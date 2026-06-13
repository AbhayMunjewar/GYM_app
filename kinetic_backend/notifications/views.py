from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from core.responses import success_response, failure_response
from core.pagination import StandardResultsSetPagination
from .models import Notification, DeviceToken
from .serializers import NotificationSerializer, DeviceTokenSerializer
from .services import NotificationService

class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = StandardResultsSetPagination
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    
    # Filtering
    filterset_fields = ['is_read', 'notification_type', 'priority']
    search_fields = ['title', 'message']
    ordering_fields = ['created_at', 'priority']
    ordering = ['-created_at']

    def get_queryset(self):
        return Notification.objects.filter(recipient=self.request.user, is_deleted=False)

    def destroy(self, request, *args, **kwargs):
        # Soft delete
        instance = self.get_object()
        instance.is_deleted = True
        instance.save()
        return success_response("Notification deleted.", status_code=status.HTTP_200_OK)

    @action(detail=True, methods=['patch'])
    def read(self, request, pk=None):
        notification = NotificationService.mark_as_read(pk, request.user)
        if notification:
            serializer = self.get_serializer(notification)
            return success_response("Notification marked as read.", data=serializer.data)
        return failure_response("Notification not found.", status_code=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['patch'], url_path='mark-all-read')
    def mark_all_read(self, request):
        updated_count = NotificationService.bulk_mark_as_read(request.user)
        return success_response(f"{updated_count} notifications marked as read.")

class DeviceTokenViewSet(viewsets.ModelViewSet):
    serializer_class = DeviceTokenSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return DeviceToken.objects.filter(user=self.request.user)

    def perform_destroy(self, instance):
        instance.is_active = False
        instance.save()
        return success_response("Device token deactivated.")
