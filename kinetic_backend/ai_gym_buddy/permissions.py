"""
AI Buddy Permissions
====================
Enforces RBAC and gym-scoped data access.
"""
from rest_framework.permissions import BasePermission
from accounts.models import UserRole


class IsMember(BasePermission):
    """Only MEMBER role can access this endpoint."""
    message = 'This endpoint is restricted to gym members.'

    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            request.user.role == UserRole.MEMBER
        )


class IsMemberOrTrainer(BasePermission):
    """MEMBER or TRAINER can access this endpoint."""
    message = 'This endpoint is restricted to members and trainers.'

    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            request.user.role in [UserRole.MEMBER, UserRole.TRAINER]
        )


class IsAnyGymRole(BasePermission):
    """Any authenticated gym participant (OWNER, TRAINER, MEMBER) can access."""

    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            request.user.role in [UserRole.OWNER, UserRole.TRAINER, UserRole.MEMBER]
        )
