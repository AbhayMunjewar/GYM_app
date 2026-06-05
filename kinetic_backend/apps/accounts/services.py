from django.db import transaction
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError
from accounts.models import UserRole
from gyms.models import Gym
from members.models import Member
from trainers.models import Trainer

User = get_user_model()

class AccountService:
    @staticmethod
    @transaction.atomic
    def register_user(email, password, role, first_name='', last_name='', phone_number='', gym_id=None):
        if role in [UserRole.MEMBER, UserRole.TRAINER] and not gym_id:
            raise ValidationError("Gym ID is required for members and trainers.")

        # Create user object
        user = User.objects.create_user(
            email=email,
            password=password,
            role=role,
            first_name=first_name,
            last_name=last_name,
            phone_number=phone_number
        )

        # Handle roles-specific profile registration
        if role == UserRole.MEMBER:
            try:
                gym = Gym.objects.get(id=gym_id)
            except Gym.DoesNotExist:
                raise ValidationError(f"Gym with ID {gym_id} does not exist.")
            Member.objects.create(user=user, gym=gym, status=Member.StatusChoices.PENDING)

        elif role == UserRole.TRAINER:
            try:
                gym = Gym.objects.get(id=gym_id)
            except Gym.DoesNotExist:
                raise ValidationError(f"Gym with ID {gym_id} does not exist.")
            Trainer.objects.create(user=user, gym=gym)

        return user
