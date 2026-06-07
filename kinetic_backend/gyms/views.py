from rest_framework import viewsets, filters, status
from rest_framework.permissions import IsAuthenticated
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from core.responses import success_response, failure_response
from .models import Gym
from .serializers import GymSerializer, GymCreateSerializer, GymUpdateSerializer
from .permissions import IsGymOwnerPermission, IsOwnerOfGym
from .services import GymService
from django.core.exceptions import ValidationError as DjangoValidationError

class GymViewSet(viewsets.ModelViewSet):
    """
    API endpoints for managing gyms.
    """
    permission_classes = [IsAuthenticated, IsGymOwnerPermission, IsOwnerOfGym]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['gym_name', 'city', 'state']
    ordering_fields = ['created_at', 'gym_name']
    ordering = ['-created_at']

    def get_serializer_class(self):
        if self.action == 'create':
            return GymCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return GymUpdateSerializer
        return GymSerializer

    def get_queryset(self):
        """
        Return only the gyms owned by the logged-in user that are not deleted.
        """
        return GymService.get_owner_gyms(self.request.user)

    @swagger_auto_schema(
        operation_description="Create a new Gym",
        request_body=GymCreateSerializer,
        responses={201: GymSerializer(), 400: "Validation Errors"}
    )
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            return failure_response(message="Validation failed", errors=serializer.errors)

        try:
            gym = GymService.create_gym(owner=request.user, validated_data=serializer.validated_data)
            return success_response(
                message="Gym created successfully",
                data=GymSerializer(gym).data,
                status_code=status.HTTP_201_CREATED
            )
        except DjangoValidationError as e:
            return failure_response(message="Validation Error", errors=e.messages)

    @swagger_auto_schema(
        operation_description="Get list of gyms owned by the user",
        responses={200: GymSerializer(many=True)}
    )
    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return success_response(
            message="Gyms retrieved successfully",
            data=serializer.data
        )

    @swagger_auto_schema(
        operation_description="Retrieve details of a specific gym",
        responses={200: GymSerializer(), 404: "Not found"}
    )
    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return success_response(
            message="Gym retrieved successfully",
            data=serializer.data
        )

    @swagger_auto_schema(
        operation_description="Update a gym (Partial update supported)",
        request_body=GymUpdateSerializer,
        responses={200: GymSerializer(), 400: "Validation Errors"}
    )
    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        
        if not serializer.is_valid():
            return failure_response(message="Validation failed", errors=serializer.errors)

        gym = GymService.update_gym(instance, serializer.validated_data)
        return success_response(
            message="Gym updated successfully",
            data=GymSerializer(gym).data
        )

    @swagger_auto_schema(
        operation_description="Delete a gym (Soft Delete)",
        responses={200: "Gym deleted successfully", 404: "Not found"}
    )
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        GymService.delete_gym(instance)
        return success_response(
            message="Gym deleted successfully"
        )
