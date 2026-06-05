import logging
from rest_framework import status, views, permissions
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenRefreshView as SimpleJWTTokenRefreshView
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from accounts.serializers import RegisterSerializer, UserMeSerializer
from accounts.services import AccountService
from core.responses import success_response, failure_response
from permissions import OwnerPermission, TrainerPermission, MemberPermission

logger = logging.getLogger(__name__)

class RegisterView(views.APIView):
    permission_classes = [permissions.AllowAny]

    @swagger_auto_schema(
        operation_description="Register a new Gym Owner, Trainer, or Member.",
        request_body=RegisterSerializer,
        responses={
            201: openapi.Response(
                description="Success",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'success': openapi.Schema(type=openapi.TYPE_BOOLEAN, default=True),
                        'message': openapi.Schema(type=openapi.TYPE_STRING, default='User registered successfully'),
                        'data': openapi.Schema(type=openapi.TYPE_OBJECT, default={})
                    }
                )
            ),
            400: "Validation error"
        }
    )
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        user = AccountService.register_user(**serializer.validated_data)
        logger.info(f"User registered successfully: {user.email} (Role: {user.role})")
        
        return success_response(
            message="User registered successfully",
            status_code=status.HTTP_201_CREATED
        )

class LoginView(views.APIView):
    permission_classes = [permissions.AllowAny]

    @swagger_auto_schema(
        operation_description="Login with email credentials to obtain JWT access and refresh tokens.",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['email', 'password'],
            properties={
                'email': openapi.Schema(type=openapi.TYPE_STRING, format=openapi.FORMAT_EMAIL),
                'password': openapi.Schema(type=openapi.TYPE_STRING, format=openapi.FORMAT_PASSWORD)
            }
        ),
        responses={
            200: openapi.Response(
                description="Success",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'success': openapi.Schema(type=openapi.TYPE_BOOLEAN, default=True),
                        'message': openapi.Schema(type=openapi.TYPE_STRING),
                        'data': openapi.Schema(
                            type=openapi.TYPE_OBJECT,
                            properties={
                                'access': openapi.Schema(type=openapi.TYPE_STRING),
                                'refresh': openapi.Schema(type=openapi.TYPE_STRING),
                                'user': openapi.Schema(
                                    type=openapi.TYPE_OBJECT,
                                    properties={
                                        'id': openapi.Schema(type=openapi.TYPE_STRING),
                                        'full_name': openapi.Schema(type=openapi.TYPE_STRING),
                                        'email': openapi.Schema(type=openapi.TYPE_STRING),
                                        'role': openapi.Schema(type=openapi.TYPE_STRING)
                                    }
                                )
                            }
                        )
                    }
                )
            ),
            401: "Invalid credentials"
        }
    )
    def post(self, request):
        email = request.data.get("email")
        password = request.data.get("password")

        if not email or not password:
            logger.warning("Login attempt failed: Email or password not provided.")
            return failure_response(
                message="Email and password are required.",
                errors=[{"message": "Email and password are required."}],
                status_code=status.HTTP_400_BAD_REQUEST
            )

        # Authenticate using custom email backend
        user = authenticate(request, username=email, password=password)

        if user is None:
            logger.warning(f"Authentication failure for email: {email}")
            return failure_response(
                message="Invalid email or password.",
                errors=[{"message": "Invalid email or password."}],
                status_code=status.HTTP_401_UNAUTHORIZED
            )

        if not user.is_active:
            logger.warning(f"Login attempt for inactive user: {email}")
            return failure_response(
                message="This account is inactive.",
                errors=[{"message": "This account is inactive."}],
                status_code=status.HTTP_403_FORBIDDEN
            )

        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)
        refresh_token = str(refresh)

        logger.info(f"User logged in successfully: {user.email}")
        
        user_data = UserMeSerializer(user).data
        return success_response(
            message="Login successful",
            data={
                "access": access_token,
                "refresh": refresh_token,
                "user": user_data
            }
        )

class CustomTokenRefreshView(SimpleJWTTokenRefreshView):
    @swagger_auto_schema(
        operation_description="Submit a refresh token to retrieve a fresh access token.",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['refresh'],
            properties={
                'refresh': openapi.Schema(type=openapi.TYPE_STRING)
            }
        ),
        responses={
            200: openapi.Response(
                description="Success",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'success': openapi.Schema(type=openapi.TYPE_BOOLEAN, default=True),
                        'message': openapi.Schema(type=openapi.TYPE_STRING),
                        'data': openapi.Schema(
                            type=openapi.TYPE_OBJECT,
                            properties={
                                'access': openapi.Schema(type=openapi.TYPE_STRING)
                            }
                        )
                    }
                )
            )
        }
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return success_response(
            message="Token refreshed successfully",
            data=serializer.validated_data
        )

