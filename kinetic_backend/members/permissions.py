from rest_framework import permissions
from accounts.models import UserRole

class IsGymOwnerForMember(permissions.BasePermission):
    """
    Object-level permission to only allow owners of the gym to edit its members.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == UserRole.OWNER)

    def has_object_permission(self, request, view, obj):
        # The user must own the gym the member belongs to
        return obj.gym.owner == request.user
