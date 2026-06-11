from rest_framework import serializers
from .models import GymQRCode, QRScanLog
from attendance.serializers import AttendanceSerializer

class GymQRCodeSerializer(serializers.ModelSerializer):
    class Meta:
        model = GymQRCode
        fields = ['id', 'gym', 'qr_token', 'qr_type', 'is_active', 'expires_at', 'created_at']
        read_only_fields = ['id', 'gym', 'qr_token', 'created_at']

class QRScanLogSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    member_email = serializers.CharField(source='member.email', read_only=True)
    attendance_details = AttendanceSerializer(source='attendance', read_only=True)

    class Meta:
        model = QRScanLog
        fields = [
            'id', 'member', 'member_name', 'member_email', 'gym', 
            'attendance', 'attendance_details', 'scan_time', 
            'ip_address', 'device_info', 'scan_status', 'created_at'
        ]
        read_only_fields = fields

class QRGenerateRequestSerializer(serializers.Serializer):
    qr_type = serializers.ChoiceField(choices=['STATIC', 'DYNAMIC'], default='DYNAMIC')
    expiry_minutes = serializers.IntegerField(default=5, min_value=1, max_value=1440, required=False)

class QRScanRequestSerializer(serializers.Serializer):
    qr_token = serializers.UUIDField()
    device_info = serializers.CharField(required=False, allow_blank=True, max_length=255)
