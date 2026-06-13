from django.contrib import admin
from .models import Notification, DeviceToken, NotificationTemplate

@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('id', 'recipient', 'title', 'notification_type', 'priority', 'is_read', 'created_at')
    list_filter = ('is_read', 'notification_type', 'priority', 'created_at')
    search_fields = ('title', 'message', 'recipient__email', 'recipient__first_name')
    readonly_fields = ('created_at', 'updated_at', 'read_at')
    ordering = ('-created_at',)

@admin.register(DeviceToken)
class DeviceTokenAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'fcm_token', 'device_type', 'is_active', 'created_at')
    list_filter = ('device_type', 'is_active', 'created_at')
    search_fields = ('user__email', 'fcm_token')

@admin.register(NotificationTemplate)
class NotificationTemplateAdmin(admin.ModelAdmin):
    list_display = ('template_name', 'notification_type', 'is_active', 'created_at')
    list_filter = ('notification_type', 'is_active')
    search_fields = ('template_name', 'title_template')
