import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.utils.translation import gettext_lazy as _

class UserRole(models.TextChoices):
    OWNER = 'OWNER', _('Gym Owner')
    TRAINER = 'TRAINER', _('Trainer')
    MEMBER = 'MEMBER', _('Member')

class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError(_('The Email field must be set'))
        email = self.normalize_email(email)
        # Ensure username is set and unique
        username = extra_fields.get('username')
        if not username:
            username = email.split('@')[0]

        base_username = username
        counter = 1
        while self.model.objects.filter(username=username).exists():
            username = f"{base_username}{counter}"
            counter += 1
        extra_fields['username'] = username


        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('is_verified', True)
        extra_fields.setdefault('role', UserRole.OWNER)

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))

        return self.create_user(email, password, **extra_fields)

class User(AbstractUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(_('email address'), unique=True, db_index=True)
    full_name = models.CharField(_('full name'), max_length=255)
    phone_number = models.CharField(_('phone number'), max_length=20, blank=True, db_index=True)
    role = models.CharField(
        _('role'),
        max_length=20,
        choices=UserRole.choices,
        default=UserRole.MEMBER,
        db_index=True
    )
    is_verified = models.BooleanField(_('verified status'), default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # Disable default first/last name
    first_name = None
    last_name = None

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username', 'full_name']

    class Meta:
        db_table = 'users'
        verbose_name = _('user')
        verbose_name_plural = _('users')
        indexes = [
            models.Index(fields=['email', 'phone_number']),
            models.Index(fields=['role', 'is_active']),
        ]

    def __str__(self):
        return f"{self.email} ({self.role})"


class Notification(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(_('title'), max_length=255)
    message = models.TextField(_('message'))
    is_read = models.BooleanField(_('is read'), default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} - {self.user.email}"

