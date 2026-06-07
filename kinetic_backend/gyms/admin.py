from django.contrib import admin
from .models import Gym

@admin.register(Gym)
class GymAdmin(admin.ModelAdmin):
    list_display = ('gym_name', 'owner', 'city', 'state', 'contact_number', 'is_active', 'is_deleted', 'created_at')
    list_filter = ('is_active', 'is_deleted', 'state', 'created_at')
    search_fields = ('gym_name', 'owner__email', 'owner__full_name', 'city', 'state', 'contact_number')
    readonly_fields = ('id', 'created_at', 'updated_at')
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('id', 'gym_name', 'owner', 'description', 'logo')
        }),
        ('Location & Contact', {
            'fields': ('address', 'city', 'state', 'pincode', 'contact_number', 'email')
        }),
        ('Status', {
            'fields': ('is_active', 'is_deleted')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )

    def get_queryset(self, request):
        """Allow admin to see all gyms, including soft-deleted ones."""
        qs = self.model._default_manager.all()
        return qs
