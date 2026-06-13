from rest_framework import serializers
from .models import GymPaymentSettings, Invoice, Payment


class GymPaymentSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = GymPaymentSettings
        fields = ['id', 'upi_id', 'upi_qr_code', 'created_at']
        read_only_fields = ['id', 'created_at']

class InvoiceSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    membership_name = serializers.CharField(source='membership.plan_name', read_only=True, allow_null=True)

    class Meta:
        model = Invoice
        fields = [
            'id', 'member', 'member_name', 'membership', 'membership_name', 
            'amount', 'tax_amount', 'discount_amount', 'total_amount', 
            'status', 'due_date', 'created_at'
        ]
        read_only_fields = ['id', 'created_at', 'status', 'total_amount']

class PaymentSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)

    class Meta:
        model = Payment
        fields = [
            'id', 'invoice', 'member', 'member_name', 'amount_paid', 
            'payment_method', 'status', 'transaction_id', 'receipt_image', 
            'payment_date', 'notes'
        ]
        read_only_fields = ['id', 'payment_date', 'status']

class RecordPaymentSerializer(serializers.Serializer):
    invoice_id = serializers.UUIDField()
    amount_paid = serializers.DecimalField(max_digits=10, decimal_places=2)
    payment_method = serializers.ChoiceField(choices=Payment.PAYMENT_METHOD_CHOICES)
    transaction_id = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    receipt_image = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    notes = serializers.CharField(required=False, allow_blank=True, allow_null=True)

class AcknowledgePaymentSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=['ACKNOWLEDGE', 'REJECT'])
    reason = serializers.CharField(required=False, allow_blank=True)

