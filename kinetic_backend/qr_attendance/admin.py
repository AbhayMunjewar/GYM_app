from django.contrib import admin
from .models import GymQRCode, QRScanLog

@admin.register(GymQRCode)
class GymQRCodeAdmin(admin.ModelAdmin):
    list_display = ['gym', 'qr_token', 'qr_type', 'is_active', 'expires_at', 'created_at']
    list_filter = ['is_active', 'qr_type']
    search_fields = ['gym__gym_name', 'qr_token']

@admin.register(QRScanLog)
class QRScanLogAdmin(admin.ModelAdmin):
    list_display = ['member', 'gym', 'scan_status', 'scan_time', 'ip_address']
    list_filter = ['scan_status', 'scan_time']
    search_fields = ['member__full_name', 'member__email', 'gym__gym_name']
