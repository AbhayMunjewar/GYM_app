from rest_framework import status
from rest_framework.views import APIView
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Q, Avg
from django.utils import timezone
from datetime import datetime, date

from core.responses import success_response, failure_response
from core.permissions import IsGymOwner, IsTrainer, IsMember
from accounts.models import UserRole
from trainers.models import Trainer
from members.models import Member
from gyms.models import Gym

from .models import Food, MealTemplate, MealFood, DietPlan, DietPlanMeal, MemberDietPlan, DietLog
from .serializers import (
    FoodSerializer, MealTemplateSerializer, DietPlanSerializer,
    MemberDietPlanSerializer, DietLogSerializer
)
from .services import NutritionEngine, DietService

class StandardResultsSetPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'
    max_page_size = 100


class FoodListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        queryset = Food.objects.filter(is_active=True, is_deleted=False)
        
        # Search filter
        search = request.query_params.get('search')
        if search:
            queryset = queryset.filter(food_name__icontains=search)
            
        # Category filter
        category = request.query_params.get('category')
        if category:
            queryset = queryset.filter(category=category.upper())
            
        paginator = StandardResultsSetPagination()
        page = paginator.paginate_queryset(queryset, request, view=self)
        if page is not None:
            serializer = FoodSerializer(page, many=True)
            return success_response(
                "Foods list retrieved successfully",
                data={
                    "count": paginator.page.paginator.count,
                    "next": paginator.get_next_link(),
                    "previous": paginator.get_previous_link(),
                    "results": serializer.data
                }
            )
            
        serializer = FoodSerializer(queryset, many=True)
        return success_response("Foods list retrieved successfully", data=serializer.data)

    def post(self, request):
        if request.user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            return failure_response(
                "Access Denied. Only Gym Owners and Trainers can add foods to the library.",
                status_code=status.HTTP_403_FORBIDDEN
            )
            
        serializer = FoodSerializer(data=request.data)
        if serializer.is_valid():
            food = serializer.save()
            return success_response(
                "Food library item created successfully",
                data=FoodSerializer(food).data,
                status_code=status.HTTP_201_CREATED
            )
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class FoodDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        food = get_object_or_404(Food, id=id, is_deleted=False)
        serializer = FoodSerializer(food)
        return success_response("Food details retrieved", data=serializer.data)

    def patch(self, request, id):
        if request.user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            return failure_response(
                "Access Denied. Only Gym Owners and Trainers can modify foods.",
                status_code=status.HTTP_403_FORBIDDEN
            )
        food = get_object_or_404(Food, id=id, is_deleted=False)
        serializer = FoodSerializer(food, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return success_response("Food library item updated", data=serializer.data)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, id):
        if request.user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            return failure_response(
                "Access Denied. Only Gym Owners and Trainers can delete foods.",
                status_code=status.HTTP_403_FORBIDDEN
            )
        food = get_object_or_404(Food, id=id, is_deleted=False)
        food.is_deleted = True
        food.is_active = False
        food.save()
        return success_response("Food library item soft deleted successfully")


class MealTemplateListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Allow Trainers and Owners to view.
        # Trainers see their own templates, Owners see gym templates.
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            queryset = MealTemplate.objects.filter(trainer=trainer_profile)
        elif request.user.role == UserRole.OWNER:
            queryset = MealTemplate.objects.filter(trainer__gym__owner=request.user)
        else:
            return failure_response(
                "Access Denied. Only Gym Owners and Trainers can view meal templates.",
                status_code=status.HTTP_403_FORBIDDEN
            )
            
        meal_type = request.query_params.get('meal_type')
        if meal_type:
            queryset = queryset.filter(meal_type=meal_type.upper())

        serializer = MealTemplateSerializer(queryset, many=True)
        return success_response("Meal templates retrieved", data=serializer.data)

    def post(self, request):
        if request.user.role != UserRole.TRAINER:
            return failure_response(
                "Access Denied. Only Trainers can create meal templates.",
                status_code=status.HTTP_403_FORBIDDEN
            )
            
        trainer_profile = get_object_or_404(Trainer, user=request.user)
        
        # Enforce trainer self-ownership
        data = request.data.copy()
        data['trainer'] = str(trainer_profile.id)

        serializer = MealTemplateSerializer(data=data)
        if serializer.is_valid():
            meal_template = serializer.save()
            return success_response(
                "Meal template created successfully",
                data=MealTemplateSerializer(meal_template).data,
                status_code=status.HTTP_201_CREATED
            )
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class MealTemplateDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        template = get_object_or_404(MealTemplate, id=id)
        serializer = MealTemplateSerializer(template)
        return success_response("Meal template details retrieved", data=serializer.data)

    def patch(self, request, id):
        template = get_object_or_404(MealTemplate, id=id)
        
        # Ownership verification
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            if template.trainer != trainer_profile:
                return failure_response("Access Denied. You do not own this template.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role != UserRole.OWNER:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
            
        serializer = MealTemplateSerializer(template, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return success_response("Meal template updated successfully", data=serializer.data)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, id):
        template = get_object_or_404(MealTemplate, id=id)
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            if template.trainer != trainer_profile:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role != UserRole.OWNER:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
            
        template.delete()
        return success_response("Meal template deleted successfully")


class DietPlanListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Access protection
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            queryset = DietPlan.objects.filter(gym=trainer_profile.gym, is_deleted=False)
        elif request.user.role == UserRole.OWNER:
            queryset = DietPlan.objects.filter(gym__owner=request.user, is_deleted=False)
        elif request.user.role == UserRole.MEMBER:
            member_profile = get_object_or_404(Member, email=request.user.email)
            queryset = DietPlan.objects.filter(gym=member_profile.gym, status='ACTIVE', is_deleted=False)
        else:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)

        # Filters
        goal = request.query_params.get('goal')
        if goal:
            queryset = queryset.filter(goal=goal.upper())
            
        status_filter = request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter.upper())
            
        search = request.query_params.get('search')
        if search:
            queryset = queryset.filter(plan_name__icontains=search)

        paginator = StandardResultsSetPagination()
        page = paginator.paginate_queryset(queryset, request, view=self)
        if page is not None:
            serializer = DietPlanSerializer(page, many=True)
            return success_response(
                "Diet plans retrieved",
                data={
                    "count": paginator.page.paginator.count,
                    "next": paginator.get_next_link(),
                    "previous": paginator.get_previous_link(),
                    "results": serializer.data
                }
            )

        serializer = DietPlanSerializer(queryset, many=True)
        return success_response("Diet plans retrieved", data=serializer.data)

    def post(self, request):
        if request.user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            return failure_response("Access Denied. Only Owners or Trainers can create diet plans.", status_code=status.HTTP_403_FORBIDDEN)
            
        # Resolve gym and trainer fields for verification
        data = request.data.copy()
        
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            gym_id = data.get('gym')
            if gym_id and gym_id != str(trainer_profile.gym.id):
                return failure_response(
                    "You do not have permission to create diet plans for this gym.",
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            data['trainer'] = str(trainer_profile.id)
            data['gym'] = str(trainer_profile.gym.id)
        else: # Owner
            # Resolve gym from owner
            gym = Gym.objects.filter(owner=request.user).first()
            if not gym:
                return failure_response("Owner has no gym profiles configured.", status_code=status.HTTP_400_BAD_REQUEST)
            gym_id = data.get('gym')
            if gym_id and gym_id != str(gym.id):
                return failure_response(
                    "You do not have permission to create diet plans for this gym.",
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            data['gym'] = str(gym.id)
            # Must specify trainer_id for owner creations
            if 'trainer' not in data:
                return failure_response("Trainer ID must be specified for owner created diet plans.", status_code=status.HTTP_400_BAD_REQUEST)

        serializer = DietPlanSerializer(data=data)
        if serializer.is_valid():
            diet_plan = serializer.save()
            return success_response(
                "Diet plan created successfully",
                data=DietPlanSerializer(diet_plan).data,
                status_code=status.HTTP_201_CREATED
            )
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class DietPlanDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        diet_plan = get_object_or_404(DietPlan, id=id, is_deleted=False)
        
        # Verify gym membership
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            if diet_plan.gym != trainer_profile.gym:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == UserRole.OWNER:
            if diet_plan.gym.owner != request.user:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == UserRole.MEMBER:
            member_profile = get_object_or_404(Member, email=request.user.email)
            if diet_plan.gym != member_profile.gym:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
                
        serializer = DietPlanSerializer(diet_plan)
        return success_response("Diet plan details retrieved", data=serializer.data)

    def patch(self, request, id):
        diet_plan = get_object_or_404(DietPlan, id=id, is_deleted=False)
        
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            if diet_plan.trainer != trainer_profile:
                return failure_response("Access Denied. You do not own this plan.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == UserRole.OWNER:
            if diet_plan.gym.owner != request.user:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        else:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
            
        serializer = DietPlanSerializer(diet_plan, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return success_response("Diet plan updated successfully", data=serializer.data)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, id):
        diet_plan = get_object_or_404(DietPlan, id=id, is_deleted=False)
        
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            if diet_plan.trainer != trainer_profile:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == UserRole.OWNER:
            if diet_plan.gym.owner != request.user:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        else:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
            
        diet_plan.is_deleted = True
        diet_plan.status = 'ARCHIVED'
        diet_plan.save()
        return success_response("Diet plan soft deleted successfully")


class DietAssignmentListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            queryset = MemberDietPlan.objects.filter(member__gym=trainer_profile.gym)
        elif request.user.role == UserRole.OWNER:
            queryset = MemberDietPlan.objects.filter(member__gym__owner=request.user)
        elif request.user.role == UserRole.MEMBER:
            member_profile = get_object_or_404(Member, email=request.user.email)
            queryset = MemberDietPlan.objects.filter(member=member_profile)
        else:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
            
        serializer = MemberDietPlanSerializer(queryset, many=True)
        return success_response("Diet assignments list retrieved", data=serializer.data)

    def post(self, request):
        # Only Trainers or Owners can assign diets
        if request.user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            return failure_response("Access Denied. Only Owners or Trainers can assign diets.", status_code=status.HTTP_403_FORBIDDEN)
            
        data = request.data.copy()
        
        # Autofill assigned_by if trainer
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            data['assigned_by'] = str(trainer_profile.id)
            
        serializer = MemberDietPlanSerializer(data=data)
        if serializer.is_valid():
            assignment = serializer.save()
            return success_response(
                "Diet plan assigned successfully",
                data=MemberDietPlanSerializer(assignment).data,
                status_code=status.HTTP_201_CREATED
            )
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class DietAssignmentDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        assignment = get_object_or_404(MemberDietPlan, id=id)
        
        # Verify cross-gym access
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            if assignment.member.gym != trainer_profile.gym:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == UserRole.OWNER:
            if assignment.member.gym.owner != request.user:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == UserRole.MEMBER:
            if assignment.member.email != request.user.email:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
                
        serializer = MemberDietPlanSerializer(assignment)
        return success_response("Diet assignment details retrieved", data=serializer.data)

    def patch(self, request, id):
        assignment = get_object_or_404(MemberDietPlan, id=id)
        
        if request.user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
            
        # Verify cross-gym
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            if assignment.member.gym != trainer_profile.gym:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == UserRole.OWNER:
            if assignment.member.gym.owner != request.user:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
                
        serializer = MemberDietPlanSerializer(assignment, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return success_response("Diet assignment updated successfully", data=serializer.data)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, id):
        assignment = get_object_or_404(MemberDietPlan, id=id)
        if request.user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
            
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            if assignment.member.gym != trainer_profile.gym:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == UserRole.OWNER:
            if assignment.member.gym.owner != request.user:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
                
        assignment.delete()
        return success_response("Diet assignment deleted successfully")


class DietLogListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role == UserRole.MEMBER:
            member_profile = get_object_or_404(Member, email=request.user.email)
            queryset = DietLog.objects.filter(member=member_profile)
        elif request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            queryset = DietLog.objects.filter(member__gym=trainer_profile.gym)
        elif request.user.role == UserRole.OWNER:
            queryset = DietLog.objects.filter(member__gym__owner=request.user)
        else:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
            
        serializer = DietLogSerializer(queryset, many=True)
        return success_response("Diet logs retrieved", data=serializer.data)

    def post(self, request):
        data = request.data.copy()
        
        # If logged in as member, autofill member
        if request.user.role == UserRole.MEMBER:
            member_profile = get_object_or_404(Member, email=request.user.email)
            data['member'] = member_profile.id
        else:
            if 'member' not in data:
                return failure_response("Member ID required to submit log.", status_code=status.HTTP_400_BAD_REQUEST)
                
        # Handle unique constraint: if already exists for this slot on this day, update instead of create.
        assigned_diet_id = data.get('assigned_diet')
        meal_id = data.get('meal')
        today = timezone.localdate()
        
        existing_log = DietLog.objects.filter(
            assigned_diet_id=assigned_diet_id,
            meal_id=meal_id,
            created_at__date=today
        ).first()
        
        if existing_log:
            serializer = DietLogSerializer(existing_log, data=data, partial=True)
        else:
            serializer = DietLogSerializer(data=data)
            
        if serializer.is_valid():
            log = serializer.save()

            # Trigger Gamification Event on completed meals
            if log.completed:
                try:
                    from gamification.services import GamificationEngine, ActivityType
                    GamificationEngine.trigger_event(log.member, ActivityType.DIET_COMPLETION, reference_id=log.id)
                except Exception:
                    pass

            return success_response(
                "Diet meal logged successfully",
                data=DietLogSerializer(log).data,
                status_code=status.HTTP_201_CREATED if not existing_log else status.HTTP_200_OK
            )
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class MemberDietProgressView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, member_id):
        member = get_object_or_404(Member, id=member_id)
        
        # Permission Verification
        if request.user.role == UserRole.MEMBER:
            if member.email != request.user.email:
                return failure_response("Access Denied. Cannot view another member's progress.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            if member.gym != trainer_profile.gym:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == UserRole.OWNER:
            if member.gym.owner != request.user:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
                
        # Get active diet plan assignment
        assigned_diet = MemberDietPlan.objects.filter(member=member, status='ACTIVE').first()
        if not assigned_diet:
            return success_response(
                "No active diet plan assigned to this member.",
                data={
                    "compliance_percentage": 0.0,
                    "target_calories": 0,
                    "target_protein": 0,
                    "target_carbs": 0,
                    "target_fats": 0,
                    "consumed_calories": 0,
                    "consumed_protein": 0.0,
                    "consumed_carbs": 0.0,
                    "consumed_fats": 0.0,
                    "remaining_calories": 0,
                    "completed_meals_count": 0,
                    "skipped_meals_count": 0,
                    "total_plan_meals": 0,
                    "current_day_number": None
                }
            )
            
        stats = NutritionEngine.get_member_diet_progress_stats(member, assigned_diet)
        return success_response("Progress metrics retrieved", data=stats)


class DietReportsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        report_type = request.query_params.get('type', 'COMPLIANCE').upper()
        
        # RBAC Check: Reports are generally for Owners and Trainers
        if request.user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            return failure_response("Access Denied. Reports are reserved for Trainers and Owners.", status_code=status.HTTP_403_FORBIDDEN)
            
        # Owner / Trainer scoping
        if request.user.role == UserRole.TRAINER:
            trainer_profile = get_object_or_404(Trainer, user=request.user)
            gym = trainer_profile.gym
            trainer_filter = Q(assigned_by=trainer_profile)
        else:
            gym = Gym.objects.filter(owner=request.user).first()
            trainer_filter = Q(member__gym=gym)

        if not gym:
            return failure_response("Gym profile not found.", status_code=status.HTTP_400_BAD_REQUEST)

        # 1. Diet Compliance Report
        if report_type == 'COMPLIANCE':
            assignments = MemberDietPlan.objects.filter(trainer_filter)
            data_results = []
            for assignment in assignments:
                stats = NutritionEngine.get_member_diet_progress_stats(assignment.member, assignment)
                data_results.append({
                    'member_name': assignment.member.full_name,
                    'diet_plan_name': assignment.diet_plan.plan_name,
                    'compliance_percentage': stats['compliance_percentage'],
                    'start_date': assignment.start_date.strftime("%Y-%m-%d"),
                    'end_date': assignment.end_date.strftime("%Y-%m-%d"),
                    'status': assignment.status
                })
            return success_response("Diet Compliance report generated", data=data_results)
            
        # 2. Nutrition Summary Report
        elif report_type == 'NUTRITION':
            # Aggregate average target calories vs actual average consumed calories
            assignments = MemberDietPlan.objects.filter(trainer_filter)
            data_results = []
            for assignment in assignments:
                stats = NutritionEngine.get_member_diet_progress_stats(assignment.member, assignment)
                data_results.append({
                    'member_name': assignment.member.full_name,
                    'target_calories': stats['target_calories'],
                    'consumed_calories': stats['consumed_calories'],
                    'consumed_protein': stats['consumed_protein'],
                    'consumed_carbs': stats['consumed_carbs'],
                    'consumed_fats': stats['consumed_fats']
                })
            return success_response("Nutrition report generated", data=data_results)
            
        # 3. Trainer Performance
        elif report_type == 'TRAINER_PERFORMANCE':
            # Count assignments per trainer, average compliance of their assigned members
            trainers = Trainer.objects.filter(gym=gym)
            data_results = []
            for t in trainers:
                assignments = MemberDietPlan.objects.filter(assigned_by=t)
                total_assigned = assignments.count()
                
                # Compute avg compliance
                total_compliance = 0.0
                valid_count = 0
                for a in assignments:
                    stats = NutritionEngine.get_member_diet_progress_stats(a.member, a)
                    total_compliance += stats['compliance_percentage']
                    valid_count += 1
                    
                avg_compliance = round(total_compliance / valid_count, 1) if valid_count > 0 else 0.0
                data_results.append({
                    'trainer_name': t.user.full_name,
                    'employee_id': t.employee_id,
                    'total_members_assigned': total_assigned,
                    'average_compliance_percentage': avg_compliance
                })
            return success_response("Trainer Diet Performance report generated", data=data_results)
            
        # 4. Member Diet Progress
        elif report_type == 'MEMBER_PROGRESS':
            member_id = request.query_params.get('member_id')
            if not member_id:
                return failure_response("member_id required for Member Diet Progress report.", status_code=status.HTTP_400_BAD_REQUEST)
            member = get_object_or_404(Member, id=member_id, gym=gym)
            assigned_diets = MemberDietPlan.objects.filter(member=member).order_by('-created_at')
            data_results = []
            for ad in assigned_diets:
                stats = NutritionEngine.get_member_diet_progress_stats(member, ad)
                data_results.append({
                    'plan_name': ad.diet_plan.plan_name,
                    'compliance_percentage': stats['compliance_percentage'],
                    'status': ad.status,
                    'start_date': ad.start_date.strftime("%Y-%m-%d"),
                    'end_date': ad.end_date.strftime("%Y-%m-%d"),
                })
            return success_response("Member Diet Progress report generated", data=data_results)

        return failure_response("Invalid report type.", status_code=status.HTTP_400_BAD_REQUEST)
