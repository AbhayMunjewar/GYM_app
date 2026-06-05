from rest_framework import serializers
from gyms.models import Gym

class GymSerializer(serializers.ModelSerializer):
    owner_email = serializers.ReadOnlyField(source='owner.email')

    class Meta:
        model = Gym
        fields = ['id', 'name', 'owner', 'owner_email', 'address', 'phone_number', 'email', 'created_at', 'updated_at']
        read_only_fields = ['id', 'owner', 'owner_email', 'created_at', 'updated_at']
