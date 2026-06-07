from django.db import models
from gyms.models import Gym

class Member(models.Model):
    STATUS_CHOICES = [
        ('ACTIVE', 'Active'),
        ('INACTIVE', 'Inactive'),
        ('SUSPENDED', 'Suspended'),
    ]

    GENDER_CHOICES = [
        ('MALE', 'Male'),
        ('FEMALE', 'Female'),
        ('OTHER', 'Other'),
    ]

    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='members')
    full_name = models.CharField(max_length=255)
    email = models.EmailField(max_length=255)
    phone_number = models.CharField(max_length=20)
    emergency_contact = models.CharField(max_length=20, blank=True, null=True)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, blank=True, null=True)
    date_of_birth = models.DateField(blank=True, null=True)
    height_cm = models.FloatField(blank=True, null=True)
    weight_kg = models.FloatField(blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    join_date = models.DateField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='ACTIVE')
    profile_image = models.ImageField(upload_to='member_profiles/', blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    
    is_active = models.BooleanField(default=True)
    is_deleted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'members'
        indexes = [
            models.Index(fields=['gym', 'is_deleted']),
            models.Index(fields=['email']),
            models.Index(fields=['phone_number']),
            models.Index(fields=['status']),
            models.Index(fields=['full_name']),
        ]
        unique_together = ('gym', 'email') # A gym cannot have two members with the exact same email

    def __str__(self):
        return f"{self.full_name} ({self.gym.gym_name})"

    def soft_delete(self):
        self.is_deleted = True
        self.is_active = False
        self.save()
