from django.contrib import admin
from .models import WorkoutSession, SessionBooking

@admin.register(WorkoutSession)
class WorkoutSessionAdmin(admin.ModelAdmin):
    list_display = ('title', 'gym', 'trainer', 'session_date', 'start_time', 'end_time', 'max_capacity', 'is_deleted')
    list_filter = ('gym', 'trainer', 'session_date', 'is_deleted')
    search_fields = ('title', 'description')
    ordering = ('session_date', 'start_time')


@admin.register(SessionBooking)
class SessionBookingAdmin(admin.ModelAdmin):
    list_display = ('session', 'member', 'status', 'booked_at')
    list_filter = ('status', 'booked_at')
    search_fields = ('member__full_name', 'session__title')
    ordering = ('-booked_at',)
