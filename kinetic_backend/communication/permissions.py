from rest_framework import permissions
from accounts.models import UserRole
from members.models import Member
from trainers.models import Trainer

def get_user_gyms(user):
    """
    Helper to resolve all gym instances associated with the authenticated user.
    """
    if not user or not user.is_authenticated:
        return []
    
    if user.role == UserRole.OWNER:
        return list(user.gyms.all())
    elif user.role == UserRole.TRAINER:
        trainer = Trainer.objects.filter(user=user, is_deleted=False).first()
        return [trainer.gym] if trainer else []
    elif user.role == UserRole.MEMBER:
        member = Member.objects.filter(email=user.email, is_deleted=False).first()
        return [member.gym] if member else []
    
    return []

class IsGymParticipant(permissions.BasePermission):
    """
    Ensures the user belongs to the same gym as the communication resource.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        user = request.user
        gyms = get_user_gyms(user)
        
        # Determine the gym of the target object
        if hasattr(obj, 'gym'):
            obj_gym = obj.gym
        elif hasattr(obj, 'group'):
            obj_gym = obj.group.gym
        elif hasattr(obj, 'category'):
            obj_gym = obj.category.gym
        elif hasattr(obj, 'topic'):
            obj_gym = obj.topic.category.gym
        elif hasattr(obj, 'event'):
            obj_gym = obj.event.gym
        elif hasattr(obj, 'question'):
            obj_gym = obj.question.gym
        else:
            return False
            
        return obj_gym in gyms


class IsOwnerOrTrainer(permissions.BasePermission):
    """
    Restricts actions to gym owners and trainers.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.role in [UserRole.OWNER, UserRole.TRAINER]


class IsModeratorOrOwner(permissions.BasePermission):
    """
    Restricts actions to content moderators (owners and trainers).
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.role in [UserRole.OWNER, UserRole.TRAINER]
