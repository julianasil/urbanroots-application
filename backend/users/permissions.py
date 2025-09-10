# backend/users/permissions.py
from rest_framework.permissions import BasePermission

class IsSellerOrReadOnly(BasePermission):
    """
    Allows read-only access to anyone, but only allows write access
    to users who are sellers or both.
    """
def has_permission(self, request, view):
        # Allow GET, HEAD, OPTIONS requests (read-only) to anyone
        if request.method in ['GET', 'HEAD', 'OPTIONS']:
            return True
        
        # Deny write access if user is not authenticated
        if not request.user.is_authenticated:
            return False
        
        # Deny write access if user has no business profile
        if not hasattr(request.user, 'business_profile') or request.user.business_profile is None:
            return False

        # Allow write access only if the business type is 'seller' or 'both'
        return request.user.business_profile.business_type in ['seller', 'both']