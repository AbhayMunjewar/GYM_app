from django.urls import path, include
from rest_framework.routers import DefaultRouter
from tenancy.views import (
    RegisterTenantView, SubscriptionDetailView, PlanUpgradeView, PlanDowngradeView,
    BillingInvoicesView, PayInvoiceView, LicenseView, LicenseActivateView, FeatureFlagsView,
    BranchViewSet, SuperAdminDashboardView, SuperAdminLicenseGenerateView
)

router = DefaultRouter()
router.register(r'branches', BranchViewSet, basename='branches')

urlpatterns = [
    path('register/', RegisterTenantView.as_view(), name='register-tenant'),
    path('subscription/', SubscriptionDetailView.as_view(), name='subscription-detail'),
    path('subscription/upgrade/', PlanUpgradeView.as_view(), name='subscription-upgrade'),
    path('subscription/downgrade/', PlanDowngradeView.as_view(), name='subscription-downgrade'),
    path('billing/invoices/', BillingInvoicesView.as_view(), name='billing-invoices'),
    path('billing/pay/', PayInvoiceView.as_view(), name='pay-invoice'),
    path('licenses/', LicenseView.as_view(), name='licenses'),
    path('licenses/activate/', LicenseActivateView.as_view(), name='licenses-activate'),
    path('features/', FeatureFlagsView.as_view(), name='feature-flags'),
    
    # Branches CRUD endpoints
    path('', include(router.urls)),
    
    # Super Admin Dashboard views
    path('admin/dashboard/', SuperAdminDashboardView.as_view(), name='admin-dashboard'),
    path('admin/licenses/generate/', SuperAdminLicenseGenerateView.as_view(), name='admin-license-generate'),
]
