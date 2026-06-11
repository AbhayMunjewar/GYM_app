import uuid
from django.db import models
from django.utils.translation import gettext_lazy as _
from gyms.models import Gym
from members.models import Member
from memberships.models import Membership

class GymPaymentSettings(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.OneToOneField(Gym, on_delete=models.CASCADE, related_name='payment_settings')
    upi_id = models.CharField(_('UPI ID'), max_length=255, blank=True, null=True)
    upi_qr_code = models.TextField(_('UPI QR Code Data/URL'), blank=True, null=True) # Storing base64 or URL
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'gym_payment_settings'

    def __str__(self):
        return f"{self.gym.gym_name} Payment Settings"


class Invoice(models.Model):
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('PAID', 'Paid'),
        ('OVERDUE', 'Overdue'),
        ('CANCELLED', 'Cancelled'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='invoices')
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='invoices')
    membership = models.ForeignKey(Membership, on_delete=models.SET_NULL, null=True, blank=True, related_name='invoices')
    
    amount = models.DecimalField(_('amount'), max_digits=10, decimal_places=2)
    tax_amount = models.DecimalField(_('tax amount'), max_digits=10, decimal_places=2, default=0.00)
    discount_amount = models.DecimalField(_('discount amount'), max_digits=10, decimal_places=2, default=0.00)
    total_amount = models.DecimalField(_('total amount'), max_digits=10, decimal_places=2)
    
    status = models.CharField(_('status'), max_length=20, choices=STATUS_CHOICES, default='PENDING')
    due_date = models.DateField(_('due date'))
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'billing_invoices'
        ordering = ['-created_at']

    def __str__(self):
        return f"INV-{str(self.id)[:8]} ({self.member.full_name})"


class Payment(models.Model):
    PAYMENT_METHOD_CHOICES = [
        ('CASH', 'Cash'),
        ('CARD', 'Card'),
        ('UPI', 'UPI'),
        ('BANK_TRANSFER', 'Bank Transfer'),
    ]
    
    STATUS_CHOICES = [
        ('PENDING_ACK', 'Pending Acknowledgment'),
        ('ACKNOWLEDGED', 'Acknowledged'),
        ('FAILED', 'Failed'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    invoice = models.ForeignKey(Invoice, on_delete=models.CASCADE, related_name='payments')
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='payments')
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='payments')
    
    amount_paid = models.DecimalField(_('amount paid'), max_digits=10, decimal_places=2)
    payment_method = models.CharField(_('payment method'), max_length=20, choices=PAYMENT_METHOD_CHOICES)
    status = models.CharField(_('status'), max_length=20, choices=STATUS_CHOICES, default='ACKNOWLEDGED')
    
    transaction_id = models.CharField(_('transaction id'), max_length=255, blank=True, null=True)
    receipt_image = models.TextField(_('receipt image'), blank=True, null=True) # Storing base64 string for simplicity or URL
    
    payment_date = models.DateTimeField(_('payment date'), auto_now_add=True)
    notes = models.TextField(_('notes'), blank=True, null=True)

    class Meta:
        db_table = 'billing_payments'
        ordering = ['-payment_date']

    def __str__(self):
        return f"PAY-{str(self.id)[:8]} ({self.amount_paid})"
