import datetime
import uuid
import json
from rest_framework import views, status, viewsets, permissions
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import RefreshToken
from django.db import transaction
from django.utils import timezone
from rest_framework.exceptions import PermissionDenied, ValidationError

from core.responses import success_response, failure_response
from tenancy.models import Tenant, TenantSettings, SubscriptionPlan, Subscription, License, Invoice, BillingHistory, FeatureFlag, PlatformSettings, AuditLog, SupportTicket
from tenancy.serializers import (
    RegisterTenantSerializer, SubscriptionSerializer, SubscriptionPlanSerializer,
    LicenseSerializer, InvoiceSerializer, BillingHistorySerializer, FeatureFlagSerializer, BranchSerializer,
    PlatformSettingsSerializer, AuditLogSerializer, SupportTicketSerializer
)
from tenancy.permissions import IsSuperAdmin, TenantAccessPermission
from gyms.models import Gym, Branch
from members.models import Member
from trainers.models import Trainer

User = get_user_model()

class RegisterTenantView(views.APIView):
    """
    Onboarding flow API endpoint.
    Creates: Owner User, Tenant, Gym, default plans, and 14-day Free Trial.
    """
    permission_classes = [permissions.AllowAny]

    @transaction.atomic
    def post(self, request):
        serializer = RegisterTenantSerializer(data=request.data)
        if not serializer.is_valid():
            return failure_response("Validation error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data

        # Check user email duplicate
        if User.objects.filter(email=data['email']).exists():
            return failure_response("A user with this email already exists.", status_code=status.HTTP_400_BAD_REQUEST)

        # 1. Create Gym Owner User
        owner = User.objects.create_user(
            email=data['email'],
            password=data['password'],
            full_name=data['full_name'],
            phone_number=data['phone_number'],
            role='OWNER',
            is_active=True,
            is_verified=True
        )

        # 2. Create Tenant
        tenant = Tenant.objects.create(
            name=f"{data['gym_name']} Enterprise",
            owner=owner
        )

        # 3. Create Tenant Settings
        TenantSettings.objects.create(tenant=tenant)

        # 4. Create Gym
        gym = Gym.objects.create(
            gym_name=data['gym_name'],
            owner=owner,
            tenant=tenant,
            address=data['address'],
            city=data['city'],
            state=data['state'],
            pincode=data['pincode'],
            contact_number=data['contact_number'],
            email=data['email']
        )

        # 4b. Create Default Branch (Main Branch / Headquarters)
        Branch.objects.create(
            gym=gym,
            branch_name="Main Branch",
            address=data['address'],
            city=data['city'],
            state=data['state'],
            pincode=data['pincode'],
            contact_number=data['contact_number'],
            email=data['email']
        )

        # 4c. Log onboarding audit log
        AuditLog.objects.create(
            tenant=tenant,
            user=owner,
            action="TENANT_REGISTER",
            details_str=json.dumps({
                "gym_name": gym.gym_name,
                "owner_email": owner.email,
                "ip": request.META.get('REMOTE_ADDR')
            })
        )

        # 5. Populate Default Plans if they don't exist
        plans = {
            'FREE': {'max_members': 10, 'max_trainers': 1, 'max_branches': 1, 'price_monthly': 0.00, 'price_yearly': 0.00, 'ai': False, 'comm': False, 'anal': False},
            'STARTER': {'max_members': 50, 'max_trainers': 5, 'max_branches': 1, 'price_monthly': 1499.00, 'price_yearly': 14990.00, 'ai': False, 'comm': True, 'anal': False},
            'PROFESSIONAL': {'max_members': 200, 'max_trainers': 15, 'max_branches': 3, 'price_monthly': 2999.00, 'price_yearly': 29990.00, 'ai': True, 'comm': True, 'anal': True},
            'ENTERPRISE': {'max_members': 1000, 'max_trainers': 50, 'max_branches': 10, 'price_monthly': 5999.00, 'price_yearly': 59990.00, 'ai': True, 'comm': True, 'anal': True},
        }

        default_plan = None
        for plan_name, info in plans.items():
            plan_obj, _ = SubscriptionPlan.objects.get_or_create(
                name=plan_name,
                defaults={
                    'max_members': info['max_members'],
                    'max_trainers': info['max_trainers'],
                    'max_branches': info['max_branches'],
                    'ai_features_access': info['ai'],
                    'community_access': info['comm'],
                    'analytics_access': info['anal'],
                    'price_monthly': info['price_monthly'],
                    'price_yearly': info['price_yearly']
                }
            )
            if plan_name == 'STARTER':
                default_plan = plan_obj

        # 6. Create 14-day Free Trial Subscription
        today = datetime.date.today()
        trial_end = today + datetime.timedelta(days=14)
        Subscription.objects.create(
            tenant=tenant,
            plan=default_plan,
            status='TRIAL',
            start_date=today,
            end_date=trial_end,
            trial_start_date=today,
            trial_end_date=trial_end
        )

        # 7. Setup Default Feature Flags
        FeatureFlag.objects.create(tenant=tenant, feature_name='COMMUNITY', is_enabled=True)
        FeatureFlag.objects.create(tenant=tenant, feature_name='AI_GYM_BUDDY', is_enabled=False)
        FeatureFlag.objects.create(tenant=tenant, feature_name='ANALYTICS', is_enabled=False)

        # 8. Generate JWT Credentials for Login
        refresh = RefreshToken.for_user(owner)
        access_token = str(refresh.access_token)

        return success_response(
            message="Tenant & Gym onboarding completed successfully.",
            data={
                "access": access_token,
                "refresh": str(refresh),
                "user": {
                    "id": str(owner.id),
                    "full_name": owner.full_name,
                    "email": owner.email,
                    "role": owner.role
                },
                "gym": {
                    "id": str(gym.id),
                    "gym_name": gym.gym_name
                },
                "tenant": {
                    "id": str(tenant.id),
                    "name": tenant.name
                }
            },
            status_code=status.HTTP_201_CREATED
        )


class SubscriptionDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, TenantAccessPermission]

    def get(self, request):
        tenant = request.tenant
        subscription = getattr(tenant, 'subscription', None)
        if not subscription:
            return failure_response("No subscription found.", status_code=status.HTTP_404_NOT_FOUND)

        # Compute limits usage counters
        gym = request.gym
        members_count = Member.objects.filter(gym=gym, is_deleted=False).count()
        trainers_count = Trainer.objects.filter(gym=gym, is_deleted=False).count()
        branches_count = Branch.objects.filter(gym=gym, is_deleted=False).count()

        sub_data = SubscriptionSerializer(subscription).data
        limits = {
            'members': {
                'used': members_count,
                'max': subscription.plan.max_members,
            },
            'trainers': {
                'used': trainers_count,
                'max': subscription.plan.max_trainers,
            },
            'branches': {
                'used': branches_count,
                'max': subscription.plan.max_branches,
            }
        }

        # Available plans
        all_plans = SubscriptionPlan.objects.all().order_by('price_monthly')
        plans_data = SubscriptionPlanSerializer(all_plans, many=True).data

        return success_response(
            message="Subscription status retrieved",
            data={
                'subscription': sub_data,
                'limits': limits,
                'available_plans': plans_data
            }
        )


