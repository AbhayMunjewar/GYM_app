from rest_framework import serializers
from .models import Notification, DeviceToken

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = [
            'id', 'title', 'message', 'notification_type', 
            'priority', 'is_read', 'read_at', 'action_url', 
            'metadata', 'created_at', 'updated_at'
        ]
        read_only_fields = fields

class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ['id', 'fcm_token', 'device_type', 'is_active', 'created_at']
        read_only_fields = ['id', 'created_at']

    def create(self, validated_data):
        user = self.context['request'].user
        token = validated_data.get('fcm_token')
        device_type = validated_data.get('device_type', 'ANDROID')
        
        # Upsert logic: If token exists for another user, move it. Or if exists for this user, activate.
        obj, created = DeviceToken.objects.update_or_create(
            fcm_token=token,
            defaults={'user': user, 'device_type': device_type, 'is_active': True}
        )
        return obj
