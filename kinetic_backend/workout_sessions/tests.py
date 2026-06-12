from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from django.urls import reverse
from datetime import date, timedelta
from accounts.models import User, UserRole
from gyms.models import Gym
from members.models import Member
from trainers.models import Trainer
from .models import WorkoutSession, SessionBooking

class WorkoutSessionTests(TestCase):
    def setUp(self):
        self.client = APIClient()

        # Create Owner
        self.owner = User.objects.create_user(
            email='owner@test.com',
            password='password123',
            full_name='Gym Owner',
            role=UserRole.OWNER,
            is_verified=True,
            is_active=True
        )

        # Create Gym
        self.gym = Gym.objects.create(
            owner=self.owner,
            gym_name='Titan Gym',
            address='123 Power St',
            city='Gainsville',
            state='Fitness',
            pincode='123456',
            contact_number='1234567890',
            email='titan@gym.com'
        )

        # Create Trainer
        self.trainer_user = User.objects.create_user(
            email='trainer@test.com',
            password='password123',
            full_name='Trainer Tom',
            role=UserRole.TRAINER,
            is_verified=True,
            is_active=True
        )
        self.trainer = Trainer.objects.create(
            user=self.trainer_user,
            gym=self.gym,
            employee_id='EMP111',
            joining_date=date.today(),
            status='ACTIVE'
        )

        # Create Member
        self.member = Member.objects.create(
            gym=self.gym,
            full_name='John Doe',
            email='member@test.com',
            phone_number='9998887776',
            status='ACTIVE'
        )

        # Create another Owner & Gym & Trainer for cross-gym isolation tests
        self.other_owner = User.objects.create_user(
            email='other_owner@test.com',
            password='password123',
            full_name='Other Owner',
            role=UserRole.OWNER,
            is_verified=True,
            is_active=True
        )
        self.other_gym = Gym.objects.create(
            owner=self.other_owner,
            gym_name='Other Gym',
            address='456 Route St',
            city='Other City',
            state='Other State',
            pincode='654321',
            contact_number='0987654321',
            email='other@gym.com'
        )
        self.other_trainer_user = User.objects.create_user(
            email='other_trainer@test.com',
            password='password123',
            full_name='Trainer Jerry',
            role=UserRole.TRAINER,
            is_verified=True,
            is_active=True
        )
        self.other_trainer = Trainer.objects.create(
            user=self.other_trainer_user,
            gym=self.other_gym,
            employee_id='EMP222',
            joining_date=date.today(),
            status='ACTIVE'
        )
        self.other_member = Member.objects.create(
            gym=self.other_gym,
            full_name='Jerry Rice',
            email='other_member@test.com',
            phone_number='9996667776',
            status='ACTIVE'
        )

    def get_jwt(self, user):
        response = self.client.post(reverse('auth_login'), {
            'email': user.email,
            'password': 'password123'
        })
        return response.data['data']['access']

    def test_owner_can_create_session(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        payload = {
            'gym': str(self.gym.id),
            'trainer': str(self.trainer.id),
            'title': 'Morning Crossfit',
            'description': 'High intensity workout',
            'session_date': str(date.today()),
            'start_time': '08:00',
            'end_time': '09:00',
            'max_capacity': 5
        }
        
        response = self.client.post(reverse('session-list-create'), payload)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(WorkoutSession.objects.count(), 1)
        self.assertEqual(WorkoutSession.objects.first().title, 'Morning Crossfit')

    def test_trainer_conflict_causes_error(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        # 1. Create first session (08:00 to 09:00)
        WorkoutSession.objects.create(
            gym=self.gym,
            trainer=self.trainer,
            title='Session 1',
            session_date=date.today(),
            start_time='08:00',
            end_time='09:00',
            max_capacity=5
        )

        # 2. Attempt to create overlapping session (08:30 to 09:30) for same trainer
        payload = {
            'gym': str(self.gym.id),
            'trainer': str(self.trainer.id),
            'title': 'Session 2 Overlap',
            'session_date': str(date.today()),
            'start_time': '08:30',
            'end_time': '09:30',
            'max_capacity': 5
        }
        response = self.client.post(reverse('session-list-create'), payload)
        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)
        self.assertEqual(WorkoutSession.objects.count(), 1)  # No new session created

    def test_cross_gym_creation_denied(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        # Owner attempts to create session for other gym
        payload = {
            'gym': str(self.other_gym.id),
            'trainer': str(self.other_trainer.id),
            'title': 'Unauthorized',
            'session_date': str(date.today()),
            'start_time': '10:00',
            'end_time': '11:00',
            'max_capacity': 5
        }
        response = self.client.post(reverse('session-list-create'), payload)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_owner_can_soft_delete_session(self):
        session = WorkoutSession.objects.create(
            gym=self.gym,
            trainer=self.trainer,
            title='Morning Yoga',
            session_date=date.today(),
            start_time='07:00',
            end_time='08:00',
            max_capacity=5
        )

        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)

        response = self.client.delete(reverse('session-detail', args=[session.id]))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        session.refresh_from_db()
        self.assertTrue(session.is_deleted)

    def test_member_booking_capacity_and_uniqueness(self):
        session = WorkoutSession.objects.create(
            gym=self.gym,
            trainer=self.trainer,
            title='Morning Spinning',
            session_date=date.today(),
            start_time='07:00',
            end_time='08:00',
            max_capacity=1  # Max capacity is 1
        )

        # 1. Book first member (success)
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)

        payload = {
            'session': str(session.id),
            'member': self.member.id
        }
        response = self.client.post(reverse('booking-list-create'), payload)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(SessionBooking.objects.count(), 1)

        # 2. Book same member again (duplicate error)
        response = self.client.post(reverse('booking-list-create'), payload)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

        # 3. Create another member and attempt to book (max capacity reached error)
        another_member = Member.objects.create(
            gym=self.gym,
            full_name='Alice Smith',
            email='alice@test.com',
            phone_number='9994447776',
            status='ACTIVE'
        )
        payload_full = {
            'session': str(session.id),
            'member': another_member.id
        }
        response = self.client.post(reverse('booking-list-create'), payload_full)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("maximum capacity", str(response.data['errors']))

    def test_cancel_booking(self):
        session = WorkoutSession.objects.create(
            gym=self.gym,
            trainer=self.trainer,
            title='Pilates',
            session_date=date.today(),
            start_time='12:00',
            end_time='13:00',
            max_capacity=5
        )
        booking = SessionBooking.objects.create(
            session=session,
            member=self.member,
            status='booked'
        )

        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)

        response = self.client.put(reverse('booking-cancel', args=[booking.id]))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        booking.refresh_from_db()
        self.assertEqual(booking.status, 'cancelled')
