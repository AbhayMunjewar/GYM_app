from rest_framework import serializers
from members.models import Member
from accounts.serializers import UserSerializer

class MemberSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    gym_name = serializers.ReadOnlyField(source='gym.name')

    class Meta:
        model = Member
        fields = [
            'id', 'user', 'gym', 'gym_name', 
            'emergency_contact_name', 'emergency_contact_phone', 
            'date_of_birth', 'status', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'user', 'gym', 'gym_name', 'created_at', 'updated_at']
