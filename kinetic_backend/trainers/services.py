import os
from datetime import date, timedelta
from django.db import transaction
from django.db.models import Q, Count, Avg
from django.contrib.auth import get_user_model
from rest_framework.exceptions import ValidationError, PermissionDenied, NotFound

from gyms.models import Gym
from members.models import Member
from memberships.models import Membership
from attendance.models import Attendance
from .models import Trainer, TrainerAssignment, TrainerAuditLog, TrainerStatus, AssignmentStatus

User = get_user_model()

class TrainerService:
    @staticmethod
    def log_audit(user, action):
        TrainerAuditLog.objects.create(user=user, action=action)

    @staticmethod
    def get_trainers_for_owner(user, query_params=None):
        """
        List all trainers belonging to gyms owned by this owner.
        """
        gyms = Gym.objects.filter(owner=user, is_deleted=False)
        queryset = Trainer.objects.filter(gym__in=gyms, is_deleted=False)

        if query_params:
            search = query_params.get('search')
            if search:
                queryset = queryset.filter(
                    Q(user__full_name__icontains=search) |
                    Q(user__email__icontains=search) |
                    Q(employee_id__icontains=search) |
                    Q(specialization__icontains=search)
                )

            status = query_params.get('status')
            if status:
                queryset = queryset.filter(status=status)

            gym_id = query_params.get('gym')
            if gym_id:
                queryset = queryset.filter(gym_id=gym_id)

            branch_id = query_params.get('branch') or query_params.get('branch_id')
            if branch_id:
                queryset = queryset.filter(branch_id=branch_id)

            experience = query_params.get('experience')
            if experience:
                try:
                    queryset = queryset.filter(experience_years__gte=int(experience))
                except ValueError:
                    pass

            # Sorting
            ordering = query_params.get('ordering')
            allowed_orderings = {
                'name': 'user__full_name',
                '-name': '-user__full_name',
                'joining_date': 'joining_date',
                '-joining_date': '-joining_date',
                'experience': 'experience_years',
                '-experience': '-experience_years',
                'created_at': 'created_at',
                '-created_at': '-created_at',
            }
            if ordering in allowed_orderings:
                queryset = queryset.order_by(allowed_orderings[ordering])
            else:
                queryset = queryset.order_by('-created_at')

        return queryset

    @staticmethod
    @transaction.atomic
    def create_trainer(owner_user, data):
        """
        Create a Trainer account and profile under the owner's gym.
        """
        # Get gym owned by owner
        gym_id = data.get('gym_id')
        if gym_id:
            gym = Gym.objects.filter(id=gym_id, owner=owner_user, is_deleted=False).first()
        else:
            gym = Gym.objects.filter(owner=owner_user, is_deleted=False).first()

        if not gym:
            raise ValidationError("A valid gym owned by you is required to register a trainer.")

        # Limit check
        tenant = gym.tenant
        if tenant:
            subscription = getattr(tenant, 'subscription', None)
            if subscription:
                max_t = subscription.plan.max_trainers
                current_t = Trainer.objects.filter(gym=gym, is_deleted=False).count()
                if current_t >= max_t:
                    raise PermissionDenied(f"You have reached the maximum limit of {max_t} trainers for your plan ({subscription.plan.get_name_display()}).")

        # Check unique employee_id in gym
        employee_id = data.get('employee_id')
        if Trainer.objects.filter(gym=gym, employee_id=employee_id, is_deleted=False).exists():
            raise ValidationError(f"Employee ID '{employee_id}' already exists in this gym.")

        # Check email duplicate
        email = data.get('email')
        if User.objects.filter(email=email).exists():
            raise ValidationError(f"A user with email '{email}' already exists.")

        # 1. Create the User record
        user = User.objects.create_user(
            email=email,
            password=data.get('password', 'Trainer@Pass123'),
            full_name=data.get('full_name'),
            phone_number=data.get('phone_number', ''),
            role='TRAINER',
            is_active=True,
            is_verified=True
        )

        # 2. Create Trainer Profile
        trainer = Trainer.objects.create(
            user=user,
            gym=gym,
            employee_id=employee_id,
            specialization=data.get('specialization', ''),
            experience_years=data.get('experience_years', 0),
            certifications=data.get('certifications', ''),
            joining_date=data.get('joining_date', date.today()),
            salary=data.get('salary', 0.00),
            bio=data.get('bio', ''),
            profile_image=data.get('profile_image', ''),
            status=data.get('status', TrainerStatus.ACTIVE)
        )

        TrainerService.log_audit(owner_user, f"Trainer Created: employee_id={employee_id}, email={email}")
        return trainer

    @staticmethod
    @transaction.atomic
    def update_trainer(owner_user, trainer, data):
        """
        Update the Trainer and their corresponding User model fields.
        """
        # User details updates
        user = trainer.user
        user_updated = False
        
        full_name = data.get('full_name')
        if full_name is not None:
            user.full_name = full_name
            user_updated = True
            
        phone_number = data.get('phone_number')
        if phone_number is not None:
            user.phone_number = phone_number
            user_updated = True

        status = data.get('status')
        if status is not None:
            trainer.status = status
            # If status becomes INACTIVE or SUSPENDED, set user is_active = False or restrict login?
            # Standard: let's align status
            if status in [TrainerStatus.INACTIVE, TrainerStatus.SUSPENDED]:
                user.is_active = False
            else:
                user.is_active = True
            user_updated = True

        if user_updated:
            user.save()

        # Trainer details updates
        for field in ['specialization', 'experience_years', 'certifications', 'joining_date', 'salary', 'bio', 'profile_image']:
            val = data.get(field)
            if val is not None:
                setattr(trainer, field, val)

        trainer.save()
        TrainerService.log_audit(owner_user, f"Trainer Updated: employee_id={trainer.employee_id}")
        return trainer

    @staticmethod
    @transaction.atomic
    def delete_trainer(owner_user, trainer):
        """
        Soft delete trainer profile and deactivate linked user account.
        """
        trainer.soft_delete()
        trainer.user.is_active = False
        trainer.user.save()
        TrainerService.log_audit(owner_user, f"Trainer Soft Deleted: employee_id={trainer.employee_id}")

    @staticmethod
    def get_trainer_dashboard_stats(trainer_user):
        """
        Fetch metrics for the trainer's mobile dashboard.
        """
        trainer = Trainer.objects.filter(user=trainer_user, is_deleted=False).first()
        if not trainer:
            return {
                "trainer_id": None,
                "assigned_members_count": 0,
                "active_members_count": 0,
                "membership_expiring_soon": 0,
                "today_attendance_present": 0,
                "pending_workouts_count": 0,
                "pending_diets_count": 0,
                "next_client": None
            }

        active_assignments = TrainerAssignment.objects.filter(trainer=trainer, status=AssignmentStatus.ACTIVE)
        assigned_member_ids = active_assignments.values_list('member_id', flat=True)

        assigned_members_count = len(assigned_member_ids)
        active_members_count = Member.objects.filter(id__in=assigned_member_ids, status='ACTIVE', is_deleted=False).count()

        # Membership Expiry (Next 7 days)
        today = date.today()
        exp_date = today + timedelta(days=7)
        expiring_soon = Membership.objects.filter(
            member_id__in=assigned_member_ids,
            status='ACTIVE',
            end_date__range=[today, exp_date]
        ).count()

        # Attendance Checked In Today
        today_attendance = Attendance.objects.filter(
            member_id__in=assigned_member_ids,
            attendance_date=today,
            is_deleted=False,
            attendance_status__in=['PRESENT', 'LATE']
        ).count()

        # Next client info (simplification: first active member by name)
        next_client = None
        first_assignment = active_assignments.first()
        if first_assignment:
            next_client = f"{first_assignment.member.full_name}"

        return {
            "trainer_id": str(trainer.id),
            "assigned_members_count": assigned_members_count,
            "active_members_count": active_members_count,
            "membership_expiring_soon": expiring_soon,
            "today_attendance_present": today_attendance,
            "pending_workouts_count": 0,
            "pending_diets_count": 0,
            "next_client": next_client
        }

    @staticmethod
    def get_trainer_members(trainer, query_params=None):
        """
        List members assigned to a trainer.
        """
        assignments = TrainerAssignment.objects.filter(trainer=trainer, status=AssignmentStatus.ACTIVE)
        member_ids = assignments.values_list('member_id', flat=True)
        queryset = Member.objects.filter(id__in=member_ids, is_deleted=False)

        # Performance caching: prefetch memberships
        queryset = queryset.prefetch_related('memberships', 'attendances')

        # Custom search/filters
        if query_params:
            search = query_params.get('search')
            if search:
                queryset = queryset.filter(full_name__icontains=search)

        return queryset

    @staticmethod
    def get_owner_trainer_analytics(owner_user):
        """
        Calculate analytics for gym trainers.
        """
        gyms = Gym.objects.filter(owner=owner_user, is_deleted=False)
        total_trainers = Trainer.objects.filter(gym__in=gyms, is_deleted=False).count()
        active_trainers = Trainer.objects.filter(gym__in=gyms, status=TrainerStatus.ACTIVE, is_deleted=False).count()

        # Utilization: Total Active Members Assigned / Active Trainers
        total_active_members = Member.objects.filter(gym__in=gyms, status='ACTIVE', is_deleted=False).count()
        total_assigned_active = TrainerAssignment.objects.filter(
            trainer__gym__in=gyms,
            status=AssignmentStatus.ACTIVE,
            member__status='ACTIVE'
        ).values('member').distinct().count()

        utilization_rate = 0.0
        if active_trainers > 0:
            utilization_rate = round(float(total_assigned_active) / active_trainers, 2)

        # Members per trainer distribution
        members_per_trainer = []
        trainers = Trainer.objects.filter(gym__in=gyms, is_deleted=False)
        for t in trainers:
            clients_count = t.assignments.filter(status=AssignmentStatus.ACTIVE).count()
            members_per_trainer.append({
                "trainer_id": str(t.id),
                "name": t.user.full_name,
                "clients_count": clients_count
            })

        # Top performers (most active clients)
        top_performers = sorted(members_per_trainer, key=lambda x: x['clients_count'], reverse=True)[:5]

        # Retention placeholder rate
        trainer_retention_rate = 100.0

        return {
            "total_trainers": total_trainers,
            "active_trainers": active_trainers,
            "trainer_utilization": utilization_rate,
            "members_per_trainer": members_per_trainer,
            "top_performing_trainers": top_performers,
            "trainer_retention": trainer_retention_rate
        }


