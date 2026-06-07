from django.contrib import admin
from .models import MembershipPlan, Membership

@admin.register(MembershipPlan)
class MembershipPlanAdmin(admin.ModelAdmin):
    list_display = ('plan_name', 'gym', 'duration_days', 'price', 'is_active', 'is_deleted')
    list_filter = ('is_active', 'is_deleted', 'gym')
    search_fields = ('plan_name', 'gym__gym_name')
    ordering = ('-created_at',)

@admin.register(Membership)
class MembershipAdmin(admin.ModelAdmin):
    list_display = ('member', 'membership_plan', 'start_date', 'end_date', 'status')
    list_filter = ('status', 'membership_plan__gym')
    search_fields = ('member__full_name', 'member__email', 'membership_plan__plan_name')
    ordering = ('-created_at',)
