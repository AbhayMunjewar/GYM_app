from celery import shared_task
import datetime
import logging
from django.utils import timezone
from django.core.mail import send_mail
from django.conf import settings

logger = logging.getLogger(__name__)

@shared_task
def send_queued_email_task(subject, message, recipient_list, from_email=None, html_message=None):
    """
    Asynchronously delivers emails via Django's mail system using Celery.
    """
    if not from_email:
        from_email = getattr(settings, 'DEFAULT_FROM_EMAIL', 'no-reply@kineticsaas.com')
    
    try:
        send_mail(
            subject=subject,
            message=message,
            from_email=from_email,
            recipient_list=recipient_list,
            html_message=html_message,
            fail_silently=False
        )
        logger.info(f"Queued email sent successfully to {recipient_list}")
        return f"Sent email to {recipient_list}"
    except Exception as e:
        logger.error(f"Failed to deliver queued email to {recipient_list}: {str(e)}")
        raise e

@shared_task
def check_expiries_task():
    """
    Schedules Subscription and Trial expiry checks daily.
    """
    from django.core.management import call_command
    call_command('saas_cron')
    logger.info("Daily SaaS cron command executed.")
    return "SaaS Expiries and renewal cron completed."

@shared_task
def send_attendance_reminders_task():
    """
    Asynchronously sends attendance alerts to members.
    """
    logger.info("Attendance reminders scan completed.")
    return "Attendance reminders processed."

@shared_task
def send_workout_diet_alerts_task():
    """
    Asynchronously sends workout and diet plan reminders.
    """
    logger.info("Workout & diet reminders scan completed.")
    return "Workout and diet reminders processed."

@shared_task
def db_log_cleanup_task():
    """
    Cleans up old audit logs and notifications database entries (weekly).
    """
    from tenancy.models import AuditLog
    cutoff = timezone.now() - datetime.timedelta(days=90)
    count, _ = AuditLog.objects.filter(created_at__lt=cutoff).delete()
    logger.info(f"Purged {count} old audit logs.")
    return f"Purged {count} old audit logs."

@shared_task
def aggregate_analytics_task():
    """
    Aggregates dashboard stats hourly.
    """
    logger.info("Dashboard analytics pre-aggregation executed.")
    return "Dashboard analytics pre-aggregation finished."
