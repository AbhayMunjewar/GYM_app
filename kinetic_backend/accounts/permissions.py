from rest_framework import permissions
from accounts.models import UserRole

class OwnerPermission(permissions.BasePermission):
    """
    Grants access only to authenticated users with the OWNER role.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == UserRole.OWNER)

class TrainerPermission(permissions.BasePermission):
    """
    Grants access only to authenticated users with the TRAINER role.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == UserRole.TRAINER)

class MemberPermission(permissions.BasePermission):
    """
    Grants access only to authenticated users with the MEMBER role.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == UserRole.MEMBER)
