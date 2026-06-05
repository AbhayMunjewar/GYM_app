from rest_framework import permissions
from accounts.models import UserRole

class MemberPermission(permissions.BasePermission):
    message = "You do not have permission to access this resource."

    def has_permission(self, request, view):
        return bool(
            request.user and 
            request.user.is_authenticated and 
            request.user.role == UserRole.MEMBER
        )
