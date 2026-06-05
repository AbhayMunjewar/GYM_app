from rest_framework import viewsets, permissions
from members.models import Member
from members.serializers import MemberSerializer
from core.permissions import IsMemberSelf

class MemberViewSet(viewsets.ModelViewSet):
    serializer_class = MemberSerializer

    def get_permissions(self):
        return [permissions.IsAuthenticated(), IsMemberSelf()]

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser:
            return Member.objects.all()

        # If Gym Owner, get all members in their gyms
        if user.role == 'OWNER':
            return Member.objects.filter(gym__owner=user)

        # If Trainer, get all members in their gym
        if user.role == 'TRAINER':
            if hasattr(user, 'trainer_profile'):
                return Member.objects.filter(gym=user.trainer_profile.gym)
            return Member.objects.none()

        # If Member, get only their own profile
        if user.role == 'MEMBER':
            return Member.objects.filter(user=user)

        return Member.objects.none()
