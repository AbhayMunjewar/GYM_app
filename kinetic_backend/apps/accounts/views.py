from rest_framework import status, views, permissions
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from accounts.serializers import RegisterSerializer, UserSerializer
from accounts.services import AccountService
from django.core.exceptions import ValidationError

class RegisterView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            user = AccountService.register_user(**serializer.validated_data)
            user_data = UserSerializer(user).data
            return Response(
                {
                    "success": True,
                    "message": "User registered successfully.",
                    "data": user_data
                },
                status=status.HTTP_201_CREATED
            )
        except ValidationError as e:
            msg = e.messages if hasattr(e, 'messages') else str(e)
            return Response(
                {
                    "success": False,
                    "error": {
                        "code": "RegistrationError",
                        "message": msg
                    }
                },
                status=status.HTTP_400_BAD_REQUEST
            )

class UserMeView(views.APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response({
            "success": True,
            "data": serializer.data
        })

    def put(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({
            "success": True,
            "message": "Profile updated successfully.",
            "data": serializer.data
        })

class LogoutView(views.APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get("refresh")
            if not refresh_token:
                return Response(
                    {"success": False, "error": {"code": "MissingToken", "message": "Refresh token is required."}},
                    status=status.HTTP_400_BAD_REQUEST
                )
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response(
                {"success": True, "message": "Successfully logged out."},
                status=status.HTTP_200_OK
            )
        except Exception as e:
            return Response(
                {"success": False, "error": {"code": "LogoutError", "message": str(e)}},
                status=status.HTTP_400_BAD_REQUEST
            )
