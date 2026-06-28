import uuid
from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from gyms.models import Gym
from members.models import Member

class TrainerStatus(models.TextChoices):
    ACTIVE = 'ACTIVE', _('Active')
    INACTIVE = 'INACTIVE', _('Inactive')
    SUSPENDED = 'SUSPENDED', _('Suspended')

class Trainer(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='trainer_profile')
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='trainers')
    branch = models.ForeignKey('gyms.Branch', on_delete=models.SET_NULL, null=True, blank=True, related_name='trainers')
    employee_id = models.CharField(_('Employee ID'), max_length=50)
    specialization = models.CharField(_('Specialization'), max_length=255, blank=True, null=True)
    experience_years = models.PositiveIntegerField(_('Experience (Years)'), default=0)
    certifications = models.TextField(_('Certifications'), blank=True, null=True)
    joining_date = models.DateField(_('Joining Date'))
    salary = models.DecimalField(_('Salary'), max_digits=10, decimal_places=2, default=0.00)
    bio = models.TextField(_('Bio'), blank=True, null=True)
    profile_image = models.TextField(_('Profile Image URL or Base64'), blank=True, null=True)
    status = models.CharField(_('Status'), max_length=20, choices=TrainerStatus.choices, default=TrainerStatus.ACTIVE)
    
    is_active = models.BooleanField(_('Is Active'), default=True)
    is_deleted = models.BooleanField(_('Is Deleted'), default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'trainers'
        unique_together = ('gym', 'employee_id')
        indexes = [
            models.Index(fields=['gym', 'is_deleted']),
            models.Index(fields=['branch', 'is_deleted']),
            models.Index(fields=['employee_id']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return f"{self.user.full_name} ({self.employee_id}) - {self.gym.gym_name}"

    def soft_delete(self):
        self.is_deleted = True
        self.is_active = False
        self.save()
        # Mark all active assignments as REMOVED
        self.assignments.filter(status=AssignmentStatus.ACTIVE).update(status=AssignmentStatus.REMOVED)


class AssignmentStatus(models.TextChoices):
    ACTIVE = 'ACTIVE', _('Active')
    COMPLETED = 'COMPLETED', _('Completed')
    REMOVED = 'REMOVED', _('Removed')

class TrainerAssignment(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    trainer = models.ForeignKey(Trainer, on_delete=models.CASCADE, related_name='assignments')
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='trainer_assignments')
    assigned_date = models.DateField(_('Assigned Date'))
    assigned_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name='created_assignments')
    notes = models.TextField(_('Notes'), blank=True, null=True)
    status = models.CharField(_('Status'), max_length=20, choices=AssignmentStatus.choices, default=AssignmentStatus.ACTIVE)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'trainer_assignments'
        indexes = [
            models.Index(fields=['trainer', 'status']),
            models.Index(fields=['member', 'status']),
        ]

    def __str__(self):
        return f"{self.trainer.user.full_name} -> {self.member.full_name} ({self.status})"


class TrainerAuditLog(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='trainer_audit_logs')
    action = models.CharField(_('Action'), max_length=255)
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'trainer_audit_logs'
        ordering = ['-timestamp']

    def __str__(self):
        user_email = self.user.email if self.user else "System"
        return f"{self.action} by {user_email} at {self.timestamp}"
