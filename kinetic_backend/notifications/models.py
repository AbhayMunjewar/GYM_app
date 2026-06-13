from django.db import models
from accounts.models import User

class NotificationPriority(models.TextChoices):
    LOW = 'LOW', 'Low'
    MEDIUM = 'MEDIUM', 'Medium'
    HIGH = 'HIGH', 'High'
    CRITICAL = 'CRITICAL', 'Critical'

class NotificationType(models.TextChoices):
    MEMBERSHIP = 'MEMBERSHIP', 'Membership'
    PAYMENT = 'PAYMENT', 'Payment'
    ATTENDANCE = 'ATTENDANCE', 'Attendance'
    WORKOUT = 'WORKOUT', 'Workout'
    DIET = 'DIET', 'Diet'
    GOAL = 'GOAL', 'Goal'
    ACHIEVEMENT = 'ACHIEVEMENT', 'Achievement'
    SYSTEM = 'SYSTEM', 'System'

class Notification(models.Model):
    recipient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=255)
    message = models.TextField()
    notification_type = models.CharField(max_length=50, choices=NotificationType.choices, default=NotificationType.SYSTEM)
    priority = models.CharField(max_length=20, choices=NotificationPriority.choices, default=NotificationPriority.LOW)
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)
    action_url = models.CharField(max_length=500, null=True, blank=True)
    metadata = models.TextField(null=True, blank=True)
    is_deleted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['recipient', '-created_at']),
            models.Index(fields=['recipient', 'is_read']),
        ]

    def __str__(self):
        return f"{self.title} - {self.recipient.email}"

class DeviceType(models.TextChoices):
    ANDROID = 'ANDROID', 'Android'
    IOS = 'IOS', 'iOS'
    WEB = 'WEB', 'Web'

class DeviceToken(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='device_tokens')
    fcm_token = models.CharField(max_length=255, unique=True)
    device_type = models.CharField(max_length=20, choices=DeviceType.choices, default=DeviceType.ANDROID)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [
            models.Index(fields=['user', 'is_active']),
        ]

    def __str__(self):
        return f"{self.device_type} - {self.user.email}"

class NotificationTemplate(models.Model):
    template_name = models.CharField(max_length=100, unique=True)
    notification_type = models.CharField(max_length=50, choices=NotificationType.choices)
    title_template = models.CharField(max_length=255)
    message_template = models.TextField()
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.template_name
