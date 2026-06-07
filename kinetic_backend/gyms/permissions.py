from rest_framework import permissions
from accounts.models import UserRole

class IsGymOwnerPermission(permissions.BasePermission):
    """
    Global permission check for OWNER role.
    """
    message = "Only gym owners can perform this action."

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == UserRole.OWNER)


class IsOwnerOfGym(permissions.BasePermission):
    """
    Object-level permission to only allow owners of an object to edit it.
    """
    message = "You do not have permission to access or modify this gym."

    def has_object_permission(self, request, view, obj):
        return obj.owner == request.user
