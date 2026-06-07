from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from core.pagination import StandardResultsSetPagination
from core.responses import success_response, failure_response
from .models import Member
from .serializers import MemberSerializer, MemberListSerializer, MemberCreateSerializer, MemberUpdateSerializer
from .services import MemberService
from .permissions import IsGymOwnerForMember

class MemberViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsGymOwnerForMember]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        return MemberService.get_members_for_owner(self.request.user, self.request.query_params)

    def get_serializer_class(self):
        if self.action == 'list':
            return MemberListSerializer
        elif self.action == 'create':
            return MemberCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return MemberUpdateSerializer
        return MemberSerializer

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            paginated_response = self.get_paginated_response(serializer.data)
            return success_response("Members retrieved successfully", data=paginated_response.data)
        
        serializer = self.get_serializer(queryset, many=True)
        return success_response("Members retrieved successfully", data=serializer.data)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            member = MemberService.create_member(request.user, serializer.validated_data)
            return success_response(
                "Member created successfully", 
                data=MemberSerializer(member).data, 
                status_code=status.HTTP_201_CREATED
            )
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return success_response("Member details retrieved successfully", data=serializer.data)

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        if serializer.is_valid():
            member = MemberService.update_member(instance, serializer.validated_data)
            return success_response("Member updated successfully", data=MemberSerializer(member).data)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        MemberService.delete_member(instance)
        return success_response("Member deleted successfully", status_code=status.HTTP_200_OK)
