import logging
from .models import Notification, DeviceToken, NotificationPriority, NotificationType

logger = logging.getLogger(__name__)

class NotificationService:
    @staticmethod
    def create_notification(recipient, title, message, notification_type=NotificationType.SYSTEM, priority=NotificationPriority.LOW, action_url=None, metadata=None):
        """
        Creates an in-app notification and attempts to send a push notification.
        """
        notification = Notification.objects.create(
            recipient=recipient,
            title=title,
            message=message,
            notification_type=notification_type,
            priority=priority,
            action_url=action_url,
            metadata=metadata
        )
        
        # Trigger FCM Push Notification
        NotificationService.send_push_notification(recipient, title, message, {"action_url": action_url, "type": notification_type})
        
        return notification

    @staticmethod
    def send_push_notification(user, title, body, data=None):
        """
        Sends an FCM push notification to all active devices of the user.
        """
        tokens = DeviceToken.objects.filter(user=user, is_active=True).values_list('fcm_token', flat=True)
        if not tokens:
            logger.debug(f"No active device tokens for user {user.email}")
            return
            
        logger.info(f"Mock sending FCM to {len(tokens)} devices for user {user.email}: {title}")
        # Placeholder for real Firebase Admin SDK integration
        # try:
        #     from firebase_admin import messaging
        #     message = messaging.MulticastMessage(
        #         notification=messaging.Notification(title=title, body=body),
        #         data=data,
        #         tokens=list(tokens),
        #     )
        #     response = messaging.send_multicast(message)
        # except Exception as e:
        #     logger.error(f"FCM Send Error: {e}")

    @staticmethod
    def mark_as_read(notification_id, user):
        """
        Marks a specific notification as read.
        """
        from django.utils import timezone
        try:
            notification = Notification.objects.get(id=notification_id, recipient=user)
            if not notification.is_read:
                notification.is_read = True
                notification.read_at = timezone.now()
                notification.save(update_fields=['is_read', 'read_at'])
            return notification
        except Notification.DoesNotExist:
            return None

    @staticmethod
    def bulk_mark_as_read(user):
        """
        Marks all unread notifications as read for a user.
        """
        from django.utils import timezone
        return Notification.objects.filter(recipient=user, is_read=False).update(is_read=True, read_at=timezone.now())

    # --- Domain Specific Reminders ---
    @staticmethod
    def send_membership_reminders(user, days_left):
        title = "Membership Expiring Soon"
        if days_left == 0:
            title = "Membership Expired"
            message = "Your membership expires today. Renew now to continue accessing the gym."
        else:
            message = f"Your membership expires in {days_left} days. Renew now."
            
        NotificationService.create_notification(
            recipient=user,
            title=title,
            message=message,
            notification_type=NotificationType.MEMBERSHIP,
            priority=NotificationPriority.HIGH
        )

    @staticmethod
    def send_payment_reminders(user, amount, status="pending"):
        title = "Payment Reminder"
        if status == "pending":
            message = f"You have a pending payment of {amount}. Please clear it at the earliest."
        elif status == "failed":
            title = "Payment Failed"
            message = f"Your recent payment of {amount} failed. Please try again."
        else:
            message = "Renew your membership to continue gym access."
            
        NotificationService.create_notification(
            recipient=user,
            title=title,
            message=message,
            notification_type=NotificationType.PAYMENT,
            priority=NotificationPriority.HIGH
        )

    @staticmethod
    def send_workout_reminders(user, workout_name, status="upcoming"):
        if status == "upcoming":
            title = "Today's Workout"
            message = f"Today's workout: {workout_name}. Let's crush it!"
        elif status == "missed":
            title = "Missed Workout"
            message = f"You missed your {workout_name} workout today. Consistency is key!"
        elif status == "completed":
            title = "Workout Completed!"
            message = f"Great job finishing {workout_name}!"
            
        NotificationService.create_notification(
            recipient=user,
            title=title,
            message=message,
            notification_type=NotificationType.WORKOUT,
            priority=NotificationPriority.MEDIUM
        )

    @staticmethod
    def send_diet_reminders(user, meal_name, status="upcoming"):
        if status == "upcoming":
            title = "Diet Reminder"
            message = f"It's time for {meal_name}. Stay on track!"
        elif status == "missed":
            title = "Missed Meal"
            message = f"You have not completed today's {meal_name}."
            
        NotificationService.create_notification(
            recipient=user,
            title=title,
            message=message,
            notification_type=NotificationType.DIET,
            priority=NotificationPriority.MEDIUM
        )

    @staticmethod
    def send_attendance_reminders(user, days_missed=0, streak=0):
        if streak > 0:
            title = "Awesome Streak!"
            message = f"Current attendance streak: {streak} days. Keep it up!"
            priority = NotificationPriority.LOW
        elif days_missed > 0:
            title = "We Miss You!"
            message = f"You missed the gym today. See you tomorrow?"
            priority = NotificationPriority.MEDIUM
            
        NotificationService.create_notification(
            recipient=user,
            title=title,
            message=message,
            notification_type=NotificationType.ATTENDANCE,
            priority=priority
        )

    @staticmethod
    def send_goal_notifications(user, goal_description, achieved=False):
        if achieved:
            title = "Goal Achieved!"
            message = f"Congratulations! You've achieved your goal: {goal_description}."
            priority = NotificationPriority.HIGH
        else:
            title = "Goal Progress Update"
            message = f"You are making progress towards: {goal_description}."
            priority = NotificationPriority.LOW
            
        NotificationService.create_notification(
            recipient=user,
            title=title,
            message=message,
            notification_type=NotificationType.GOAL,
            priority=priority
        )
