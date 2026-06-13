from django.contrib import admin
from django.urls import path, include, re_path
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

schema_view = get_schema_view(
    openapi.Info(
        title="Kinetic Gym Management API",
        default_version='v1',
        description="Enterprise API documentation for Kinetic Gym Management SaaS Platform backend.",
        terms_of_service="https://www.google.com/policies/terms/",
        contact=openapi.Contact(email="support@kinetic.com"),
        license=openapi.License(name="BSD License"),
    ),
    public=True,
    permission_classes=(permissions.AllowAny,),
)

from accounts.views import OwnerDashboardView, TrainerDashboardView, MemberDashboardView

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # Swagger & ReDoc endpoints
    re_path(r'^swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
    
    # API Endpoints
    path('api/auth/', include('accounts.urls')),
    path('api/gyms/', include('gyms.urls')),
    path('api/members/', include('members.urls')),
    path('api/memberships/', include('memberships.urls')),
    path('api/attendance/', include('attendance.urls')),
    path('api/qr-attendance/', include('qr_attendance.urls')),
    path('api/billing/', include('billing.urls')),
    path('api/trainers/', include('trainers.urls')),
    path('api/trainer-assignments/', include('trainers.urls_assignments')),
    path('api/sessions/', include('workout_sessions.urls_sessions')),
    path('api/bookings/', include('workout_sessions.urls_bookings')),
    path('api/', include('diets.urls')),
    path('api/progress/', include('progress_tracking.urls')),
    path('api/notifications/', include('notifications.urls')),
    path('api/analytics/', include('analytics.urls')),
    
    # Role-based dashboard routes
    path('api/owner/dashboard/', OwnerDashboardView.as_view(), name='owner_dashboard'),
    path('api/trainer/dashboard/', TrainerDashboardView.as_view(), name='trainer_dashboard'),
    path('api/member/dashboard/', MemberDashboardView.as_view(), name='member_dashboard'),
]
