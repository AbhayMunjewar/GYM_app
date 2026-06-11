from rest_framework import serializers
from .models import Member
from gyms.serializers import GymSerializer

class MemberSerializer(serializers.ModelSerializer):
    class Meta:
        model = Member
        fields = '__all__'
        read_only_fields = ['gym', 'is_deleted', 'created_at', 'updated_at']

class MemberListSerializer(serializers.ModelSerializer):
    gym_name = serializers.CharField(source='gym.gym_name', read_only=True)
    active_plan_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Member
        fields = ['id', 'gym_name', 'full_name', 'email', 'phone_number', 'status', 'join_date', 'profile_image', 'active_plan_name']

    def get_active_plan_name(self, obj):
        active_membership = obj.memberships.filter(status='ACTIVE').first()
        if active_membership:
            return active_membership.membership_plan.plan_name
        return None

class MemberCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Member
        exclude = ['is_deleted', 'created_at', 'updated_at', 'gym']

class MemberUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Member
        exclude = ['is_deleted', 'created_at', 'updated_at', 'gym']
