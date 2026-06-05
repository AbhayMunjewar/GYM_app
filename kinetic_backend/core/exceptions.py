import logging
from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status

logger = logging.getLogger(__name__)

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None:
        # Standardize DRF exceptions
        details = response.data
        message = "A validation or client error occurred."
        
        if isinstance(details, dict):
            if 'detail' in details:
                message = details.pop('detail')
            elif len(details) > 0:
                message = "Validation failed for one or more fields."
        elif isinstance(details, list):
            message = details[0]

        response.data = {
            "success": False,
            "error": {
                "code": exc.__class__.__name__,
                "message": message,
                "details": details if details else None
            }
        }
    else:
        # Log unhandled exceptions (internal server errors)
        logger.exception("Internal Server Error: %s", str(exc))
        response = Response(
            {
                "success": False,
                "error": {
                    "code": "InternalServerError",
                    "message": "An unexpected internal server error occurred.",
                    "details": None
                }
            },
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

    return response
