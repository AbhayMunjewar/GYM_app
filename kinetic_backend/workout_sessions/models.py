import uuid
from django.db import models
from django.utils import timezone
from gyms.models import Gym
from trainers.models import Trainer
from members.models import Member

class WorkoutSession(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='sessions')
    trainer = models.ForeignKey(Trainer, on_delete=models.CASCADE, related_name='sessions')
    title = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    session_date = models.DateField()
    start_time = models.CharField(max_length=10)  # format: "09:00"
    end_time = models.CharField(max_length=10)    # format: "10:00"
    max_capacity = models.PositiveIntegerField(default=10)
    is_deleted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'workout_sessions'
        ordering = ['session_date', 'start_time']
        indexes = [
            models.Index(fields=['gym', 'is_deleted']),
            models.Index(fields=['trainer', 'is_deleted']),
            models.Index(fields=['session_date']),
        ]

    def __str__(self):
        return f"{self.title} on {self.session_date} ({self.start_time}-{self.end_time})"


class SessionBooking(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    session = models.ForeignKey(WorkoutSession, on_delete=models.CASCADE, related_name='bookings')
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='bookings')
    status = models.CharField(max_length=20, default='booked')  # booked | cancelled | completed
    booked_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'session_bookings'
        unique_together = ('session', 'member')
        indexes = [
            models.Index(fields=['session', 'status']),
            models.Index(fields=['member', 'status']),
        ]

    def __str__(self):
        return f"{self.member.full_name} booked for {self.session.title} ({self.status})"
