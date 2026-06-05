from rest_framework import permissions
from accounts.models import UserRole

class IsGymOwner(permissions.BasePermission):
    """
    Allows access only to authenticated gym owners.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == UserRole.OWNER)

class IsTrainer(permissions.BasePermission):
    """
    Allows access only to authenticated trainers.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == UserRole.TRAINER)

class IsMember(permissions.BasePermission):
    """
    Allows access only to authenticated members.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == UserRole.MEMBER)

class IsMemberSelf(permissions.BasePermission):
    """
    Allows members to access only their own records.
    """
    def has_object_permission(self, request, view, obj):
        if not request.user or not request.user.is_authenticated:
            return False
        # If superuser or owner, bypass self check
        if request.user.role == UserRole.OWNER or request.user.is_superuser:
            return True
        if hasattr(obj, 'user'):
            return obj.user == request.user
        if hasattr(obj, 'member'):
            return obj.member.user == request.user
        return False
