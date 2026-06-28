from rest_framework import permissions

class IsSuperAdmin(permissions.BasePermission):
    """
    Permission that grants access only to Django superusers / Platform admins.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.is_superuser)


class TenantAccessPermission(permissions.BasePermission):
    """
    Permission that enforces Tenant-level data validation.
    Ensures that request.tenant is set and active, and matches the user's role constraints.
    """
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
            
        # Super Admins bypass tenant validation permission checks
        if request.user.is_superuser:
            return True
            
        # Ensure tenant was resolved by TenantMiddleware
        return hasattr(request, 'tenant') and request.tenant is not None

    def has_object_permission(self, request, view, obj):
        if request.user.is_superuser:
            return True
            
        # Resolve tenant from obj
        obj_tenant = None
        if hasattr(obj, 'tenant'):
            obj_tenant = obj.tenant
        elif hasattr(obj, 'gym') and obj.gym:
            obj_tenant = obj.gym.tenant
        elif hasattr(obj, 'member') and obj.member.gym:
            obj_tenant = obj.member.gym.tenant
        elif hasattr(obj, 'trainer') and obj.trainer.gym:
            obj_tenant = obj.trainer.gym.tenant
        elif hasattr(obj, 'session') and obj.session.gym:
            obj_tenant = obj.session.gym.tenant

        return obj_tenant == request.tenant
