from django.urls import path, include
from rest_framework.routers import DefaultRouter
from tenancy.views import (
    RegisterTenantView, SubscriptionDetailView, PlanUpgradeView, PlanDowngradeView,
    BillingInvoicesView, PayInvoiceView, LicenseView, LicenseActivateView, FeatureFlagsView,
    BranchViewSet, SuperAdminDashboardView, SuperAdminLicenseGenerateView,
    SupportTicketViewSet, SuperAdminSupportTicketViewSet, SuperAdminPlatformSettingsView
)

router = DefaultRouter()
router.register(r'branches', BranchViewSet, basename='branches')
router.register(r'support-tickets', SupportTicketViewSet, basename='support-tickets')
router.register(r'admin/support-tickets', SuperAdminSupportTicketViewSet, basename='admin-support-tickets')

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
    
    # Branches & Support Tickets CRUD endpoints
    path('', include(router.urls)),
    
    # Super Admin Dashboard & Settings views
    path('admin/dashboard/', SuperAdminDashboardView.as_view(), name='admin-dashboard'),
    path('admin/licenses/generate/', SuperAdminLicenseGenerateView.as_view(), name='admin-license-generate'),
    path('admin/platform-settings/', SuperAdminPlatformSettingsView.as_view(), name='admin-platform-settings'),
]
