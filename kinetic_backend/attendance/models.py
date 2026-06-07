from django.db import models
from gyms.models import Gym
from members.models import Member
from memberships.models import Membership
from django.utils import timezone

class Attendance(models.Model):
    class StatusChoices(models.TextChoices):
        PRESENT = 'PRESENT', 'Present'
        ABSENT = 'ABSENT', 'Absent'
        LATE = 'LATE', 'Late'

    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='attendances')
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='attendances')
    membership = models.ForeignKey(Membership, on_delete=models.CASCADE, related_name='attendances')
    
    attendance_date = models.DateField(default=timezone.now)
    check_in_time = models.DateTimeField(null=True, blank=True)
    check_out_time = models.DateTimeField(null=True, blank=True)
    
    attendance_status = models.CharField(
        max_length=20,
        choices=StatusChoices.choices,
        default=StatusChoices.PRESENT
    )
    notes = models.TextField(blank=True, null=True)

    is_deleted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def soft_delete(self):
        self.is_deleted = True
        self.save()

    class Meta:
        db_table = 'attendance_records'
        indexes = [
            models.Index(fields=['attendance_date']),
            models.Index(fields=['member', 'attendance_date']),
            models.Index(fields=['gym', 'attendance_date']),
        ]
        # We can enforce unique_together conditionally for non-deleted records in the service,
        # but Django 3+ also supports UniqueConstraint with condition.
        constraints = [
            models.UniqueConstraint(
                fields=['member', 'attendance_date'],
                condition=models.Q(is_deleted=False),
                name='unique_active_attendance_per_day'
            )
        ]
        ordering = ['-attendance_date', '-check_in_time']

    def __str__(self):
        return f"{self.member.full_name} - {self.attendance_date} ({self.attendance_status})"
