from rest_framework import serializers
from trainers.models import Trainer
from accounts.serializers import UserSerializer

class TrainerSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    gym_name = serializers.ReadOnlyField(source='gym.name')

    class Meta:
        model = Trainer
        fields = [
            'id', 'user', 'gym', 'gym_name', 
            'specialization', 'bio', 'experience_years', 
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'user', 'gym', 'gym_name', 'created_at', 'updated_at']
