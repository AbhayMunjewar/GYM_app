import logging
from datetime import timedelta
from django.utils import timezone
from memberships.models import Membership
from billing.models import Invoice
from workout_sessions.models import SessionBooking
from diets.models import DietPlan
from members.models import Member
from .services import NotificationService

logger = logging.getLogger(__name__)

# Note: In a production environment, these functions should be decorated with @shared_task from Celery.
# For now, they act as Django Management Commands / Cron endpoints.

def check_expiring_memberships():
    """
    Checks for memberships expiring in 7, 3, 1, and 0 days and sends reminders.
    """
    today = timezone.now().date()
    for days_left in [7, 3, 1, 0]:
        target_date = today + timedelta(days=days_left)
        expiring_memberships = Membership.objects.filter(end_date=target_date, status__in=['ACTIVE', 'EXPIRING'])
        
        for membership in expiring_memberships:
            NotificationService.send_membership_reminders(membership.member.user, days_left)
            logger.info(f"Sent {days_left} day expiry reminder to {membership.member.email}")

def check_pending_payments():
    """
    Checks for pending invoices and sends reminders.
    """
    pending_invoices = Invoice.objects.filter(status='PENDING', due_date__lte=timezone.now().date() + timedelta(days=3))
    for invoice in pending_invoices:
        NotificationService.send_payment_reminders(invoice.gym.owner, invoice.amount, "pending")
        logger.info(f"Sent payment reminder to {invoice.gym.owner.email} for {invoice.amount}")

def check_daily_workouts():
    """
    Sends upcoming workout reminders for today.
    """
    today = timezone.now().date()
    today_sessions = SessionBooking.objects.filter(session__date=today, status='CONFIRMED')
    for booking in today_sessions:
        if booking.member and booking.member.user:
            NotificationService.send_workout_reminders(booking.member.user, booking.session.title, "upcoming")
            logger.info(f"Sent upcoming workout reminder to {booking.member.email}")

def check_missed_attendance():
    """
    Scans for members who haven't badged in for 3+ days to send attendance reminders.
    """
    from attendance.models import AttendanceLog
    three_days_ago = timezone.now().date() - timedelta(days=3)
    
    # Find active members who haven't attended in the last 3 days
    members = Member.objects.filter(is_deleted=False)
    for member in members:
        if member.user:
            recent_attendance = AttendanceLog.objects.filter(member=member, check_in_time__gte=three_days_ago).exists()
            if not recent_attendance:
                NotificationService.send_attendance_reminders(member.user, days_missed=3)
                logger.info(f"Sent missed attendance reminder to {member.email}")
