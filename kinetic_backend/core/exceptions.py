import logging
from django.db import IntegrityError, DatabaseError as DjangoDatabaseError
from django.core.exceptions import ValidationError as DjangoValidationError
from rest_framework.views import exception_handler
from rest_framework import exceptions as drf_exceptions
from rest_framework import status
from core.responses import failure_response

logger = logging.getLogger(__name__)

# Custom SaaS Enterprise Exceptions
class SaaSBaseException(Exception):
    status_code = status.HTTP_400_BAD_REQUEST
    message = "A platform error occurred."
    
    def __init__(self, message=None, errors=None, status_code=None):
        if message:
            self.message = message
        if status_code:
            self.status_code = status_code
        self.errors = errors or []
        super().__init__(self.message)

class APIError(SaaSBaseException):
    status_code = status.HTTP_400_BAD_REQUEST
    message = "API request failed."

class ValidationError(SaaSBaseException):
    status_code = status.HTTP_400_BAD_REQUEST
    message = "Validation check failed."

class AuthenticationError(SaaSBaseException):
    status_code = status.HTTP_401_UNAUTHORIZED
    message = "Authentication credentials invalid."

class PermissionError(SaaSBaseException):
    status_code = status.HTTP_403_FORBIDDEN
    message = "Access permission denied."

class SaaSDatabaseError(SaaSBaseException):
    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    message = "Database transactional error."

class BackgroundJobError(SaaSBaseException):
    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    message = "Background processing task failed."


def custom_exception_handler(exc, context):
    """
    Unified Exception Handler mapping standard and custom exceptions into consistent JSON format.
    """
    # 1. Map custom SaaS exceptions to DRF format
    if isinstance(exc, SaaSBaseException):
        return failure_response(
            message=exc.message,
            errors=exc.errors if exc.errors else [{"message": exc.message}],
            status_code=exc.status_code
        )

    # 2. Handle native Django validation error
    if isinstance(exc, DjangoValidationError):
        data = exc.message_dict if hasattr(exc, 'message_dict') else exc.messages
        exc = drf_exceptions.ValidationError(detail=data)

    # 3. Handle Database exceptions (Integrity violations like unique constraints, foreign keys)
    if isinstance(exc, (IntegrityError, DjangoDatabaseError)):
        logger.exception("Database transaction error: %s", str(exc))
        return failure_response(
            message="Database validation or transactional constraint failed.",
            errors=[{"message": str(exc)}],
            status_code=status.HTTP_409_CONFLICT if isinstance(exc, IntegrityError) else status.HTTP_500_INTERNAL_SERVER_ERROR
        )

    # 4. Standard DRF exceptions handling
    response = exception_handler(exc, context)

    if response is not None:
        message = "A client request error occurred."
        errors = response.data

        if isinstance(exc, drf_exceptions.ValidationError):
            message = "Validation failed for one or more fields."
        elif isinstance(exc, drf_exceptions.NotAuthenticated):
            message = "Authentication credentials were not provided."
        elif isinstance(exc, drf_exceptions.PermissionDenied):
            if hasattr(exc, 'detail') and isinstance(exc.detail, str) and exc.detail != "You do not have permission to perform this action.":
                message = str(exc.detail)
            else:
                message = "You do not have permission to access this resource."
        elif hasattr(exc, 'detail') and isinstance(exc.detail, str):
            message = exc.detail

        return failure_response(
            message=message,
            errors=errors,
            status_code=response.status_code
        )

    # 5. Capture 500 error logs and standardize output
    logger.exception("Unhandled server exception: %s", str(exc))
    return failure_response(
        message="An unexpected server error occurred.",
        errors=[{"message": "Please contact system administrator."}],
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
    )
