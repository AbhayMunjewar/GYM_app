from django.contrib import admin
from .models import Attendance

@admin.register(Attendance)
class AttendanceAdmin(admin.ModelAdmin):
    list_display = ('member', 'gym', 'attendance_date', 'check_in_time', 'check_out_time', 'attendance_status')
    list_filter = ('attendance_status', 'attendance_date', 'gym')
    search_fields = ('member__full_name', 'member__email')
    readonly_fields = ('created_at', 'updated_at')
    date_hierarchy = 'attendance_date'
