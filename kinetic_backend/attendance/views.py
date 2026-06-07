from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from core.responses import success_response, failure_response
from core.pagination import StandardResultsSetPagination
from .models import Attendance
from .serializers import AttendanceSerializer, CheckInSerializer, CheckOutSerializer
from .services import AttendanceService, StreakService
from gyms.models import Gym
from django.utils import timezone
from datetime import timedelta

class AttendanceViewSet(viewsets.ModelViewSet):
    serializer_class = AttendanceSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        user = self.request.user
        queryset = Attendance.objects.filter(is_deleted=False)

        if user.role == 'OWNER':
            queryset = queryset.filter(gym__owner=user)
        elif user.role == 'MEMBER':
            queryset = queryset.filter(member__email=user.email)
        elif user.role == 'TRAINER':
            # Trainers might see attendance for their gym
            queryset = queryset.filter(gym__trainers__user=user)
        else:
            queryset = Attendance.objects.none()

        # Filtering
        date_filter = self.request.query_params.get('date')
        if date_filter:
            queryset = queryset.filter(attendance_date=date_filter)

        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(attendance_status=status_filter)

        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(member__full_name__icontains=search)

        return queryset.order_by('-attendance_date', '-check_in_time')

    def get_gym_for_owner(self):
        gym = Gym.objects.filter(owner=self.request.user, is_deleted=False).first()
        if not gym:
            raise ValueError("No active gym found for owner.")
        return gym

    def get_gym_for_member(self):
        from members.models import Member
        member = Member.objects.filter(email=self.request.user.email, is_deleted=False).first()
        if not member:
            raise ValueError("Member profile not found.")
        return member.gym

    @action(detail=False, methods=['post'], url_path='check-in')
    def check_in(self, request):
        serializer = CheckInSerializer(data=request.data)
        if not serializer.is_valid():
            return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)
        
        member_id = serializer.validated_data['member_id']
        
        try:
            if request.user.role == 'OWNER':
                gym = self.get_gym_for_owner()
            elif request.user.role == 'MEMBER':
                gym = self.get_gym_for_member()
            else:
                return failure_response("Unauthorized role for check-in.", status_code=status.HTTP_403_FORBIDDEN)
                
            attendance = AttendanceService.check_in(member_id, gym)
            return success_response("Check-in successful.", data=AttendanceSerializer(attendance).data, status_code=status.HTTP_201_CREATED)
        except ValueError as e:
            return failure_response(str(e), status_code=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return failure_response("An unexpected error occurred.", status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['post'], url_path='check-out')
    def check_out(self, request):
        serializer = CheckOutSerializer(data=request.data)
        if not serializer.is_valid():
            return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)
        
        member_id = serializer.validated_data['member_id']
        
        try:
            if request.user.role == 'OWNER':
                gym = self.get_gym_for_owner()
            elif request.user.role == 'MEMBER':
                gym = self.get_gym_for_member()
            else:
                return failure_response("Unauthorized role for check-out.", status_code=status.HTTP_403_FORBIDDEN)

            attendance = AttendanceService.check_out(member_id, gym)
            return success_response("Check-out successful.", data=AttendanceSerializer(attendance).data, status_code=status.HTTP_200_OK)
        except ValueError as e:
            return failure_response(str(e), status_code=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return failure_response("An unexpected error occurred.", status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['get'], url_path='member/(?P<member_id>[^/.]+)')
    def member_history(self, request, member_id=None):
        queryset = self.get_queryset().filter(member_id=member_id)
        page = self.paginate_queryset(queryset)
        
        # Also include streak info in response meta or a separate endpoint
        streak_info = StreakService.calculate_streak(member_id)

        if page is not None:
            serializer = self.get_serializer(page, many=True)
            resp = self.get_paginated_response(serializer.data).data
            resp['streak_info'] = streak_info
            return success_response("Member history retrieved.", data=resp)

        serializer = self.get_serializer(queryset, many=True)
        return success_response("Member history retrieved.", data={"history": serializer.data, "streak_info": streak_info})

    @action(detail=False, methods=['get'], url_path='dashboard/owner')
    def dashboard_owner(self, request):
        if request.user.role != 'OWNER':
            return failure_response("Unauthorized.", status_code=status.HTTP_403_FORBIDDEN)
        
        try:
            gym = self.get_gym_for_owner()
            stats = AttendanceService.get_dashboard_stats(gym.id)
            return success_response("Owner dashboard stats retrieved.", data=stats)
        except ValueError as e:
            return failure_response(str(e), status_code=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'], url_path='reports/analytics')
    def analytics_reports(self, request):
        if request.user.role != 'OWNER':
            return failure_response("Unauthorized.", status_code=status.HTTP_403_FORBIDDEN)
        
        try:
            gym = self.get_gym_for_owner()
            peak_hours = AttendanceService.get_peak_hours(gym.id)
            # could add more reports here
            return success_response("Analytics retrieved.", data={"peak_hours": peak_hours})
        except ValueError as e:
            return failure_response(str(e), status_code=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'], url_path='dashboard/member')
    def dashboard_member(self, request):
        if request.user.role != 'MEMBER':
            return failure_response("Unauthorized.", status_code=status.HTTP_403_FORBIDDEN)
            
        from members.models import Member
        member = Member.objects.filter(email=request.user.email, is_deleted=False).first()
        if not member:
            return failure_response("Member profile not found.", status_code=status.HTTP_404_NOT_FOUND)

        streak_info = StreakService.calculate_streak(member.id)
        
        # Check if already checked in today
        today = timezone.localtime().date()
        attendance = Attendance.objects.filter(member=member, attendance_date=today, is_deleted=False).first()
        is_checked_in = False
        is_checked_out = False
        if attendance:
            is_checked_in = True
            is_checked_out = attendance.check_out_time is not None

        data = {
            'streak_info': streak_info,
            'is_checked_in': is_checked_in,
            'is_checked_out': is_checked_out,
            'member_id': member.id
        }
        return success_response("Member dashboard stats retrieved.", data=data)
