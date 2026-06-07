from django.test import TestCase
from django.utils import timezone
from gyms.models import Gym
from members.models import Member
from memberships.models import Membership, MembershipPlan
from accounts.models import User
from attendance.services import AttendanceService, StreakService
from attendance.models import Attendance
from datetime import timedelta

class AttendanceServiceTest(TestCase):
    def setUp(self):
        self.owner = User.objects.create_user(email="owner@test.com", password="pwd", role="OWNER")
        self.gym = Gym.objects.create(gym_name="Test Gym", owner=self.owner)
        self.member_user = User.objects.create_user(email="member@test.com", password="pwd", role="MEMBER")
        self.member = Member.objects.create(gym=self.gym, full_name="John Doe", email="member@test.com")
        self.plan = MembershipPlan.objects.create(gym=self.gym, plan_name="Monthly", price=50.0, duration_days=30)
        self.membership = Membership.objects.create(
            member=self.member, 
            membership_plan=self.plan,
            start_date=timezone.now().date(),
            end_date=timezone.now().date() + timedelta(days=30),
            status='ACTIVE'
        )

    def test_check_in_success(self):
        attendance = AttendanceService.check_in(self.member.id, self.gym)
        self.assertIsNotNone(attendance.id)
        self.assertEqual(attendance.attendance_status, 'PRESENT')

    def test_check_in_duplicate_prevented(self):
        AttendanceService.check_in(self.member.id, self.gym)
        with self.assertRaisesMessage(ValueError, "Member has already checked in today."):
            AttendanceService.check_in(self.member.id, self.gym)

    def test_check_out_success(self):
        AttendanceService.check_in(self.member.id, self.gym)
        attendance = AttendanceService.check_out(self.member.id, self.gym)
        self.assertIsNotNone(attendance.check_out_time)

    def test_check_out_without_check_in_fails(self):
        with self.assertRaisesMessage(ValueError, "No check-in record found for today."):
            AttendanceService.check_out(self.member.id, self.gym)

    def test_streak_calculation(self):
        # Create attendances for past 3 days
        today = timezone.localtime().date()
        Attendance.objects.create(member=self.member, gym=self.gym, membership=self.membership, attendance_date=today)
        Attendance.objects.create(member=self.member, gym=self.gym, membership=self.membership, attendance_date=today - timedelta(days=1))
        Attendance.objects.create(member=self.member, gym=self.gym, membership=self.membership, attendance_date=today - timedelta(days=2))
        
        streak_info = StreakService.calculate_streak(self.member.id)
        self.assertEqual(streak_info['current_streak'], 3)
        self.assertEqual(streak_info['longest_streak'], 3)
        self.assertEqual(streak_info['total_attendance'], 3)
