from rest_framework import viewsets, permissions
from trainers.models import Trainer
from trainers.serializers import TrainerSerializer
from core.permissions import IsMemberSelf

class TrainerViewSet(viewsets.ModelViewSet):
    serializer_class = TrainerSerializer

    def get_permissions(self):
        return [permissions.IsAuthenticated(), IsMemberSelf()]

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser:
            return Trainer.objects.all()

        # If Gym Owner, get all trainers in their gyms
        if user.role == 'OWNER':
            return Trainer.objects.filter(gym__owner=user)

        # If Trainer, get only their own profile
        if user.role == 'TRAINER':
            return Trainer.objects.filter(user=user)

        # If Member, get all trainers in their gym
        if user.role == 'MEMBER':
            if hasattr(user, 'member_profile'):
                return Trainer.objects.filter(gym=user.member_profile.gym)
            return Trainer.objects.none()

        return Trainer.objects.none()
