import uuid
from django.db import models
from gyms.models import Gym
from members.models import Member
from attendance.models import Attendance

class GymQRCode(models.Model):
    QR_TYPE_CHOICES = [
        ('STATIC', 'Static'),
        ('DYNAMIC', 'Dynamic'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='qr_codes')
    qr_token = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)
    qr_type = models.CharField(max_length=10, choices=QR_TYPE_CHOICES, default='DYNAMIC')
    is_active = models.BooleanField(default=True)
    expires_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'gym_qr_codes'
        indexes = [
            models.Index(fields=['gym', 'is_active']),
            models.Index(fields=['qr_token']),
        ]

    def __str__(self):
        return f"QR for {self.gym.gym_name} ({self.qr_type})"

class QRScanLog(models.Model):
    STATUS_CHOICES = [
        ('SUCCESS', 'Success'),
        ('FAILED', 'Failed'),
        ('DUPLICATE', 'Duplicate'),
        ('EXPIRED', 'Expired'),
        ('INVALID', 'Invalid'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='qr_scans')
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='qr_scans')
    attendance = models.ForeignKey(Attendance, on_delete=models.SET_NULL, null=True, blank=True, related_name='qr_scan')
    scan_time = models.DateTimeField(auto_now_add=True)
    ip_address = models.GenericIPAddressField(blank=True, null=True)
    device_info = models.CharField(max_length=255, blank=True, null=True)
    scan_status = models.CharField(max_length=10, choices=STATUS_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'qr_scan_logs'
        indexes = [
            models.Index(fields=['member', 'scan_time']),
            models.Index(fields=['gym', 'scan_time']),
            models.Index(fields=['scan_status']),
        ]

    def __str__(self):
        return f"{self.member.full_name} scanned at {self.scan_time} ({self.scan_status})"
