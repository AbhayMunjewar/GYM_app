from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from gyms.models import Gym
from members.models import Member
from .models import GymQRCode, QRScanLog
from .serializers import (
    GymQRCodeSerializer, QRScanLogSerializer, 
    QRGenerateRequestSerializer, QRScanRequestSerializer
)
from .services import QRService
from .permissions import IsGymOwner, IsGymMember
from django.utils import timezone
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

def get_owner_gym(user):
    return Gym.objects.filter(owner=user).first()

def get_member(user):
    return Member.objects.filter(email=user.email).first()

class QRGenerateView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    @swagger_auto_schema(
        operation_summary="Generate Gym QR Code",
        request_body=QRGenerateRequestSerializer,
        responses={201: "QR Code generated successfully", 400: "Invalid data", 404: "Gym not found"}
    )
    def post(self, request):
        gym = get_owner_gym(request.user)
        if not gym:
            return Response({"success": False, "message": "Gym not found for this owner."}, status=404)

        serializer = QRGenerateRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({"success": False, "message": "Invalid data", "errors": serializer.errors}, status=400)

        qr_type = serializer.validated_data.get('qr_type')
        expiry_minutes = serializer.validated_data.get('expiry_minutes', 5)

        qr_code = QRService.generate_qr(gym, qr_type, expiry_minutes)

        return Response({
            "success": True,
            "message": "QR Code generated successfully",
            "data": {
                "qr_token": qr_code.qr_token,
                "qr_type": qr_code.qr_type,
                "expires_at": qr_code.expires_at
            }
        }, status=201)

class ActiveQRView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    @swagger_auto_schema(
        operation_summary="Get Active QR Code",
        responses={200: GymQRCodeSerializer(), 404: "No active QR code found"}
    )
    def get(self, request, gym_id):
        gym = get_owner_gym(request.user)
        if not gym or str(gym.id) != str(gym_id):
            return Response({"success": False, "message": "Gym not found or access denied."}, status=404)

        active_qr = QRService.get_active_qr(gym)
        if not active_qr:
            return Response({"success": False, "message": "No active QR code found."}, status=404)

        serializer = GymQRCodeSerializer(active_qr)
        return Response({
            "success": True,
            "data": serializer.data
        })

class QRScanView(APIView):
    permission_classes = [IsAuthenticated, IsGymMember]

    @swagger_auto_schema(
        operation_summary="Scan QR Code",
        request_body=QRScanRequestSerializer,
        responses={201: "Successfully checked in", 400: "Scan failed", 404: "Member not found"}
    )
    def post(self, request):
        member = get_member(request.user)
        if not member:
            return Response({"success": False, "message": "Member profile not found."}, status=404)

        serializer = QRScanRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({"success": False, "message": "Invalid data", "errors": serializer.errors}, status=400)

        qr_token = serializer.validated_data.get('qr_token')
        device_info = serializer.validated_data.get('device_info', '')
        ip_address = request.META.get('REMOTE_ADDR')

        success, log, message = QRService.scan_qr(member, qr_token, ip_address, device_info)

        if success:
            return Response({
                "success": True,
                "message": message,
                "data": QRScanLogSerializer(log).data
            }, status=201)
        else:
            return Response({
                "success": False,
                "message": message,
                "data": QRScanLogSerializer(log).data if log else None
            }, status=400)

class QRScanHistoryView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    @swagger_auto_schema(
        operation_summary="Get QR Scan History (Owner)",
        manual_parameters=[
            openapi.Parameter('status', openapi.IN_QUERY, description="Filter by status (SUCCESS, FAILED, DUPLICATE)", type=openapi.TYPE_STRING),
            openapi.Parameter('date', openapi.IN_QUERY, description="Filter by date (YYYY-MM-DD)", type=openapi.TYPE_STRING)
        ],
        responses={200: QRScanLogSerializer(many=True)}
    )
    def get(self, request):
        gym = get_owner_gym(request.user)
        if not gym:
            return Response({"success": False, "message": "Gym not found."}, status=404)

        logs = QRScanLog.objects.filter(gym=gym).order_by('-scan_time')
        
        # Simple filtering
        status_filter = request.query_params.get('status')
        if status_filter:
            logs = logs.filter(scan_status=status_filter)
            
        date_filter = request.query_params.get('date')
        if date_filter:
            logs = logs.filter(scan_time__date=date_filter)

        # Pagination logic could be added here, returning first 50 for simplicity
        serializer = QRScanLogSerializer(logs[:50], many=True)
        return Response({
            "success": True,
            "data": serializer.data
        })

class MemberScanHistoryView(APIView):
    permission_classes = [IsAuthenticated, IsGymMember]

    @swagger_auto_schema(
        operation_summary="Get QR Scan History (Member)",
        responses={200: QRScanLogSerializer(many=True)}
    )
    def get(self, request, member_id):
        member = get_member(request.user)
        if not member or str(member.id) != str(member_id):
            return Response({"success": False, "message": "Access denied."}, status=403)

        logs = QRScanLog.objects.filter(member=member).order_by('-scan_time')[:50]
        serializer = QRScanLogSerializer(logs, many=True)
        
        return Response({
            "success": True,
            "data": serializer.data
        })

class QRDashboardAnalyticsView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    @swagger_auto_schema(
        operation_summary="Get QR Dashboard Analytics (Owner)",
        responses={200: "Dashboard metrics (today_successful, today_failed, etc.)"}
    )
    def get(self, request):
        gym = get_owner_gym(request.user)
        if not gym:
            return Response({"success": False, "message": "Gym not found."}, status=404)

        today = timezone.now().date()
        today_logs = QRScanLog.objects.filter(gym=gym, scan_time__date=today)
        
        successful = today_logs.filter(scan_status='SUCCESS').count()
        failed = today_logs.filter(scan_status='FAILED').count()
        duplicates = today_logs.filter(scan_status='DUPLICATE').count()
        
        return Response({
            "success": True,
            "data": {
                "today_successful": successful,
                "today_failed": failed,
                "today_duplicates": duplicates,
                "total_attempts": successful + failed + duplicates
            }
        })
