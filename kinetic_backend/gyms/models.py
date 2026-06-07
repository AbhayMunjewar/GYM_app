import uuid
from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _

class Gym(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym_name = models.CharField(_('gym name'), max_length=255)
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name='gyms',
        help_text=_('Owner of the gym')
    )
    address = models.TextField(_('address'))
    city = models.CharField(_('city'), max_length=100)
    state = models.CharField(_('state'), max_length=100)
    pincode = models.CharField(_('pincode'), max_length=20)
    contact_number = models.CharField(_('contact number'), max_length=20)
    email = models.EmailField(_('email address'))
    logo = models.ImageField(_('logo'), upload_to='gym_logos/', null=True, blank=True)
    description = models.TextField(_('description'), null=True, blank=True)
    
    is_active = models.BooleanField(_('active status'), default=True)
    is_deleted = models.BooleanField(_('deleted status'), default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'gyms'
        verbose_name = _('gym')
        verbose_name_plural = _('gyms')
        indexes = [
            models.Index(fields=['owner', 'is_deleted']),
            models.Index(fields=['city', 'state']),
            models.Index(fields=['gym_name']),
        ]

    def __str__(self):
        return self.gym_name

    def soft_delete(self):
        self.is_deleted = True
        self.is_active = False
        self.save(update_fields=['is_deleted', 'is_active', 'updated_at'])
