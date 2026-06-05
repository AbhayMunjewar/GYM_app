from django.db import transaction
from django.contrib.auth import get_user_model
from accounts.validators import validate_user_email, validate_user_password, validate_user_phone

User = get_user_model()

class AccountService:
    @staticmethod
    @transaction.atomic
    def register_user(full_name, username, email, password, phone_number, role):
        # Perform validation steps
        validate_user_email(email)
        validate_user_password(password)
        if phone_number:
            validate_user_phone(phone_number)

        # Create the user; create_user naturally handles password hashing
        user = User.objects.create_user(
            email=email,
            password=password,
            username=username,
            full_name=full_name,
            phone_number=phone_number,
            role=role,
            is_active=True,
            is_verified=False
        )
        return user
