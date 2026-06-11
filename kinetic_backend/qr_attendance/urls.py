from django.urls import path
from .views import (
    QRGenerateView,
    ActiveQRView,
    QRScanView,
    QRScanHistoryView,
    MemberScanHistoryView,
    QRDashboardAnalyticsView
)

urlpatterns = [
    path('generate/', QRGenerateView.as_view(), name='qr-generate'),
    path('gym/<uuid:gym_id>/', ActiveQRView.as_view(), name='active-qr'),
    path('scan/', QRScanView.as_view(), name='qr-scan'),
    path('history/', QRScanHistoryView.as_view(), name='qr-history'),
    path('member/<uuid:member_id>/', MemberScanHistoryView.as_view(), name='member-qr-history'),
    path('dashboard/owner/', QRDashboardAnalyticsView.as_view(), name='qr-dashboard-owner'),
]
