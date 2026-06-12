from django.urls import path
from .views import (
    SessionBookingListCreateView, MemberBookingsView, CancelBookingView
)

urlpatterns = [
    path('', SessionBookingListCreateView.as_view(), name='booking-list-create'),
    path('member/<int:member_id>/', MemberBookingsView.as_view(), name='member-bookings'),
    path('<uuid:booking_id>/cancel/', CancelBookingView.as_view(), name='booking-cancel'),
]
