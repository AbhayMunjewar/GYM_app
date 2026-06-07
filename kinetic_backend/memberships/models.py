import uuid
from django.db import models
from gyms.models import Gym
from members.models import Member
from django.utils.translation import gettext_lazy as _

class MembershipPlan(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='membership_plans')
    plan_name = models.CharField(_('plan name'), max_length=255)
    description = models.TextField(_('description'), blank=True, null=True)
    duration_days = models.PositiveIntegerField(_('duration in days'))
    price = models.DecimalField(_('price'), max_digits=10, decimal_places=2)
    
    is_active = models.BooleanField(_('active status'), default=True)
    is_deleted = models.BooleanField(_('deleted status'), default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'membership_plans'
        verbose_name = _('membership plan')
        verbose_name_plural = _('membership plans')
        indexes = [
            models.Index(fields=['gym', 'is_deleted']),
            models.Index(fields=['is_active']),
        ]

    def __str__(self):
        return f"{self.plan_name} - {self.gym.gym_name}"

    def soft_delete(self):
        self.is_deleted = True
        self.is_active = False
        self.save(update_fields=['is_deleted', 'is_active', 'updated_at'])


class Membership(models.Model):
    STATUS_CHOICES = [
        ('ACTIVE', 'Active'),
        ('EXPIRED', 'Expired'),
        ('PENDING', 'Pending'),
        ('CANCELLED', 'Cancelled'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='memberships')
    membership_plan = models.ForeignKey(MembershipPlan, on_delete=models.PROTECT, related_name='assigned_memberships')
    
    start_date = models.DateField(_('start date'))
    end_date = models.DateField(_('end date'))
    status = models.CharField(_('status'), max_length=20, choices=STATUS_CHOICES, default='ACTIVE')
    notes = models.TextField(_('notes'), blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'member_memberships'
        verbose_name = _('membership')
        verbose_name_plural = _('memberships')
        indexes = [
            models.Index(fields=['member', 'status']),
            models.Index(fields=['start_date']),
            models.Index(fields=['end_date']),
        ]

    def __str__(self):
        return f"{self.member.full_name} - {self.membership_plan.plan_name} ({self.status})"
