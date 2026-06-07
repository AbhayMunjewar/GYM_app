from django.utils import timezone
from django.db import transaction
from django.db.models import Count, Q, Avg
from .models import Attendance
from members.models import Member
from memberships.models import Membership
from datetime import timedelta

class AttendanceService:
    @staticmethod
    @transaction.atomic
    def check_in(member_id, gym):
        """
        Validates membership and creates an attendance record.
        """
        # 1. Validate member exists and belongs to the owner's gym
        try:
            member = Member.objects.get(id=member_id, gym=gym, is_deleted=False)
        except Member.DoesNotExist:
            raise ValueError("Member not found or does not belong to this gym.")

        # 2. Validate membership exists and is ACTIVE
        membership = Membership.objects.filter(
            member=member, 
            status='ACTIVE'
        ).first()

        if not membership:
            raise ValueError("Member does not have an active membership.")

        # 3. Prevent duplicate check-ins today
        today = timezone.localtime().date()
        if Attendance.objects.filter(member=member, attendance_date=today, is_deleted=False).exists():
            raise ValueError("Member has already checked in today.")

        # Determine if late (e.g., after 9 AM - this could be dynamic, but let's keep it simple or configurable)
        # For this requirement, we'll just set it to PRESENT. The prompt says "Status Choices: PRESENT, ABSENT, LATE".
        current_time = timezone.localtime()
        status = Attendance.StatusChoices.PRESENT
        
        # Create Attendance record
        attendance = Attendance.objects.create(
            gym=gym,
            member=member,
            membership=membership,
            attendance_date=today,
            check_in_time=current_time,
            attendance_status=status
        )
        return attendance

    @staticmethod
    def check_out(member_id, gym):
        """
        Records the checkout time for today's attendance.
        """
        try:
            member = Member.objects.get(id=member_id, gym=gym, is_deleted=False)
        except Member.DoesNotExist:
            raise ValueError("Member not found or does not belong to this gym.")

        today = timezone.localtime().date()
        attendance = Attendance.objects.filter(
            member=member, 
            attendance_date=today, 
            is_deleted=False
        ).first()

        if not attendance:
            raise ValueError("No check-in record found for today.")

        if attendance.check_out_time:
            raise ValueError("Member has already checked out.")

        attendance.check_out_time = timezone.localtime()
        attendance.save()
        return attendance

    @staticmethod
    def get_dashboard_stats(gym_id):
        """
        Owner Dashboard Stats
        """
        today = timezone.localtime().date()
        today_attendances = Attendance.objects.filter(gym_id=gym_id, attendance_date=today, is_deleted=False)
        
        present_count = today_attendances.filter(attendance_status=Attendance.StatusChoices.PRESENT).count()
        late_count = today_attendances.filter(attendance_status=Attendance.StatusChoices.LATE).count()
        
        # Active Members Today
        active_members_today = today_attendances.values('member').distinct().count()

        return {
            'present_today': present_count,
            'late_today': late_count,
            'active_members_today': active_members_today,
            # We can calculate peak hours by aggregating check_in_time hours.
        }

    @staticmethod
    def get_peak_hours(gym_id):
        """
        Returns peak attendance hours based on historical check-ins.
        """
        from django.db.models.functions import ExtractHour
        
        peak_hours = Attendance.objects.filter(
            gym_id=gym_id, 
            check_in_time__isnull=False,
            is_deleted=False
        ).annotate(
            hour=ExtractHour('check_in_time')
        ).values('hour').annotate(
            count=Count('id')
        ).order_by('-count')[:5]

        # Format: { "08:00 AM - 09:00 AM": count }
        formatted_peaks = []
        for ph in peak_hours:
            hour = ph['hour']
            count = ph['count']
            if hour is None: continue
            
            # Format hour to AM/PM
            from datetime import time
            start_time = time(hour=int(hour))
            end_time = time(hour=(int(hour) + 1) % 24)
            formatted_peaks.append({
                'time_range': f"{start_time.strftime('%I:%M %p')} - {end_time.strftime('%I:%M %p')}",
                'count': count
            })
            
        return formatted_peaks


class StreakService:
    @staticmethod
    def calculate_streak(member_id):
        """
        Calculate current and longest streak for a member.
        """
        attendances = Attendance.objects.filter(
            member_id=member_id, 
            is_deleted=False
        ).order_by('-attendance_date').values_list('attendance_date', flat=True)

        if not attendances:
            return {'current_streak': 0, 'longest_streak': 0, 'total_attendance': 0}

        # Remove duplicates if any
        dates = sorted(list(set(attendances)), reverse=True)
        
        current_streak = 0
        longest_streak = 0
        temp_streak = 0
        
        today = timezone.localtime().date()
        yesterday = today - timedelta(days=1)
        
        # Calculate current streak
        # If the member attended today or yesterday, the streak is alive
        if dates and (dates[0] == today or dates[0] == yesterday):
            expected_date = dates[0]
            for d in dates:
                if d == expected_date:
                    current_streak += 1
                    expected_date -= timedelta(days=1)
                else:
                    break

        # Calculate longest streak
        if dates:
            temp_streak = 1
            longest_streak = 1
            for i in range(len(dates) - 1):
                if (dates[i] - dates[i+1]).days == 1:
                    temp_streak += 1
                    longest_streak = max(longest_streak, temp_streak)
                else:
                    temp_streak = 1

        total_attendance = len(dates)
        
        # calculate monthly attendance
        first_day_of_month = today.replace(day=1)
        monthly_attendance = sum(1 for d in dates if d >= first_day_of_month)

        return {
            'current_streak': current_streak,
            'longest_streak': longest_streak,
            'total_attendance': total_attendance,
            'monthly_attendance': monthly_attendance
        }