class PlanUpgradeView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, TenantAccessPermission]

    @transaction.atomic
    def post(self, request):
        plan_id = request.data.get('plan_id')
        billing_cycle = request.data.get('billing_cycle', 'monthly') # monthly / yearly
        
        try:
            plan = SubscriptionPlan.objects.get(id=plan_id)
        except (SubscriptionPlan.DoesNotExist, ValidationError):
            return failure_response("Invalid plan selected.", status_code=status.HTTP_400_BAD_REQUEST)

        tenant = request.tenant
        subscription = tenant.subscription

        price = plan.price_monthly if billing_cycle == 'monthly' else plan.price_yearly
        
        # Update Subscription dates
        today = datetime.date.today()
        duration_days = 30 if billing_cycle == 'monthly' else 365
        end_date = today + datetime.timedelta(days=duration_days)

        subscription.plan = plan
        subscription.status = 'ACTIVE'
        subscription.start_date = today
        subscription.end_date = end_date
        subscription.save()

        # Update Feature Flags based on Plan Capabilities
        FeatureFlag.objects.update_or_create(tenant=tenant, feature_name='AI_GYM_BUDDY', defaults={'is_enabled': plan.ai_features_access})
        FeatureFlag.objects.update_or_create(tenant=tenant, feature_name='ANALYTICS', defaults={'is_enabled': plan.analytics_access})
        FeatureFlag.objects.update_or_create(tenant=tenant, feature_name='COMMUNITY', defaults={'is_enabled': plan.community_access})

        # Create Invoice
        invoice_number = f"INV-{uuid.uuid4().hex[:8].upper()}"
        tax = price * 18 // 100 # 18% GST standard simulation
        invoice = Invoice.objects.create(
            tenant=tenant,
            invoice_number=invoice_number,
            amount=price + tax,
            tax=tax,
            due_date=today + datetime.timedelta(days=7),
            status='UNPAID'
        )

        # Log audit log
        AuditLog.objects.create(
            tenant=tenant,
            user=request.user,
            action="SUBSCRIPTION_UPGRADE",
            details_str=json.dumps({
                "plan_name": plan.name,
                "billing_cycle": billing_cycle,
                "price": float(price),
                "invoice_number": invoice_number
            })
        )

        return success_response(
            message="Plan upgraded. Please complete checkout invoice payment.",
            data={
                "subscription": SubscriptionSerializer(subscription).data,
                "invoice": InvoiceSerializer(invoice).data
            }
        )