class TrainerAssignmentService:
    @staticmethod
    @transaction.atomic
    def assign_trainer(owner_user, trainer_id, member_id, notes=""):
        """
        Assigns a member to a trainer after validating all business rules.
        """
        # Validate existence
        try:
            trainer = Trainer.objects.get(id=trainer_id, is_deleted=False)
        except Trainer.DoesNotExist:
            raise NotFound("Trainer not found.")

        try:
            member = Member.objects.get(id=member_id, is_deleted=False)
        except Member.DoesNotExist:
            raise NotFound("Member not found.")

        # Business Rules checks:
        # Both must belong to same gym
        if trainer.gym != member.gym:
            raise ValidationError("Trainer and Member must belong to the same gym.")

        # Trainer must be active
        if trainer.status != TrainerStatus.ACTIVE:
            raise ValidationError("Cannot assign member to an inactive or suspended trainer.")

        # Member must be active
        if member.status != 'ACTIVE':
            raise ValidationError("Cannot assign trainer to an inactive member.")

        # Prevent duplicate active assignments
        if TrainerAssignment.objects.filter(trainer=trainer, member=member, status=AssignmentStatus.ACTIVE).exists():
            raise ValidationError("This member is already actively assigned to this trainer.")

        # Resolve existing active assignments for this member (one primary trainer)
        TrainerAssignment.objects.filter(member=member, status=AssignmentStatus.ACTIVE).update(status=AssignmentStatus.COMPLETED)

        # Create new assignment
        assignment = TrainerAssignment.objects.create(
            trainer=trainer,
            member=member,
            assigned_date=date.today(),
            assigned_by=owner_user,
            notes=notes,
            status=AssignmentStatus.ACTIVE
        )

        TrainerService.log_audit(owner_user, f"Trainer Assigned: trainer_id={trainer.id}, member_id={member.id}")
        return assignment

    @staticmethod
    @transaction.atomic
    def update_assignment(owner_user, assignment, data):
        """
        Update assignment details (notes, status).
        """
        notes = data.get('notes')
        if notes is not None:
            assignment.notes = notes

        status = data.get('status')
        if status is not None:
            assignment.status = status

        assignment.save()
        TrainerService.log_audit(owner_user, f"Assignment Updated: assignment_id={assignment.id}")
        return assignment

    @staticmethod
    @transaction.atomic
    def remove_assignment(owner_user, assignment):
        """
        Soft delete assignment (marks status as REMOVED).
        """
        assignment.status = AssignmentStatus.REMOVED
        assignment.save()
        TrainerService.log_audit(owner_user, f"Assignment Removed: assignment_id={assignment.id}")
