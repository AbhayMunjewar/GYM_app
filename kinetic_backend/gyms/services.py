from django.core.exceptions import ValidationError
from django.shortcuts import get_object_or_404
from .models import Gym

class GymService:
    @staticmethod
    def create_gym(owner, validated_data):
        """
        Creates a new gym for the given owner.
        """
        if owner.role != 'OWNER':
            raise ValidationError("Only users with the OWNER role can create a gym.")
        
        # Check for duplicates based on name and owner
        if Gym.objects.filter(owner=owner, gym_name__iexact=validated_data.get('gym_name'), is_deleted=False).exists():
            raise ValidationError("You already have a gym with this name.")
            
        gym = Gym.objects.create(owner=owner, **validated_data)
        return gym

    @staticmethod
    def update_gym(gym, validated_data):
        """
        Updates an existing gym's fields.
        """
        for attr, value in validated_data.items():
            setattr(gym, attr, value)
        gym.save()
        return gym

    @staticmethod
    def delete_gym(gym):
        """
        Soft deletes the gym.
        """
        gym.soft_delete()

    @staticmethod
    def get_owner_gyms(owner):
        """
        Retrieves all non-deleted gyms for a specific owner.
        """
        return Gym.objects.filter(owner=owner, is_deleted=False)

    @staticmethod
    def get_gym(gym_id, owner=None):
        """
        Retrieves a non-deleted gym. If owner is provided, ensures it belongs to the owner.
        """
        queryset = Gym.objects.filter(id=gym_id, is_deleted=False)
        if owner:
            queryset = queryset.filter(owner=owner)
        return get_object_or_404(queryset)
