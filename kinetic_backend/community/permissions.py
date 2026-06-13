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

class IsGymMemberOrStaff(permissions.BasePermission):
    """
    Ensures the user belongs to the gym associated with the community resource.
    Strictly blocks cross-gym visibility.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        user = request.user
        gyms = get_user_gyms(user)
        
        # Determine the gym of the target object
        if hasattr(obj, 'gym'):
            obj_gym = obj.gym
        elif hasattr(obj, 'post'):
            obj_gym = obj.post.gym
        elif hasattr(obj, 'member') and hasattr(obj.member, 'gym'):
            obj_gym = obj.member.gym
        else:
            return False
            
        return obj_gym in gyms


class IsPostAuthorOrStaff(permissions.BasePermission):
    """
    Allows only the author of a post to edit it.
    Allows the author OR gym Owner (moderator) to delete or change status.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        user = request.user
        
        # Read operations allowed for everyone in the same gym
        if request.method in permissions.SAFE_METHODS:
            gyms = get_user_gyms(user)
            return obj.gym in gyms
            
        # Edit operations (PUT/PATCH): only author
        if request.method in ['PUT', 'PATCH']:
            return obj.author == user
            
        # Delete operations: author OR owner of the gym
        if request.method == 'DELETE':
            if obj.author == user:
                return True
            if user.role == UserRole.OWNER and obj.gym.owner == user:
                return True
                
        return False


class IsCommentAuthorOrStaff(permissions.BasePermission):
    """
    Allows only the author of a comment to edit it.
    Allows the author OR gym Owner (moderator) to delete the comment.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        user = request.user
        
        # Read operations
        if request.method in permissions.SAFE_METHODS:
            gyms = get_user_gyms(user)
            return obj.post.gym in gyms
            
        # Edit operations (PUT/PATCH): only author
        if request.method in ['PUT', 'PATCH']:
            return obj.author == user
            
        # Delete operations: author OR owner of the gym
        if request.method == 'DELETE':
            if obj.author == user:
                return True
            if user.role == UserRole.OWNER and obj.post.gym.owner == user:
                return True
                
        return False
