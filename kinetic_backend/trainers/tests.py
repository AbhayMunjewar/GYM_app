from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from django.urls import reverse
from datetime import date, timedelta
from accounts.models import User, UserRole
from gyms.models import Gym
from members.models import Member
from memberships.models import Membership, MembershipPlan
from .models import Trainer, TrainerAssignment, TrainerAuditLog, TrainerStatus, AssignmentStatus

class TrainerTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        
        # Create Owner
        self.owner = User.objects.create_user(
            email='owner@test.com',
            password='password123',
            full_name='Test Owner',
            role=UserRole.OWNER,
            is_verified=True,
            is_active=True
        )
        
        # Create Gym
        self.gym = Gym.objects.create(
            owner=self.owner,
            gym_name='Test Gym',
            address='123 Test St',
            city='Test City',
            state='Test State',
            pincode='123456',
            contact_number='1234567890',
            email='gym@test.com'
        )

        # Create another Owner & Gym for cross-gym validation
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
            address='456 Other St',
            city='Other City',
            state='Other State',
            pincode='654321',
            contact_number='0987654321',
            email='othergym@test.com'
        )

        # Create Member under Gym
        self.member = Member.objects.create(
            gym=self.gym,
            full_name='Test Member',
            email='member@test.com',
            phone_number='1122334455',
            status='ACTIVE'
        )

        # Create Member under other gym
        self.other_member = Member.objects.create(
            gym=self.other_gym,
            full_name='Other Member',
            email='other_member@test.com',
            phone_number='9988776655',
            status='ACTIVE'
        )

        # Create Member User account
        self.member_user = User.objects.create_user(
            email='member@test.com',
            password='password123',
            full_name='Test Member',
            role=UserRole.MEMBER,
            is_verified=True,
            is_active=True
        )

        self.trainer_payload = {
            'email': 'trainer_new@test.com',
            'password': 'password123',
            'full_name': 'New Trainer',
            'phone_number': '9876543210',
            'employee_id': 'EMP007',
            'specialization': 'Bodybuilding',
            'experience_years': 4,
            'certifications': 'ISSA, CPR',
            'joining_date': '2026-06-12',
            'salary': '45000.00',
            'bio': 'Trainer bio...',
            'profile_image': 'image_url',
            'status': 'ACTIVE'
        }

    def get_jwt(self, user):
        response = self.client.post(reverse('auth_login'), {
            'email': user.email,
            'password': 'password123'
        })
        return response.data['data']['access']

    def test_owner_can_create_trainer(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        response = self.client.post(reverse('trainer-list-create'), self.trainer_payload)
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Trainer.objects.count(), 1)
        trainer = Trainer.objects.first()
        self.assertEqual(trainer.employee_id, 'EMP007')
        self.assertEqual(trainer.user.email, 'trainer_new@test.com')
        self.assertEqual(trainer.user.role, 'TRAINER')
        self.assertEqual(TrainerAuditLog.objects.count(), 1)

    def test_owner_cannot_duplicate_employee_id(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        # Create first
        self.client.post(reverse('trainer-list-create'), self.trainer_payload)
        # Create second with same employee_id
        payload = self.trainer_payload.copy()
        payload['email'] = 'trainer_diff@test.com'
        response = self.client.post(reverse('trainer-list-create'), payload)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_trainer_or_member_cannot_create_trainer(self):
        token = self.get_jwt(self.member_user)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        response = self.client.post(reverse('trainer-list-create'), self.trainer_payload)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_owner_can_update_trainer(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        create_res = self.client.post(reverse('trainer-list-create'), self.trainer_payload)
        trainer_id = create_res.data['data']['id']

        response = self.client.patch(
            reverse('trainer-detail', args=[trainer_id]),
            {'experience_years': 6, 'full_name': 'Updated Trainer Name'}
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        trainer = Trainer.objects.get(id=trainer_id)
        self.assertEqual(trainer.experience_years, 6)
        self.assertEqual(trainer.user.full_name, 'Updated Trainer Name')

    def test_owner_can_delete_trainer(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        create_res = self.client.post(reverse('trainer-list-create'), self.trainer_payload)
        trainer_id = create_res.data['data']['id']

        response = self.client.delete(reverse('trainer-detail', args=[trainer_id]))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        trainer = Trainer.objects.get(id=trainer_id)
        self.assertTrue(trainer.is_deleted)
        self.assertFalse(trainer.user.is_active)

    def test_owner_can_assign_trainer(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        # Create trainer
        create_res = self.client.post(reverse('trainer-list-create'), self.trainer_payload)
        trainer_id = create_res.data['data']['id']

        # Assign
        response = self.client.post(reverse('assignment-list-create'), {
            'trainer_id': trainer_id,
            'member_id': str(self.member.id)
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(TrainerAssignment.objects.count(), 1)
        self.assertEqual(TrainerAssignment.objects.first().status, AssignmentStatus.ACTIVE)

    def test_prevent_cross_gym_assignment(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        # Create trainer
        create_res = self.client.post(reverse('trainer-list-create'), self.trainer_payload)
        trainer_id = create_res.data['data']['id']

        # Try to assign member from other gym
        response = self.client.post(reverse('assignment-list-create'), {
            'trainer_id': trainer_id,
            'member_id': str(self.other_member.id)
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_prevent_inactive_trainer_assignment(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        # Create trainer and update status to INACTIVE
        payload = self.trainer_payload.copy()
        payload['status'] = 'INACTIVE'
        create_res = self.client.post(reverse('trainer-list-create'), payload)
        trainer_id = create_res.data['data']['id']

        # Assign
        response = self.client.post(reverse('assignment-list-create'), {
            'trainer_id': trainer_id,
            'member_id': str(self.member.id)
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_prevent_duplicate_active_assignment(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        create_res = self.client.post(reverse('trainer-list-create'), self.trainer_payload)
        trainer_id = create_res.data['data']['id']

        # First assignment
        self.client.post(reverse('assignment-list-create'), {
            'trainer_id': trainer_id,
            'member_id': str(self.member.id)
        })
        # Duplicate assignment
        response = self.client.post(reverse('assignment-list-create'), {
            'trainer_id': trainer_id,
            'member_id': str(self.member.id)
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_trainer_dashboard_stats(self):
        # Create a trainer user
        trainer_user = User.objects.create_user(
            email='trainer_dash@test.com',
            password='password123',
            full_name='Dash Trainer',
            role=UserRole.TRAINER,
            is_verified=True,
            is_active=True
        )
        trainer = Trainer.objects.create(
            user=trainer_user,
            gym=self.gym,
            employee_id='EMP999',
            joining_date=date.today(),
            status='ACTIVE'
        )
        # Assign member
        TrainerAssignment.objects.create(
            trainer=trainer,
            member=self.member,
            assigned_date=date.today(),
            assigned_by=self.owner,
            status=AssignmentStatus.ACTIVE
        )

        token = self.get_jwt(trainer_user)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        response = self.client.get(reverse('trainer-dashboard'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['assigned_members_count'], 1)
        self.assertEqual(response.data['data']['active_members_count'], 1)
