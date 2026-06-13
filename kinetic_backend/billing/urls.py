from django.urls import path
from .views import (
    GymPaymentSettingsView,
    InvoiceListCreateView,
    InvoiceDetailView,
    PaymentListView,
    RecordPaymentView,
    AcknowledgePaymentView,
    RevenueAnalyticsView
)

urlpatterns = [
    # Settings
    path('settings/', GymPaymentSettingsView.as_view(), name='billing-settings'),
    
    # Invoices
    path('invoices/', InvoiceListCreateView.as_view(), name='invoice-list-create'),
    path('invoices/<uuid:pk>/', InvoiceDetailView.as_view(), name='invoice-detail'),
    
    # Payments
    path('payments/', PaymentListView.as_view(), name='payment-list'),
    path('payments/record/', RecordPaymentView.as_view(), name='record-payment'),
    path('payments/<uuid:payment_id>/acknowledge/', AcknowledgePaymentView.as_view(), name='acknowledge-payment'),
    
    # Analytics
    path('analytics/', RevenueAnalyticsView.as_view(), name='billing-analytics'),
]
