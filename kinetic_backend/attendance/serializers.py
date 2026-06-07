from rest_framework import serializers
from .models import Attendance
from members.serializers import MemberSerializer
from memberships.serializers import MembershipPlanSerializer

class AttendanceSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    member_email = serializers.EmailField(source='member.email', read_only=True)
    plan_name = serializers.CharField(source='membership.membership_plan.plan_name', read_only=True)

    class Meta:
        model = Attendance
        fields = [
            'id', 'gym', 'member', 'membership', 'attendance_date', 
            'check_in_time', 'check_out_time', 'attendance_status', 'notes',
            'member_name', 'member_email', 'plan_name',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'gym', 'member', 'membership', 'attendance_date', 'check_in_time', 'check_out_time', 'attendance_status', 'created_at', 'updated_at']

class CheckInSerializer(serializers.Serializer):
    member_id = serializers.IntegerField(required=True)

class CheckOutSerializer(serializers.Serializer):
    member_id = serializers.IntegerField(required=True)
