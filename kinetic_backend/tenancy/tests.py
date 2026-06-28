import datetime
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase
from django.utils import timezone

from tenancy.models import Tenant, SubscriptionPlan, Subscription, License, Invoice, FeatureFlag
from gyms.models import Gym, Branch
from members.models import Member
from trainers.models import Trainer

User = get_user_model()

class SaasTenancyTests(APITestCase):
    def setUp(self):
        # 1. Setup subscription plans
        self.starter_plan = SubscriptionPlan.objects.create(
            name='STARTER', max_members=2, max_trainers=1, max_branches=1,
            ai_features_access=False, community_access=True, analytics_access=False,
            price_monthly=1499.00, price_yearly=14990.00
        )
        self.pro_plan = SubscriptionPlan.objects.create(
            name='PROFESSIONAL', max_members=10, max_trainers=5, max_branches=3,
            ai_features_access=True, community_access=True, analytics_access=True,
            price_monthly=2999.00, price_yearly=29990.00
        )

        # 2. Setup Super Admin
        self.admin_user = User.objects.create_superuser(
            email='admin@saas.com', username='admin_user', password='password123', full_name='Super Admin'
        )

    def test_tenant_registration_onboarding(self):
        payload = {
            'email': 'new_owner@test.com',
            'password': 'password123',
            'full_name': 'Gym Owner X',
            'phone_number': '9876543210',
            'gym_name': 'Iron Paradise',
            'address': '123 Health Street',
            'city': 'Mumbai',
            'state': 'Maharashtra',
            'pincode': '400001',
            'contact_number': '022-123456'
        }

        response = self.client.post('/api/saas/register/', payload, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data['success'])
        self.assertIn('access', response.data['data'])

        # Verify database structures created
        owner = User.objects.get(email='new_owner@test.com')
        self.assertEqual(owner.role, 'OWNER')
        tenant = Tenant.objects.get(owner=owner)
        self.assertEqual(tenant.name, 'Iron Paradise Enterprise')
        
        # Verify Gym created
        gym = Gym.objects.get(tenant=tenant)
        self.assertEqual(gym.gym_name, 'Iron Paradise')

        # Verify trial subscription created
        sub = Subscription.objects.get(tenant=tenant)
        self.assertEqual(sub.status, 'TRIAL')
        self.assertEqual(sub.plan.name, 'STARTER')

    def test_tenant_isolation(self):
        # Create Owner A & Tenant A
        owner_a = User.objects.create_user(email='owner_a@gym.com', password='password123', role='OWNER', full_name='Owner A')
        tenant_a = Tenant.objects.create(name='Tenant A', owner=owner_a)
        gym_a = Gym.objects.create(gym_name='Gym A', owner=owner_a, tenant=tenant_a)
        sub_a = Subscription.objects.create(
            tenant=tenant_a, plan=self.starter_plan, status='ACTIVE',
            start_date=datetime.date.today(), end_date=datetime.date.today() + datetime.timedelta(days=30)
        )
        branch_a = Branch.objects.create(gym=gym_a, branch_name='Branch A')

        # Create Owner B & Tenant B
        owner_b = User.objects.create_user(email='owner_b@gym.com', password='password123', role='OWNER', full_name='Owner B')
        tenant_b = Tenant.objects.create(name='Tenant B', owner=owner_b)
        gym_b = Gym.objects.create(gym_name='Gym B', owner=owner_b, tenant=tenant_b)
        sub_b = Subscription.objects.create(
            tenant=tenant_b, plan=self.starter_plan, status='ACTIVE',
            start_date=datetime.date.today(), end_date=datetime.date.today() + datetime.timedelta(days=30)
        )
        branch_b = Branch.objects.create(gym=gym_b, branch_name='Branch B')

        # Authenticate Owner A
        login_res = self.client.post('/api/auth/login/', {"email": "owner_a@gym.com", "password": "password123"})
        token_a = login_res.data['data']['access']

        # Owner A queries branches -> should only see Branch A
        response = self.client.get('/api/saas/branches/', HTTP_AUTHORIZATION=f'Bearer {token_a}')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        branch_names = [b['branch_name'] for b in response.data]
        self.assertIn('Branch A', branch_names)
        self.assertNotIn('Branch B', branch_names)

    def test_subscription_limits_enforcement(self):
        # Create Tenant with 2 Members limit
        owner = User.objects.create_user(email='limit_owner@gym.com', password='password123', role='OWNER', full_name='Owner L')
        tenant = Tenant.objects.create(name='Limit Tenant', owner=owner)
        gym = Gym.objects.create(gym_name='Limit Gym', owner=owner, tenant=tenant)
        sub = Subscription.objects.create(
            tenant=tenant, plan=self.starter_plan, status='ACTIVE',
            start_date=datetime.date.today(), end_date=datetime.date.today() + datetime.timedelta(days=30)
        )

        # Authenticate
        login_res = self.client.post('/api/auth/login/', {"email": "limit_owner@gym.com", "password": "password123"})
        token = login_res.data['data']['access']

        # Add 2 members (Should succeed)
        m1 = Member.objects.create(gym=gym, full_name='Member One', email='m1@gym.com', phone_number='11')
        m2 = Member.objects.create(gym=gym, full_name='Member Two', email='m2@gym.com', phone_number='22')

        # Add 3rd member -> Should fail with 403 limit error
        payload = {
            'full_name': 'Member Three',
            'email': 'm3@gym.com',
            'phone_number': '33',
            'status': 'ACTIVE'
        }
        response = self.client.post('/api/members/', payload, format='json', HTTP_AUTHORIZATION=f'Bearer {token}')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('maximum limit', str(response.data['errors']))

    def test_expired_subscription_blocks_operational_requests(self):
        # Create Tenant with expired subscription
        owner = User.objects.create_user(email='exp_owner@gym.com', password='password123', role='OWNER', full_name='Owner E')
        tenant = Tenant.objects.create(name='Expired Tenant', owner=owner)
        gym = Gym.objects.create(gym_name='Expired Gym', owner=owner, tenant=tenant)
        
        # Set subscription expired in the past
        sub = Subscription.objects.create(
            tenant=tenant, plan=self.starter_plan, status='EXPIRED',
            start_date=datetime.date.today() - datetime.timedelta(days=40),
            end_date=datetime.date.today() - datetime.timedelta(days=10)
        )

        # Authenticate
        login_res = self.client.post('/api/auth/login/', {"email": "exp_owner@gym.com", "password": "password123"})
        token = login_res.data['data']['access']

        # Attempt to create a branch
        payload = {
            'branch_name': 'Failed Branch',
            'address': 'Add', 'city': 'City', 'state': 'State',
            'pincode': '123', 'contact_number': '123', 'email': 'fb@gym.com'
        }
        response = self.client.post('/api/saas/branches/', payload, format='json', HTTP_AUTHORIZATION=f'Bearer {token}')
        # Should be blocked by SubscriptionEnforcementMiddleware
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        import json
        resp_data = json.loads(response.content.decode('utf-8'))
        self.assertIn('expired', resp_data['message'].lower())

    def test_license_key_activation(self):
        owner = User.objects.create_user(email='license_owner@gym.com', password='password123', role='OWNER', full_name='Owner Lic')
        tenant = Tenant.objects.create(name='License Tenant', owner=owner)
        gym = Gym.objects.create(gym_name='License Gym', owner=owner, tenant=tenant)
        sub = Subscription.objects.create(
            tenant=tenant, plan=self.starter_plan, status='TRIAL',
            start_date=datetime.date.today(), end_date=datetime.date.today() + datetime.timedelta(days=14)
        )

        # Create License Key
        expiry = datetime.date.today() + datetime.timedelta(days=90)
        lic = License.objects.create(
            tenant=tenant, license_key='LIC-XYZ-123', activation_status=False, expiry_date=expiry
        )

        # Authenticate
        login_res = self.client.post('/api/auth/login/', {"email": "license_owner@gym.com", "password": "password123"})
        token = login_res.data['data']['access']

        # Activate
        payload = {'license_key': 'LIC-XYZ-123'}
        response = self.client.post('/api/saas/licenses/activate/', payload, format='json', HTTP_AUTHORIZATION=f'Bearer {token}')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])

        # Verify subscription was extended to the license key expiry
        sub.refresh_from_db()
        self.assertEqual(sub.status, 'ACTIVE')
        self.assertEqual(sub.end_date, expiry)

    def test_super_admin_endpoints(self):
        # Authenticate Super Admin
        login_res = self.client.post('/api/auth/login/', {"email": "admin@saas.com", "password": "password123"})
        admin_token = login_res.data['data']['access']

        # Get Admin platform stats
        response = self.client.get('/api/saas/admin/dashboard/', HTTP_AUTHORIZATION=f'Bearer {admin_token}')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('platform_stats', response.data['data'])

    def test_support_tickets_flow(self):
        # Setup Owner
        owner = User.objects.create_user(email='ticket_owner@gym.com', password='password123', role='OWNER', full_name='Owner T')
        tenant = Tenant.objects.create(name='Ticket Tenant', owner=owner)
        gym = Gym.objects.create(gym_name='Ticket Gym', owner=owner, tenant=tenant)
        sub = Subscription.objects.create(
            tenant=tenant, plan=self.starter_plan, status='ACTIVE',
            start_date=datetime.date.today(), end_date=datetime.date.today() + datetime.timedelta(days=30)
        )

        # Authenticate
        login_res = self.client.post('/api/auth/login/', {"email": "ticket_owner@gym.com", "password": "password123"})
        token = login_res.data['data']['access']

        # Create support ticket
        payload = {
            'subject': 'System down',
            'message': 'Cannot add trainers.'
        }
        response = self.client.post('/api/saas/support-tickets/', payload, format='json', HTTP_AUTHORIZATION=f'Bearer {token}')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        # Verify AuditLog logged
        from tenancy.models import AuditLog, SupportTicket
        self.assertTrue(AuditLog.objects.filter(action='SUPPORT_TICKET_CREATE', tenant=tenant).exists())
        self.assertTrue(SupportTicket.objects.filter(tenant=tenant, subject='System down').exists())

        # Resolve ticket as Super Admin
        admin_login = self.client.post('/api/auth/login/', {"email": "admin@saas.com", "password": "password123"})
        admin_token = admin_login.data['data']['access']

        ticket = SupportTicket.objects.get(tenant=tenant)
        payload_resolve = {'status': 'RESOLVED'}
        res = self.client.patch(f'/api/saas/admin/support-tickets/{ticket.id}/', payload_resolve, format='json', HTTP_AUTHORIZATION=f'Bearer {admin_token}')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        
        ticket.refresh_from_db()
        self.assertEqual(ticket.status, 'RESOLVED')
        self.assertTrue(AuditLog.objects.filter(action='SUPPORT_TICKET_RESOLVE', tenant=tenant).exists())

    def test_saas_cron_command(self):
        # Create expired TRIAL subscription
        owner = User.objects.create_user(email='cron_owner@gym.com', password='password123', role='OWNER', full_name='Owner C')
        tenant = Tenant.objects.create(name='Cron Tenant', owner=owner)
        gym = Gym.objects.create(gym_name='Cron Gym', owner=owner, tenant=tenant)
        sub = Subscription.objects.create(
            tenant=tenant, plan=self.starter_plan, status='TRIAL',
            start_date=datetime.date.today() - datetime.timedelta(days=20),
            end_date=datetime.date.today() - datetime.timedelta(days=6)
        )

        from django.core.management import call_command
        call_command('saas_cron')

        # Verify status transitions to EXPIRED
        sub.refresh_from_db()
        self.assertEqual(sub.status, 'EXPIRED')

        # Verify AuditLog logged
        from tenancy.models import AuditLog
        self.assertTrue(AuditLog.objects.filter(action='TRIAL_EXPIRED', tenant=tenant).exists())

    def test_sre_telemetry_health_endpoint(self):
        response = self.client.get('/api/health/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('cpu_usage_pct', response.data['data'])
        self.assertIn('memory_usage_pct', response.data['data'])
        self.assertIn('database_latency_ms', response.data['data'])

    def test_custom_exception_handler_format(self):
        # Access a protected endpoint without auth header to trigger 401 NotAuthenticated
        response = self.client.get('/api/saas/settings/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertFalse(response.data['success'])
        self.assertIn('errors', response.data)
        self.assertEqual(response.data['message'], "Authentication credentials were not provided.")

    def test_query_count_optimization(self):
        owner = User.objects.create_user(email='q_owner@gym.com', password='password123', role='OWNER', full_name='Owner Q')
        tenant = Tenant.objects.create(name='Q Tenant', owner=owner)
        gym = Gym.objects.create(gym_name='Q Gym', owner=owner, tenant=tenant)
        Subscription.objects.create(
            tenant=tenant, plan=self.starter_plan, status='ACTIVE',
            start_date=datetime.date.today(), end_date=datetime.date.today() + datetime.timedelta(days=30)
        )

        # Create members with active memberships
        from members.models import Member
        from memberships.models import MembershipPlan, MemberMembership
        plan = MembershipPlan.objects.create(gym=gym, plan_name='Starter', price=999, duration_days=30)
        
        for i in range(5):
            m = Member.objects.create(gym=gym, full_name=f'Member {i}', email=f'm{i}@gym.com')
            MemberMembership.objects.create(member=m, membership_plan=plan, status='ACTIVE', price_paid=999, start_date=datetime.date.today(), end_date=datetime.date.today() + datetime.timedelta(days=30))

        # Authenticate
        login_res = self.client.post('/api/auth/login/', {"email": "q_owner@gym.com", "password": "password123"})
        token = login_res.data['data']['access']

        # Assert database query count is optimized (fetching member list with memberships should not scale N+1)
        from django.db import connection
        from django.test.utils import CaptureQueriesContext

        with CaptureQueriesContext(connection) as ctx:
            response = self.client.get('/api/members/', HTTP_AUTHORIZATION=f'Bearer {token}')
            self.assertEqual(response.status_code, status.HTTP_200_OK)
            self.assertEqual(len(response.data['data']['results']), 5)
            
        # N+1 would cause >10 queries; prefetch should complete it in few queries
        self.assertLess(len(ctx.captured_queries), 8)
