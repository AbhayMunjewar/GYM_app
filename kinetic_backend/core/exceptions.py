import logging
from rest_framework.views import exception_handler
from rest_framework import exceptions as drf_exceptions
from django.core.exceptions import ValidationError as DjangoValidationError
from core.responses import failure_response
from rest_framework import status

logger = logging.getLogger(__name__)

def custom_exception_handler(exc, context):
    # Handle Django Validation errors natively in DRF
    if isinstance(exc, DjangoValidationError):
        data = exc.message_dict if hasattr(exc, 'message_dict') else exc.messages
        exc = drf_exceptions.ValidationError(detail=data)

    response = exception_handler(exc, context)

    if response is not None:
        message = "A client request error occurred."
        errors = response.data

        if isinstance(exc, drf_exceptions.ValidationError):
            message = "Validation failed for one or more fields."
        elif isinstance(exc, drf_exceptions.NotAuthenticated):
            message = "Authentication credentials were not provided."
        elif isinstance(exc, drf_exceptions.PermissionDenied):
            # Preserve custom permission denied messages
            if hasattr(exc, 'detail') and isinstance(exc.detail, str) and exc.detail != "You do not have permission to perform this action.":
                message = str(exc.detail)
            else:
                message = "You do not have permission to access this resource."
        elif hasattr(exc, 'detail') and isinstance(exc.detail, str):
            message = exc.detail

        # Format using standard failure_response utility
        return failure_response(
            message=message,
            errors=errors,
            status_code=response.status_code
        )

    # Capture 500 error logs and standardize output
    logger.exception("Unhandled server exception: %s", str(exc))
    return failure_response(
        message="An unexpected server error occurred.",
        errors=[{"message": "Please contact system administrator."}],
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
    )
