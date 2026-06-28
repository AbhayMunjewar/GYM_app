import logging
from django.http import JsonResponse
from rest_framework import status
from django.utils import timezone
from rest_framework_simplejwt.authentication import JWTAuthentication
from accounts.models import UserRole
from gyms.models import Gym, Branch
from members.models import Member
from trainers.models import Trainer
from tenancy.models import Tenant

logger = logging.getLogger(__name__)

class TenantMiddleware:
    """
    Middleware that identifies the active tenant, gym, and branch context for every request.
    Works for standard Django sessions and DRF Simple-JWT token auth.
    Injects context directly into the request scope:
    - request.tenant
    - request.gym
    - request.branch
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        request.tenant = None
        request.gym = None
        request.branch = None

        # 1. Attempt DRF JWT authentication if standard request.user is anonymous
        user = request.user
        if not user or not user.is_authenticated:
            try:
                jwt_auth = JWTAuthentication()
                header = jwt_auth.get_header(request)
                if header:
                    raw_token = jwt_auth.get_raw_token(header)
                    validated_token = jwt_auth.get_validated_token(raw_token)
                    user = jwt_auth.get_user(validated_token)
                    request.user = user # Set request.user so subsequent middleware sees it
            except Exception:
                pass

        if user and user.is_authenticated:
            # 2. Superuser / Super Admin Check
            if user.is_superuser:
                tenant_id = request.headers.get('X-Tenant-ID') or request.GET.get('tenant_id')
                if tenant_id:
                    try:
                        request.tenant = Tenant.objects.get(id=tenant_id)
                        request.gym = Gym.objects.filter(tenant=request.tenant).first()
                    except (Tenant.DoesNotExist, ValueError):
                        pass
            
            # 3. Member Check
            elif user.role == UserRole.MEMBER:
                try:
                    member = Member.objects.get(user=user, is_deleted=False)
                    request.gym = member.gym
                    request.tenant = member.gym.tenant
                    request.branch = member.branch
                except Member.DoesNotExist:
                    pass

            # 4. Trainer Check
            elif user.role == UserRole.TRAINER:
                try:
                    trainer = Trainer.objects.get(user=user, is_deleted=False)
                    request.gym = trainer.gym
                    request.tenant = trainer.gym.tenant
                    request.branch = trainer.branch
                except Trainer.DoesNotExist:
                    pass

            # 5. Gym Owner Check
            elif user.role == UserRole.OWNER:
                gym = Gym.objects.filter(owner=user, is_deleted=False).first()
                if gym:
                    request.gym = gym
                    request.tenant = gym.tenant
                    
                    # For owners, allow dynamic branch scoping via query parameters
                    branch_id = request.GET.get('branch_id')
                    if branch_id:
                        try:
                            request.branch = Branch.objects.get(id=branch_id, gym=gym, is_deleted=False)
                        except (Branch.DoesNotExist, ValueError):
                            pass

        return self.get_response(request)


class SubscriptionEnforcementMiddleware:
    """
    Middleware that verifies the active subscription status for write/operational actions.
    Returns 403 Forbidden if a tenant's subscription is suspended, expired, or cancelled.
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Allow reading endpoints (GET) and onboarding endpoints
        onboarding_paths = [
            '/api/saas/register/',
            '/api/saas/plans/',
            '/api/auth/',
            '/admin/',
        ]
        
        if request.method == 'GET' or any(request.path.startswith(p) for p in onboarding_paths):
            return self.get_response(request)

        # Enforce subscription checks only if tenant is resolved
        if hasattr(request, 'tenant') and request.tenant:
            subscription = getattr(request.tenant, 'subscription', None)
            
            if not subscription:
                return JsonResponse({
                    'success': False,
                    'message': 'No active subscription found for this tenant. Please select a plan.',
                    'errors': [{'message': 'Subscription required'}]
                }, status=status.HTTP_403_FORBIDDEN)

            # Check if subscription status is blocked
            if subscription.status in ['SUSPENDED', 'EXPIRED']:
                return JsonResponse({
                    'success': False,
                    'message': f'Your subscription is currently {subscription.status.lower()}. Please renew to perform this action.',
                    'errors': [{'message': f'Subscription {subscription.status}'}]
                }, status=status.HTTP_403_FORBIDDEN)

            # Check if trial or active plan has expired
            if subscription.end_date < timezone.now().date():
                subscription.status = 'EXPIRED'
                subscription.save(update_fields=['status'])
                return JsonResponse({
                    'success': False,
                    'message': 'Your SaaS subscription has expired. Please renew your plan.',
                    'errors': [{'message': 'Subscription expired'}]
                }, status=status.HTTP_403_FORBIDDEN)

        return self.get_response(request)
