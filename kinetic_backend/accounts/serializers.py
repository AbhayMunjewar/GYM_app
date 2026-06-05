from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError as DjangoValidationError
from accounts.validators import validate_user_email, validate_user_phone, validate_user_password
from accounts.models import UserRole

User = get_user_model()

class UserMeSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'full_name', 'email', 'role']
        read_only_fields = ['id', 'full_name', 'email', 'role']

class RegisterSerializer(serializers.Serializer):
    full_name = serializers.CharField(max_length=255)
    username = serializers.CharField(max_length=150, required=False, allow_blank=True, default='')
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    phone_number = serializers.CharField(max_length=20, required=False, allow_blank=True, default='')
    role = serializers.ChoiceField(choices=UserRole.choices)

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("A user with this email address already exists.")
        try:
            validate_user_email(value)
        except DjangoValidationError as e:
            raise serializers.ValidationError(e.messages)
        return value

    def validate_phone_number(self, value):
        if value:
            try:
                validate_user_phone(value)
            except DjangoValidationError as e:
                raise serializers.ValidationError(e.messages)
        return value

    def validate_password(self, value):
        try:
            validate_user_password(value)
        except DjangoValidationError as e:
            raise serializers.ValidationError(e.messages)
        return value
