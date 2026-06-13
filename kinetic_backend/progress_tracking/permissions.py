from rest_framework import permissions
from accounts.models import UserRole
from trainers.models import Trainer
from members.models import Member

class IsProgressOwnerOrTrainer(permissions.BasePermission):
    """
    Custom permission to ensure:
    - Owners have full access to their gym's members' progress.
    - Trainers have access to their gym's members' progress.
    - Members can only view and edit their own progress tracking details.
    """
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return True

    def has_object_permission(self, request, view, obj):
        # Resolve gym of the target member
        if hasattr(obj, 'member'):
            member = obj.member
        elif isinstance(obj, Member):
            member = obj
        else:
            return False
            
        role = request.user.role

        if role == UserRole.OWNER:
            return member.gym.owner == request.user
            
        elif role == UserRole.TRAINER:
            trainer = Trainer.objects.filter(user=request.user, is_deleted=False).first()
            if not trainer:
                return False
            # Ensure trainer and member are in the same gym
            return trainer.gym == member.gym
            
        elif role == UserRole.MEMBER:
            # Enforce self-ownership based on matching email
            return member.email == request.user.email
            
        return False