class LogoutView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Logout by blacklisting the active refresh token.",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['refresh'],
            properties={
                'refresh': openapi.Schema(type=openapi.TYPE_STRING)
            }
        ),
        responses={
            200: openapi.Response(
                description="Success",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'success': openapi.Schema(type=openapi.TYPE_BOOLEAN, default=True),
                        'message': openapi.Schema(type=openapi.TYPE_STRING)
                    }
                )
            )
        }
    )
    def post(self, request):
        try:
            refresh_token = request.data.get("refresh")
            if not refresh_token:
                return failure_response(
                    message="Refresh token is required.",
                    errors=[{"message": "Refresh token is required."}],
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            token = RefreshToken(refresh_token)
            token.blacklist()
            logger.info(f"User logged out successfully: {request.user.email}")
            return success_response(
                message="Logged out successfully."
            )
        except Exception as e:
            logger.error(f"Logout failed for user {request.user.email}: {str(e)}")
            return failure_response(
                message="Logout failed.",
                errors=[{"message": str(e)}],
                status_code=status.HTTP_400_BAD_REQUEST
            )

class UserMeView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Get current authenticated user profile.",
        responses={
            200: openapi.Response(
                description="Success",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'success': openapi.Schema(type=openapi.TYPE_BOOLEAN, default=True),
                        'message': openapi.Schema(type=openapi.TYPE_STRING),
                        'data': openapi.Schema(
                            type=openapi.TYPE_OBJECT,
                            properties={
                                'id': openapi.Schema(type=openapi.TYPE_STRING),
                                'full_name': openapi.Schema(type=openapi.TYPE_STRING),
                                'email': openapi.Schema(type=openapi.TYPE_STRING),
                                'role': openapi.Schema(type=openapi.TYPE_STRING)
                            }
                        )
                    }
                )
            )
        }
    )
    def get(self, request):
        serializer = UserMeSerializer(request.user)
        return success_response(
            message="Current user profile retrieved",
            data=serializer.data
        )


class OwnerDashboardView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, OwnerPermission]

    @swagger_auto_schema(
        operation_description="Retrieve the Owner dashboard details.",
        responses={
            200: openapi.Response(
                description="Success",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'success': openapi.Schema(type=openapi.TYPE_BOOLEAN, default=True),
                        'message': openapi.Schema(type=openapi.TYPE_STRING),
                        'data': openapi.Schema(
                            type=openapi.TYPE_OBJECT,
                            properties={
                                'role': openapi.Schema(type=openapi.TYPE_STRING, default='OWNER'),
                                'message': openapi.Schema(type=openapi.TYPE_STRING, default='Welcome Owner')
                            }
                        )
                    }
                )
            )
        }
    )
    def get(self, request):
        return success_response(
            message="Welcome Owner",
            data={
                "role": "OWNER",
                "message": "Welcome Owner"
            }
        )


class TrainerDashboardView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, TrainerPermission]

    @swagger_auto_schema(
        operation_description="Retrieve the Trainer dashboard details.",
        responses={
            200: openapi.Response(
                description="Success",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'success': openapi.Schema(type=openapi.TYPE_BOOLEAN, default=True),
                        'message': openapi.Schema(type=openapi.TYPE_STRING),
                        'data': openapi.Schema(
                            type=openapi.TYPE_OBJECT,
                            properties={
                                'role': openapi.Schema(type=openapi.TYPE_STRING, default='TRAINER'),
                                'message': openapi.Schema(type=openapi.TYPE_STRING, default='Welcome Trainer')
                            }
                        )
                    }
                )
            )
        }
    )
    def get(self, request):
        return success_response(
            message="Welcome Trainer",
            data={
                "role": "TRAINER",
                "message": "Welcome Trainer"
            }
        )


class MemberDashboardView(views.APIView):
    permission_classes = [permissions.IsAuthenticated, MemberPermission]

    @swagger_auto_schema(
        operation_description="Retrieve the Member dashboard details.",
        responses={
            200: openapi.Response(
                description="Success",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'success': openapi.Schema(type=openapi.TYPE_BOOLEAN, default=True),
                        'message': openapi.Schema(type=openapi.TYPE_STRING),
                        'data': openapi.Schema(
                            type=openapi.TYPE_OBJECT,
                            properties={
                                'role': openapi.Schema(type=openapi.TYPE_STRING, default='MEMBER'),
                                'message': openapi.Schema(type=openapi.TYPE_STRING, default='Welcome Member')
                            }
                        )
                    }
                )
            )
        }
    )
    def get(self, request):
        return success_response(
            message="Welcome Member",
            data={
                "role": "MEMBER",
                "message": "Welcome Member"
            }
        )
