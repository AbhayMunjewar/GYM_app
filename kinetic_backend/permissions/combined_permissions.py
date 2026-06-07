from rest_framework import permissions

class OwnerOrTrainerPermission(permissions.BasePermission):
    message = "You do not have permission to access this resource."

    def has_permission(self, request, view):
        return bool(
            request.user and 
            request.user.is_authenticated and 
            request.user.role in ['OWNER', 'TRAINER']
        )

class TrainerOrMemberPermission(permissions.BasePermission):
    message = "You do not have permission to access this resource."

    def has_permission(self, request, view):
        return bool(
            request.user and 
            request.user.is_authenticated and 
            request.user.role in ['TRAINER', 'MEMBER']
        )

class OwnerOrTrainerOrMemberPermission(permissions.BasePermission):
    message = "You do not have permission to access this resource."

    def has_permission(self, request, view):
        return bool(
            request.user and 
            request.user.is_authenticated and 
            request.user.role in ['OWNER', 'TRAINER', 'MEMBER']
        )
