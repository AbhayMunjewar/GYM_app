from django.utils import timezone
from .models import GymPaymentSettings, Invoice, Payment
from accounts.models import Notification, User
from decimal import Decimal

class BillingService:

    @staticmethod
    def get_or_create_payment_settings(gym):
        settings, created = GymPaymentSettings.objects.get_or_create(gym=gym)
        return settings

    @staticmethod
    def update_payment_settings(gym, upi_id, upi_qr_code=None):
        settings = BillingService.get_or_create_payment_settings(gym)
        settings.upi_id = upi_id
        if upi_qr_code is not None:
            settings.upi_qr_code = upi_qr_code
        settings.save()
        return settings

    @staticmethod
    def generate_invoice(gym, member, amount, due_date, membership=None):
        amount = Decimal(str(amount))
        invoice = Invoice.objects.create(
            gym=gym,
            member=member,
            membership=membership,
            amount=amount,
            total_amount=amount,  # Simplification: total = amount for now
            due_date=due_date,
            status='PENDING'
        )
        
        member_user = User.objects.filter(email=member.email).first()
        if member_user:
            NotificationService.send_notification(
                user=member_user,
                title="New Invoice Generated",
                message=f"An invoice of {amount} has been generated. Due date: {due_date}."
            )
        return invoice

    @staticmethod
    def record_payment(invoice, amount_paid, payment_method, transaction_id=None, receipt_image=None):
        amount_paid = Decimal(str(amount_paid))
        
        # If paid by member via UPI, it needs acknowledgment. If paid by cash/owner, it's auto acknowledged.
        # For simplicity, if receipt_image is provided, it's pending. If not, it's acknowledged (recorded by owner).
        status = 'PENDING_ACK' if receipt_image else 'ACKNOWLEDGED'

        payment = Payment.objects.create(
            invoice=invoice,
            gym=invoice.gym,
            member=invoice.member,
            amount_paid=amount_paid,
            payment_method=payment_method,
            transaction_id=transaction_id,
            receipt_image=receipt_image,
            status=status
        )

        if status == 'ACKNOWLEDGED':
            BillingService._update_invoice_status(invoice)
        else:
            NotificationService.send_notification(
                user=invoice.gym.owner,
                title="Payment Receipt Submitted",
                message=f"Member {invoice.member.full_name} submitted a payment receipt for Invoice {str(invoice.id)[:8]}."
            )

        return payment

    @staticmethod
    def acknowledge_payment(payment):
        if payment.status != 'ACKNOWLEDGED':
            payment.status = 'ACKNOWLEDGED'
            payment.save()
            BillingService._update_invoice_status(payment.invoice)
            
            member_user = User.objects.filter(email=payment.member.email).first()
            if member_user:
                NotificationService.send_notification(
                    user=member_user,
                    title="Payment Acknowledged",
                    message=f"Your payment of {payment.amount_paid} has been acknowledged by the gym owner."
                )
        return payment
        
    @staticmethod
    def reject_payment(payment, reason=""):
        if payment.status != 'FAILED':
            payment.status = 'FAILED'
            payment.save()
            member_user = User.objects.filter(email=payment.member.email).first()
            if member_user:
                NotificationService.send_notification(
                    user=member_user,
                    title="Payment Rejected",
                    message=f"Your payment of {payment.amount_paid} was rejected. Reason: {reason}"
                )
        return payment

    @staticmethod
    def _update_invoice_status(invoice):
        # Calculate total paid from acknowledged payments
        total_paid = sum(p.amount_paid for p in invoice.payments.filter(status='ACKNOWLEDGED'))
        if total_paid >= invoice.total_amount:
            invoice.status = 'PAID'
        else:
            if invoice.due_date < timezone.now().date():
                invoice.status = 'OVERDUE'
            else:
                invoice.status = 'PENDING'
        invoice.save()

    @staticmethod
    def get_revenue_analytics(gym):
        from django.db.models import Sum
        today = timezone.now().date()
        first_day_of_month = today.replace(day=1)

        # Total Revenue (All time Acknowledged Payments)
        total_revenue = Payment.objects.filter(
            gym=gym, 
            status='ACKNOWLEDGED'
        ).aggregate(total=Sum('amount_paid'))['total'] or Decimal('0.00')

        # This month's revenue
        monthly_revenue = Payment.objects.filter(
            gym=gym, 
            status='ACKNOWLEDGED',
            payment_date__gte=first_day_of_month
        ).aggregate(total=Sum('amount_paid'))['total'] or Decimal('0.00')

        # Pending Dues (Sum of total_amount for PENDING/OVERDUE invoices minus their acknowledged payments)
        # Simplification: Just sum the unpaid amount of all pending/overdue invoices
        pending_invoices = Invoice.objects.filter(gym=gym, status__in=['PENDING', 'OVERDUE'])
        pending_dues = Decimal('0.00')
        for inv in pending_invoices:
            paid = sum(p.amount_paid for p in inv.payments.filter(status='ACKNOWLEDGED'))
            pending_dues += (inv.total_amount - paid)

        return {
            "total_revenue": str(total_revenue),
            "monthly_revenue": str(monthly_revenue),
            "pending_dues": str(pending_dues),
        }

class NotificationService:
    @staticmethod
    def send_notification(user, title, message):
        return Notification.objects.create(
            user=user,
            title=title,
            message=message
        )

    @staticmethod
    def get_unread_notifications(user):
        return Notification.objects.filter(user=user, is_read=False)

    @staticmethod
    def mark_as_read(notification_id, user):
        try:
            notif = Notification.objects.get(id=notification_id, user=user)
            notif.is_read = True
            notif.save()
            return True
        except Notification.DoesNotExist:
            return False
