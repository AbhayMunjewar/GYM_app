from django.contrib import admin
from .models import Member

@admin.register(Member)
class MemberAdmin(admin.ModelAdmin):
    list_display = ('full_name', 'email', 'phone_number', 'gym', 'status', 'is_deleted')
    list_filter = ('status', 'is_deleted', 'gym', 'join_date')
    search_fields = ('full_name', 'email', 'phone_number', 'gym__gym_name')
    ordering = ('-created_at',)
    readonly_fields = ('created_at', 'updated_at')

    def get_queryset(self, request):
        # Override to show soft-deleted items in admin
        return self.model.objects.all()
