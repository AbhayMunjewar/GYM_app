from django.contrib import admin
from .models import Trainer, TrainerAssignment, TrainerAuditLog

@admin.register(Trainer)
class TrainerAdmin(admin.ModelAdmin):
    list_display = ('employee_id', 'get_full_name', 'gym', 'specialization', 'experience_years', 'status', 'is_active', 'is_deleted')
    list_filter = ('gym', 'status', 'is_active', 'is_deleted')
    search_fields = ('employee_id', 'user__full_name', 'user__email', 'specialization')
    ordering = ('employee_id', '-created_at')

    def get_full_name(self, obj):
        return obj.user.full_name
    get_full_name.short_description = 'Name'


@admin.register(TrainerAssignment)
class TrainerAssignmentAdmin(admin.ModelAdmin):
    list_display = ('trainer_name', 'member_name', 'assigned_date', 'assigned_by_name', 'status', 'created_at')
    list_filter = ('status', 'assigned_date')
    search_fields = ('trainer__user__full_name', 'member__full_name', 'notes')
    ordering = ('-created_at',)

    def trainer_name(self, obj):
        return obj.trainer.user.full_name
    trainer_name.short_description = 'Trainer'

    def member_name(self, obj):
        return obj.member.full_name
    member_name.short_description = 'Member'

    def assigned_by_name(self, obj):
        return obj.assigned_by.full_name if obj.assigned_by else 'System'
    assigned_by_name.short_description = 'Assigned By'


@admin.register(TrainerAuditLog)
class TrainerAuditLogAdmin(admin.ModelAdmin):
    list_display = ('user_email', 'action', 'timestamp')
    list_filter = ('timestamp',)
    search_fields = ('user__email', 'action')
    ordering = ('-timestamp',)

    def user_email(self, obj):
        return obj.user.email if obj.user else 'System'
    user_email.short_description = 'User'