class PlanDowngradeView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, TenantAccessPermission]

    @transaction.atomic
    def post(self, request):
        plan_id = request.data.get('plan_id')
        try:
            plan = SubscriptionPlan.objects.get(id=plan_id)
        except (SubscriptionPlan.DoesNotExist, ValidationError):
            return failure_response("Invalid plan selected.", status_code=status.HTTP_400_BAD_REQUEST)

        tenant = request.tenant
        subscription = tenant.subscription
        
        # Apply downgrade
        subscription.plan = plan
        subscription.save()

        # Re-align Feature Flags
        FeatureFlag.objects.update_or_create(tenant=tenant, feature_name='AI_GYM_BUDDY', defaults={'is_enabled': plan.ai_features_access})
        FeatureFlag.objects.update_or_create(tenant=tenant, feature_name='ANALYTICS', defaults={'is_enabled': plan.analytics_access})
        FeatureFlag.objects.update_or_create(tenant=tenant, feature_name='COMMUNITY', defaults={'is_enabled': plan.community_access})

        # Log audit log
        AuditLog.objects.create(
            tenant=tenant,
            user=request.user,
            action="SUBSCRIPTION_DOWNGRADE",
            details_str=json.dumps({
                "plan_name": plan.name
            })
        )

        return success_response(
            message="Plan downgraded successfully. Limit updates are now active.",
            data=SubscriptionSerializer(subscription).data
        )


class BillingInvoicesView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, TenantAccessPermission]

    def get(self, request):
        tenant = request.tenant
        invoices = Invoice.objects.filter(tenant=tenant).order_by('-created_at')
        histories = BillingHistory.objects.filter(tenant=tenant).order_by('-created_at')

        return success_response(
            message="Billing details retrieved",
            data={
                'invoices': InvoiceSerializer(invoices, many=True).data,
                'history': BillingHistorySerializer(histories, many=True).data
            }
        )


class PayInvoiceView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, TenantAccessPermission]

    @transaction.atomic
    def post(self, request):
        invoice_id = request.data.get('invoice_id')
        try:
            invoice = Invoice.objects.get(id=invoice_id, tenant=request.tenant)
        except Invoice.DoesNotExist:
            return failure_response("Invoice not found.", status_code=status.HTTP_404_NOT_FOUND)

        if invoice.status == 'PAID':
            return failure_response("Invoice is already paid.", status_code=status.HTTP_400_BAD_REQUEST)

        # 1. Update Invoice status
        invoice.status = 'PAID'
        invoice.save()

        # 2. Record Billing History
        ref_id = f"TXN-{uuid.uuid4().hex[:12].upper()}"
        BillingHistory.objects.create(
            tenant=request.tenant,
            invoice=invoice,
            amount=invoice.amount,
            payment_method='CARD_SIMULATED',
            transaction_reference=ref_id,
            status='SUCCESS'
        )

        # 3. Renew Subscription validity
        sub = request.tenant.subscription
        sub.status = 'ACTIVE'
        # Push dates
        sub.start_date = datetime.date.today()
        sub.end_date = sub.start_date + datetime.timedelta(days=30)
        sub.save()

        # Log audit log
        AuditLog.objects.create(
            tenant=request.tenant,
            user=request.user,
            action="BILLING_PAYMENT_SUCCESS",
            details_str=json.dumps({
                "invoice_id": str(invoice.id),
                "invoice_number": invoice.invoice_number,
                "amount": float(invoice.amount),
                "ref_id": ref_id
            })
        )

        return success_response(
            message="Payment checkout simulated successfully.",
            data={
                "invoice": InvoiceSerializer(invoice).data,
                "transaction_reference": ref_id
            }
        )


