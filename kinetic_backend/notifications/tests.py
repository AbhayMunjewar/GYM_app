from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from accounts.models import User
from gyms.models import Gym
from .models import Notification, DeviceToken, NotificationType, NotificationPriority
from .services import NotificationService

class NotificationTests(APITestCase):

    def setUp(self):
        # Create user
        self.user = User.objects.create_user(email='user@test.com', password='password123', full_name='Test User')
        
        # Create mock notifications
        self.notif1 = Notification.objects.create(
            recipient=self.user,
            title='Test 1',
            message='Message 1',
            notification_type=NotificationType.SYSTEM,
            priority=NotificationPriority.LOW
        )
        self.notif2 = Notification.objects.create(
            recipient=self.user,
            title='Test 2',
            message='Message 2',
            notification_type=NotificationType.MEMBERSHIP,
            priority=NotificationPriority.HIGH
        )
        
        self.url = reverse('notifications-list')
        self.client.force_authenticate(user=self.user)

    def test_list_notifications(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Should be paginated (so check results)
        self.assertEqual(len(response.data['results']), 2)

    def test_filter_notifications(self):
        response = self.client.get(self.url, {'is_read': 'False'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 2)

    def test_mark_as_read(self):
        read_url = reverse('notifications-read', kwargs={'pk': self.notif1.id})
        response = self.client.patch(read_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.notif1.refresh_from_db()
        self.assertTrue(self.notif1.is_read)

    def test_mark_all_read(self):
        read_all_url = reverse('notifications-mark-all-read')
        response = self.client.patch(read_all_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.notif1.refresh_from_db()
        self.notif2.refresh_from_db()
        self.assertTrue(self.notif1.is_read)
        self.assertTrue(self.notif2.is_read)

class NotificationServiceTests(APITestCase):
    
    def setUp(self):
        self.user = User.objects.create_user(email='user@test.com', password='password123', full_name='Test User')

    def test_create_notification(self):
        notif = NotificationService.create_notification(
            recipient=self.user,
            title="Service Test",
            message="Testing service",
            notification_type=NotificationType.WORKOUT
        )
        self.assertEqual(notif.recipient, self.user)
        self.assertEqual(notif.title, "Service Test")
        self.assertFalse(notif.is_read)

    def test_device_token_creation(self):
        self.client.force_authenticate(user=self.user)
        url = reverse('device-tokens-list')
        data = {
            'fcm_token': 'test_token_xyz',
            'device_type': 'ANDROID'
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(DeviceToken.objects.filter(fcm_token='test_token_xyz').exists())
