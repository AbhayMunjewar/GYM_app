import re
from django.core.exceptions import ValidationError
from django.core.validators import validate_email as django_validate_email

def validate_user_email(email):
    try:
        django_validate_email(email)
    except ValidationError:
        raise ValidationError("Enter a valid email address.")
    return email

def validate_user_phone(phone_number):
    if phone_number:
        pattern = r'^\+?[0-9]{9,15}$'
        if not re.match(pattern, phone_number):
            raise ValidationError("Phone number must be between 9 and 15 digits, and optionally start with '+'.")
    return phone_number

def validate_user_password(password):
    if len(password) < 8:
        raise ValidationError("Password must be at least 8 characters long.")
    if not re.search(r"[A-Z]", password):
        raise ValidationError("Password must contain at least one uppercase letter.")
    if not re.search(r"[a-z]", password):
        raise ValidationError("Password must contain at least one lowercase letter.")
    if not re.search(r"\d", password):
        raise ValidationError("Password must contain at least one number.")
    return password