class LicenseView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, TenantAccessPermission]

    def get(self, request):
        licenses = License.objects.filter(tenant=request.tenant).order_by('-created_at')
        return success_response(
            message="Licenses retrieved",
            data=LicenseSerializer(licenses, many=True).data
        )


class LicenseActivateView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, TenantAccessPermission]

    @transaction.atomic
    def post(self, request):
        key = request.data.get('license_key')
        try:
            license_obj = License.objects.get(license_key=key, tenant=request.tenant)
        except License.DoesNotExist:
            return failure_response("Invalid license key.", status_code=status.HTTP_400_BAD_REQUEST)

        if license_obj.activation_status:
            return failure_response("License key is already activated.", status_code=status.HTTP_400_BAD_REQUEST)

        license_obj.activation_status = True
        license_obj.activated_at = timezone.now()
        license_obj.save()

        # Extend Subscription
        sub = request.tenant.subscription
        sub.status = 'ACTIVE'
        sub.end_date = license_obj.expiry_date
        sub.save()

        # Log audit log
        AuditLog.objects.create(
            tenant=request.tenant,
            user=request.user,
            action="LICENSE_ACTIVATE",
            details_str=json.dumps({
                "license_id": str(license_obj.id),
                "license_key": license_obj.license_key,
                "expiry_date": str(license_obj.expiry_date)
            })
        )

        return success_response(
            message="License key activated successfully! Subscription extended.",
            data=LicenseSerializer(license_obj).data
        )


class FeatureFlagsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, TenantAccessPermission]

    def get(self, request):
        flags = FeatureFlag.objects.filter(tenant=request.tenant)
        return success_response(
            message="Feature flags retrieved",
            data=FeatureFlagSerializer(flags, many=True).data
        )


class BranchViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, TenantAccessPermission]
    serializer_class = BranchSerializer

    def get_queryset(self):
        return Branch.objects.filter(gym=self.request.gym, is_deleted=False)

    @transaction.atomic
    def perform_create(self, serializer):
        gym = self.request.gym
        tenant = gym.tenant
        
        # Check branch subscription limit
        if tenant:
            subscription = getattr(tenant, 'subscription', None)
            if subscription:
                max_b = subscription.plan.max_branches
                current_b = Branch.objects.filter(gym=gym, is_deleted=False).count()
                if current_b >= max_b:
                    raise PermissionDenied(f"You have reached the maximum limit of {max_b} branches for your plan.")
        
        branch = serializer.save(gym=gym)
        # Log audit log
        AuditLog.objects.create(
            tenant=tenant,
            user=self.request.user,
            action="BRANCH_CREATE",
            details_str=json.dumps({
                "branch_id": str(branch.id),
                "branch_name": branch.branch_name
            })
        )

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.soft_delete()
        # Log audit log
        AuditLog.objects.create(
            tenant=request.tenant,
            user=request.user,
            action="BRANCH_DELETE",
            details_str=json.dumps({
                "branch_id": str(instance.id),
                "branch_name": instance.branch_name
            })
        )
        return success_response("Branch soft deleted successfully.")


class SuperAdminDashboardView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, IsSuperAdmin]

    def get(self, request):
        # Platform Telemetry Analytics
        total_gyms = Gym.objects.filter(is_deleted=False).count()
        total_tenants = Tenant.objects.filter(is_active=True).count()
        total_revenue = BillingHistory.objects.filter(status='SUCCESS').raw('SELECT id, SUM(amount) as total FROM billing_history')[0].total or 0.00
        
        # Subscription Plan breakdowns
        subs = Subscription.objects.all()
        breakdown = {
            'trial': subs.filter(status='TRIAL').count(),
            'active': subs.filter(status='ACTIVE').count(),
            'suspended': subs.filter(status='SUSPENDED').count(),
            'expired': subs.filter(status='EXPIRED').count(),
        }

        # Active Gyms List
        gyms = Gym.objects.filter(is_deleted=False).order_by('-created_at')
        gyms_list = []
        for g in gyms:
            sub = getattr(g.tenant, 'subscription', None) if g.tenant else None
            gyms_list.append({
                'id': str(g.id),
                'gym_name': g.gym_name,
                'city': g.city,
                'owner': g.owner.email,
                'plan': sub.plan.name if sub else 'None',
                'status': sub.status if sub else 'None'
            })

        return success_response(
            message="Super admin dashboard stats retrieved",
            data={
                'platform_stats': {
                    'total_gyms': total_gyms,
                    'total_tenants': total_tenants,
                    'total_revenue': float(total_revenue),
                },
                'subscription_breakdown': breakdown,
                'gyms': gyms_list
            }
        )


