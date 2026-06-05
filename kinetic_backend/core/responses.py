from rest_framework.response import Response
from rest_framework import status

def success_response(message="Success", data=None, status_code=status.HTTP_200_OK):
    return Response({
        "success": True,
        "message": message,
        "data": data if data is not None else {}
    }, status=status_code)

def failure_response(message="Failure", errors=None, status_code=status.HTTP_400_BAD_REQUEST):
    # Standardize errors to be a list
    if errors is None:
        errors = []
    elif isinstance(errors, dict):
        # Flatten dict of lists/errors into a unified list of objects or messages
        formatted_errors = []
        for field, error_list in errors.items():
            if isinstance(error_list, list):
                for err in error_list:
                    formatted_errors.append({"field": field, "message": str(err)})
            else:
                formatted_errors.append({"field": field, "message": str(error_list)})
        errors = formatted_errors
    elif not isinstance(errors, list):
        errors = [{"message": str(errors)}]

    return Response({
        "success": False,
        "message": message,
        "errors": errors
    }, status=status_code)
