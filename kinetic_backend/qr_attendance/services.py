from datetime import timedelta
from django.utils import timezone
from .models import GymQRCode, QRScanLog
from attendance.models import Attendance
from memberships.models import Membership
from members.models import Member
from gyms.models import Gym

class QRService:
    @staticmethod
    def generate_qr(gym, qr_type='DYNAMIC', expiry_minutes=5):
        # Deactivate any existing active QRs for this gym
        GymQRCode.objects.filter(gym=gym, is_active=True).update(is_active=False)
        
        expires_at = None
        if qr_type == 'DYNAMIC':
            expires_at = timezone.now() + timedelta(minutes=expiry_minutes)
            
        qr_code = GymQRCode.objects.create(
            gym=gym,
            qr_type=qr_type,
            is_active=True,
            expires_at=expires_at
        )
        return qr_code

    @staticmethod
    def get_active_qr(gym):
        # We also need to check if the active DYNAMIC QR has expired
        active_qr = GymQRCode.objects.filter(gym=gym, is_active=True).first()
        if not active_qr:
            return None
            
        if active_qr.qr_type == 'DYNAMIC' and active_qr.expires_at and active_qr.expires_at < timezone.now():
            active_qr.is_active = False
            active_qr.save(update_fields=['is_active'])
            return None
            
        return active_qr

    @staticmethod
    def scan_qr(member, qr_token, ip_address=None, device_info=None):
        try:
            qr_code = GymQRCode.objects.get(qr_token=qr_token)
        except GymQRCode.DoesNotExist:
            return QRService._log_failed_scan(member, None, ip_address, device_info, 'INVALID', "Invalid QR token")

        # Basic invalidations
        if not qr_code.is_active:
            return QRService._log_failed_scan(member, qr_code.gym, ip_address, device_info, 'EXPIRED', "QR code is no longer active")

        if qr_code.qr_type == 'DYNAMIC' and qr_code.expires_at and qr_code.expires_at < timezone.now():
            qr_code.is_active = False
            qr_code.save(update_fields=['is_active'])
            return QRService._log_failed_scan(member, qr_code.gym, ip_address, device_info, 'EXPIRED', "QR code has expired")

        gym = qr_code.gym

        # Validate Membership exists for the same gym
        if member.gym != gym:
            return QRService._log_failed_scan(member, gym, ip_address, device_info, 'FAILED', "Member does not belong to this gym")

        active_membership = Membership.objects.filter(
            member=member,
            membership_plan__gym=gym,
            status='ACTIVE'
        ).first()

        if not active_membership:
            return QRService._log_failed_scan(member, gym, ip_address, device_info, 'FAILED', "No active membership found")

        today = timezone.now().date()
        
        # Check for Duplicate Attendance
        existing_attendance = Attendance.objects.filter(
            member=member,
            date=today
        ).first()

        if existing_attendance:
            # According to strictly "No Existing Attendance Record Today" -> Duplicate Scan
            return QRService._log_failed_scan(member, gym, ip_address, device_info, 'DUPLICATE', "Already checked in today")

        # Create Attendance Record
        # By Day 7 rules: we just create Attendance
        from attendance.services import AttendanceService
        try:
            attendance = AttendanceService.check_in(member)
        except Exception as e:
            return QRService._log_failed_scan(member, gym, ip_address, device_info, 'FAILED', str(e))

        # Log Success
        log = QRScanLog.objects.create(
            member=member,
            gym=gym,
            attendance=attendance,
            ip_address=ip_address,
            device_info=device_info,
            scan_status='SUCCESS'
        )

        return True, log, "Successfully checked in"

    @staticmethod
    def _log_failed_scan(member, gym, ip_address, device_info, status, error_message):
        # If gym is None, we try to use member's gym just to have it logged
        log_gym = gym if gym else member.gym
        log = QRScanLog.objects.create(
            member=member,
            gym=log_gym,
            ip_address=ip_address,
            device_info=device_info,
            scan_status=status
        )
        return False, log, error_message
