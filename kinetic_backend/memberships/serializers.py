from rest_framework import serializers
from .models import MembershipPlan, Membership
from gyms.models import Gym
from members.models import Member
from members.serializers import MemberSerializer

class MembershipPlanSerializer(serializers.ModelSerializer):
    gym_id = serializers.PrimaryKeyRelatedField(
        queryset=Gym.objects.all(),
        source='gym',
        write_only=True
    )
    
    class Meta:
        model = MembershipPlan
        fields = [
            'id', 'gym_id', 'plan_name', 'description', 
            'duration_days', 'price', 'is_active', 
            'is_deleted', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'is_deleted', 'created_at', 'updated_at']

    def validate(self, attrs):
        gym = attrs.get('gym')
        request = self.context.get('request')
        
        if request and gym:
            # Ensure the user owns the gym they are trying to create a plan for
            if gym.owner != request.user:
                raise serializers.ValidationError({"gym_id": "You do not have permission to create a plan for this gym."})
        return attrs


class MembershipSerializer(serializers.ModelSerializer):
    member_id = serializers.PrimaryKeyRelatedField(
        queryset=Member.objects.all(),
        source='member',
        write_only=True
    )
    membership_plan_id = serializers.PrimaryKeyRelatedField(
        queryset=MembershipPlan.objects.all(),
        source='membership_plan',
        write_only=True
    )
    
    # Read-only nested representation for the response
    plan_details = MembershipPlanSerializer(source='membership_plan', read_only=True)
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    member_email = serializers.EmailField(source='member.email', read_only=True)

    class Meta:
        model = Membership
        fields = [
            'id', 'member_id', 'membership_plan_id', 'plan_details',
            'member_name', 'member_email',
            'start_date', 'end_date', 'status', 'notes', 
            'created_at', 'updated_at'
        ]
        # start_date, end_date and status will be calculated automatically based on the plan
        read_only_fields = ['id', 'start_date', 'end_date', 'status', 'created_at', 'updated_at']

    def validate(self, attrs):
        member = attrs.get('member')
        plan = attrs.get('membership_plan')
        request = self.context.get('request')
        
        # In update, member and plan might not be in attrs if not provided
        if self.instance:
            member = member or self.instance.member
            plan = plan or self.instance.membership_plan

        if member and plan:
            # Prevent cross-gym assignment
            if member.gym != plan.gym:
                raise serializers.ValidationError("Cannot assign a membership plan from a different gym.")
            
            # Ensure the user owns the gym
            if request and member.gym.owner != request.user:
                raise serializers.ValidationError("You do not have permission to assign memberships for this gym.")
            
        return attrs
