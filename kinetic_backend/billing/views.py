from rest_framework import status, generics, filters
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django_filters.rest_framework import DjangoFilterBackend
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from gyms.models import Gym
from members.models import Member

from .models import GymPaymentSettings, Invoice, Payment
from .serializers import (
    GymPaymentSettingsSerializer, InvoiceSerializer, PaymentSerializer,
    RecordPaymentSerializer, AcknowledgePaymentSerializer
)
from .services import BillingService
from notifications.services import NotificationService
from core.permissions import IsGymOwner

def get_gym_for_owner(user):
    return Gym.objects.filter(owner=user).first()

def get_member_for_user(user):
    return Member.objects.filter(email=user.email).first()

# ==========================================
# PAYMENT SETTINGS (Owner Only)
# ==========================================
class GymPaymentSettingsView(APIView):
    def get_permissions(self):
        if self.request.method in ['GET', 'HEAD', 'OPTIONS']:
            return [IsAuthenticated()]
        return [IsAuthenticated(), IsGymOwner()]

    @swagger_auto_schema(operation_summary="Get Gym Payment Settings", responses={200: GymPaymentSettingsSerializer})
    def get(self, request):
        if request.user.role == 'OWNER':
            gym = get_gym_for_owner(request.user)
        elif request.user.role == 'MEMBER':
            member = get_member_for_user(request.user)
            gym = member.gym if member else None
        else:
            gym = None

        if not gym: 
            return Response({'success': False, 'message': 'Gym not found'}, status=404)
            
        settings = BillingService.get_or_create_payment_settings(gym)
        return Response({'success': True, 'data': GymPaymentSettingsSerializer(settings).data})

    @swagger_auto_schema(operation_summary="Update Gym Payment Settings", request_body=GymPaymentSettingsSerializer)
    def patch(self, request):
        gym = get_gym_for_owner(request.user)
        if not gym: return Response({'success': False, 'message': 'Gym not found'}, status=404)
        
        upi_id = request.data.get('upi_id')
        upi_qr_code = request.data.get('upi_qr_code')
        
        settings = BillingService.update_payment_settings(gym, upi_id, upi_qr_code)
        return Response({'success': True, 'data': GymPaymentSettingsSerializer(settings).data})


# ==========================================
# INVOICES
# ==========================================
class InvoiceListCreateView(generics.ListCreateAPIView):
    serializer_class = InvoiceSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'member_id']
    search_fields = ['member__full_name']
    ordering_fields = ['created_at', 'due_date', 'total_amount']

    def get_queryset(self):
        if self.request.user.role == 'OWNER':
            gym = get_gym_for_owner(self.request.user)
            return Invoice.objects.filter(gym=gym)
        elif self.request.user.role == 'MEMBER':
            member = get_member_for_user(self.request.user)
            return Invoice.objects.filter(member=member) if member else Invoice.objects.none()
        return Invoice.objects.none()

    def perform_create(self, serializer):
        gym = get_gym_for_owner(self.request.user)
        if not gym: raise serializers.ValidationError("Only Gym Owner can create invoices manually here.")
        # We manually call the service in the view, overriding standard perform_create
        member = serializer.validated_data.get('member')
        amount = serializer.validated_data.get('amount')
        due_date = serializer.validated_data.get('due_date')
        membership = serializer.validated_data.get('membership')
        BillingService.generate_invoice(gym, member, amount, due_date, membership)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return Response({"success": True, "message": "Invoice created successfully"}, status=status.HTTP_201_CREATED)


class InvoiceDetailView(generics.RetrieveAPIView):
    serializer_class = InvoiceSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        if self.request.user.role == 'OWNER':
            gym = get_gym_for_owner(self.request.user)
            return Invoice.objects.filter(gym=gym)
        elif self.request.user.role == 'MEMBER':
            member = get_member_for_user(self.request.user)
            return Invoice.objects.filter(member=member) if member else Invoice.objects.none()
        return Invoice.objects.none()


# ==========================================
# PAYMENTS
# ==========================================
class PaymentListView(generics.ListAPIView):
    serializer_class = PaymentSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['status', 'payment_method', 'invoice_id']
    search_fields = ['member__full_name', 'transaction_id']

    def get_queryset(self):
        if self.request.user.role == 'OWNER':
            gym = get_gym_for_owner(self.request.user)
            return Payment.objects.filter(gym=gym)
        elif self.request.user.role == 'MEMBER':
            member = get_member_for_user(self.request.user)
            return Payment.objects.filter(member=member) if member else Payment.objects.none()
        return Payment.objects.none()


class RecordPaymentView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(operation_summary="Record Payment / Submit Receipt", request_body=RecordPaymentSerializer)
    def post(self, request):
        serializer = RecordPaymentSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({"success": False, "errors": serializer.errors}, status=400)

        invoice_id = serializer.validated_data['invoice_id']
        invoice = get_object_or_404(Invoice, id=invoice_id)
        
        # Validation checks
        if request.user.role == 'MEMBER':
            member = get_member_for_user(request.user)
            if invoice.member != member:
                return Response({"success": False, "message": "Unauthorized invoice access"}, status=403)
        elif request.user.role == 'OWNER':
            gym = get_gym_for_owner(request.user)
            if invoice.gym != gym:
                return Response({"success": False, "message": "Unauthorized invoice access"}, status=403)

        payment = BillingService.record_payment(
            invoice=invoice,
            amount_paid=serializer.validated_data['amount_paid'],
            payment_method=serializer.validated_data['payment_method'],
            transaction_id=serializer.validated_data.get('transaction_id'),
            receipt_image=serializer.validated_data.get('receipt_image')
        )

        return Response({
            "success": True, 
            "message": "Payment recorded successfully", 
            "data": PaymentSerializer(payment).data
        }, status=201)


class AcknowledgePaymentView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    @swagger_auto_schema(operation_summary="Acknowledge or Reject Receipt", request_body=AcknowledgePaymentSerializer)
    def post(self, request, payment_id):
        gym = get_gym_for_owner(request.user)
        payment = get_object_or_404(Payment, id=payment_id, gym=gym)

        serializer = AcknowledgePaymentSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({"success": False, "errors": serializer.errors}, status=400)

        action = serializer.validated_data['action']
        if action == 'ACKNOWLEDGE':
            BillingService.acknowledge_payment(payment)
            return Response({"success": True, "message": "Payment acknowledged."})
        elif action == 'REJECT':
            reason = serializer.validated_data.get('reason', '')
            BillingService.reject_payment(payment, reason)
            return Response({"success": True, "message": "Payment rejected."})

# ==========================================
# ANALYTICS
# ==========================================
class RevenueAnalyticsView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    @swagger_auto_schema(operation_summary="Get Billing Analytics")
    def get(self, request):
        gym = get_gym_for_owner(request.user)
        if not gym: return Response({'success': False, 'message': 'Gym not found'}, status=404)
        
        analytics = BillingService.get_revenue_analytics(gym)
        return Response({'success': True, 'data': analytics})