class SuperAdminLicenseGenerateView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, IsSuperAdmin]

    def post(self, request):
        tenant_id = request.data.get('tenant_id')
        expiry_days = int(request.data.get('expiry_days', 365))
        
        try:
            tenant = Tenant.objects.get(id=tenant_id)
        except Tenant.DoesNotExist:
            return failure_response("Tenant not found.", status_code=status.HTTP_404_NOT_FOUND)

        key = f"KEY-{uuid.uuid4().hex[:16].upper()}"
        expiry_date = datetime.date.today() + datetime.timedelta(days=expiry_days)

        license_obj = License.objects.create(
            tenant=tenant,
            license_key=key,
            activation_status=False,
            expiry_date=expiry_date
        )

        # Log audit log
        AuditLog.objects.create(
            user=request.user,
            action="LICENSE_GENERATE",
            details_str=json.dumps({
                "tenant_id": str(tenant.id),
                "license_key": key,
                "expiry_days": expiry_days
            })
        )

        return success_response(
            message="License key generated successfully.",
            data=LicenseSerializer(license_obj).data
        )


class SupportTicketViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, TenantAccessPermission]
    serializer_class = SupportTicketSerializer

    def get_queryset(self):
        user = self.request.user
        if user.role == 'OWNER':
            return SupportTicket.objects.filter(tenant=self.request.tenant)
        return SupportTicket.objects.filter(user=user, tenant=self.request.tenant)

    def perform_create(self, serializer):
        ticket = serializer.save(tenant=self.request.tenant, user=self.request.user)
        # Log audit log
        AuditLog.objects.create(
            tenant=self.request.tenant,
            user=self.request.user,
            action="SUPPORT_TICKET_CREATE",
            details_str=json.dumps({
                "ticket_id": str(ticket.id),
                "subject": ticket.subject
            })
        )


class SuperAdminSupportTicketViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, IsSuperAdmin]
    serializer_class = SupportTicketSerializer
    queryset = SupportTicket.objects.all().order_by('-created_at')

    @transaction.atomic
    def perform_update(self, serializer):
        ticket = serializer.save()
        # Log audit log
        AuditLog.objects.create(
            tenant=ticket.tenant,
            user=self.request.user,
            action="SUPPORT_TICKET_RESOLVE" if ticket.status == 'RESOLVED' else "SUPPORT_TICKET_UPDATE",
            details_str=json.dumps({
                "ticket_id": str(ticket.id),
                "status": ticket.status
            })
        )


class SuperAdminPlatformSettingsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, IsSuperAdmin]

    def get(self, request):
        settings_obj, _ = PlatformSettings.objects.get_or_create(
            pk=uuid.UUID('00000000-0000-0000-0000-000000000000'),
            defaults={'maintenance_mode': False, 'allowed_signups': True, 'default_trial_days': 14}
        )
        return success_response(
            message="Platform settings retrieved",
            data=PlatformSettingsSerializer(settings_obj).data
        )

    def patch(self, request):
        settings_obj, _ = PlatformSettings.objects.get_or_create(
            pk=uuid.UUID('00000000-0000-0000-0000-000000000000'),
            defaults={'maintenance_mode': False, 'allowed_signups': True, 'default_trial_days': 14}
        )
        serializer = PlatformSettingsSerializer(settings_obj, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            # Log audit log
            AuditLog.objects.create(
                user=request.user,
                action="PLATFORM_SETTINGS_UPDATE",
                details_str=json.dumps(request.data)
            )
            return success_response(
                message="Platform settings updated successfully",
                data=serializer.data
            )
        return failure_response("Validation error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)
