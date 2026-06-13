from rest_framework import permissions
from accounts.models import UserRole
from trainers.models import Trainer
from members.models import Member

class IsOwnerOrTrainer(permissions.BasePermission):
    """
    Allow access to Gym Owners and Trainers only.
    """
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return request.user.role in [UserRole.OWNER, UserRole.TRAINER]


class IsMemberOwnerOrTrainer(permissions.BasePermission):
    """
    Allow Members to view their own records, and Owners/Trainers to CRUD.
    """
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return True

    def has_object_permission(self, request, view, obj):
        # Allow Owners/Trainers of the gym to view/CRUD
        if request.user.role in [UserRole.OWNER, UserRole.TRAINER]:
            return True

        # Allow Member to view/update if it belongs to them
        if request.user.role == UserRole.MEMBER:
            if hasattr(obj, 'member'):
                return obj.member.user == request.user
            if isinstance(obj, Member):
                return obj.user == request.user
        return False
