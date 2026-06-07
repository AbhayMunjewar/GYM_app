from rest_framework import serializers
from .models import Gym
from accounts.serializers import UserMeSerializer

class GymSerializer(serializers.ModelSerializer):
    # owner = UserSerializer(read_only=True)

    class Meta:
        model = Gym
        fields = [
            'id', 'gym_name', 'owner', 'address', 'city', 'state', 'pincode', 
            'contact_number', 'email', 'logo', 'description', 
            'is_active', 'is_deleted', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'owner', 'is_deleted', 'created_at', 'updated_at']

class GymCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Gym
        fields = [
            'gym_name', 'address', 'city', 'state', 'pincode', 
            'contact_number', 'email', 'logo', 'description'
        ]

    def validate_contact_number(self, value):
        # Basic validation, ensure it has only digits and is 10+ length
        if not value.isdigit() or len(value) < 10:
            raise serializers.ValidationError("Enter a valid contact number.")
        return value
    
    def validate_gym_name(self, value):
        # We can add sanitization or length checks
        if len(value.strip()) < 3:
            raise serializers.ValidationError("Gym name must be at least 3 characters.")
        return value.strip()


class GymUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Gym
        fields = [
            'gym_name', 'address', 'city', 'state', 'pincode', 
            'contact_number', 'email', 'logo', 'description', 'is_active'
        ]
        extra_kwargs = {
            'gym_name': {'required': False},
            'address': {'required': False},
            'city': {'required': False},
            'state': {'required': False},
            'pincode': {'required': False},
            'contact_number': {'required': False},
            'email': {'required': False},
        }

    def validate_contact_number(self, value):
        if value and (not value.isdigit() or len(value) < 10):
            raise serializers.ValidationError("Enter a valid contact number.")
        return value
