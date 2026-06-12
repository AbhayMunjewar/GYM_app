from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Trainer, TrainerAssignment, TrainerAuditLog

User = get_user_model()

class UserSummarySerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'full_name', 'phone_number', 'is_active']

class TrainerSerializer(serializers.ModelSerializer):
    user = UserSummarySerializer(read_only=True)
    gym_name = serializers.CharField(source='gym.gym_name', read_only=True)

    class Meta:
        model = Trainer
        fields = [
            'id', 'user', 'gym', 'gym_name', 'employee_id', 'specialization', 
            'experience_years', 'certifications', 'joining_date', 'salary', 
            'bio', 'profile_image', 'status', 'is_active', 'created_at', 'updated_at'
        ]

class TrainerCreateSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, required=False)
    full_name = serializers.CharField(max_length=255)
    phone_number = serializers.CharField(max_length=20, required=False, allow_blank=True)
    
    gym_id = serializers.UUIDField(required=False)
    employee_id = serializers.CharField(max_length=50)
    specialization = serializers.CharField(max_length=255, required=False, allow_blank=True)
    experience_years = serializers.IntegerField(required=False, default=0)
    certifications = serializers.CharField(required=False, allow_blank=True)
    joining_date = serializers.DateField(required=False)
    salary = serializers.DecimalField(max_digits=10, decimal_places=2, required=False, default=0.00)
    bio = serializers.CharField(required=False, allow_blank=True)
    profile_image = serializers.CharField(required=False, allow_blank=True)
    status = serializers.CharField(required=False, default='ACTIVE')

class TrainerUpdateSerializer(serializers.Serializer):
    full_name = serializers.CharField(max_length=255, required=False)
    phone_number = serializers.CharField(max_length=20, required=False, allow_blank=True)
    
    specialization = serializers.CharField(max_length=255, required=False, allow_blank=True)
    experience_years = serializers.IntegerField(required=False)
    certifications = serializers.CharField(required=False, allow_blank=True)
    joining_date = serializers.DateField(required=False)
    salary = serializers.DecimalField(max_digits=10, decimal_places=2, required=False)
    bio = serializers.CharField(required=False, allow_blank=True)
    profile_image = serializers.CharField(required=False, allow_blank=True)
    status = serializers.CharField(required=False)

class TrainerAssignmentSerializer(serializers.ModelSerializer):
    trainer_name = serializers.CharField(source='trainer.user.full_name', read_only=True)
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    assigned_by_name = serializers.CharField(source='assigned_by.full_name', read_only=True)

    class Meta:
        model = TrainerAssignment
        fields = [
            'id', 'trainer', 'trainer_name', 'member', 'member_name', 
            'assigned_date', 'assigned_by', 'assigned_by_name', 
            'notes', 'status', 'created_at', 'updated_at'
        ]

class TrainerAssignmentCreateSerializer(serializers.Serializer):
    trainer_id = serializers.UUIDField()
    member_id = serializers.IntegerField()
    notes = serializers.CharField(required=False, allow_blank=True, default='')

class TrainerAuditLogSerializer(serializers.ModelSerializer):
    user_email = serializers.CharField(source='user.email', read_only=True)

    class Meta:
        model = TrainerAuditLog
        fields = ['id', 'user', 'user_email', 'action', 'timestamp']
