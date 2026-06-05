from rest_framework import permissions
from accounts.models import UserRole

class OwnerOrTrainerPermission(permissions.BasePermission):
    message = "You do not have permission to access this resource."

    def has_permission(self, request, view):
        return bool(
            request.user and 
            request.user.is_authenticated and 
            request.user.role in [UserRole.OWNER, UserRole.TRAINER]
        )

class TrainerOrMemberPermission(permissions.BasePermission):
    message = "You do not have permission to access this resource."

    def has_permission(self, request, view):
        return bool(
            request.user and 
            request.user.is_authenticated and 
            request.user.role in [UserRole.TRAINER, UserRole.MEMBER]
        )

class OwnerOrTrainerOrMemberPermission(permissions.BasePermission):
    message = "You do not have permission to access this resource."

    def has_permission(self, request, view):
        return bool(
            request.user and 
            request.user.is_authenticated and 
            request.user.role in [UserRole.OWNER, UserRole.TRAINER, UserRole.MEMBER]
        )
