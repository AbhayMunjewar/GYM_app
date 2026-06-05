from accounts.models import UserRole

def is_owner(user):
    """
    Checks if a user is authenticated and has the OWNER role.
    """
    return bool(user and user.is_authenticated and user.role == UserRole.OWNER)

def is_trainer(user):
    """
    Checks if a user is authenticated and has the TRAINER role.
    """
    return bool(user and user.is_authenticated and user.role == UserRole.TRAINER)

def is_member(user):
    """
    Checks if a user is authenticated and has the MEMBER role.
    """
    return bool(user and user.is_authenticated and user.role == UserRole.MEMBER)
