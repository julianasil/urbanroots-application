# backend/users/permissions.py
from rest_framework.permissions import BasePermission
from .models import BusinessProfile # ADDED: Import the BusinessProfile model

class IsSellerOrReadOnly(BasePermission):
    """
    Allows read-only access to anyone.
    Allows write access (like creating a product) only if the user is a member of at least one
    business profile with a business_type of 'seller' or 'both'.
    """
    def has_permission(self, request, view):
        # Allow GET, HEAD, OPTIONS requests (read-only) to anyone.
        if request.method in ['GET', 'HEAD', 'OPTIONS']:
            return True
        
        # Deny write access if the user is not authenticated.
        if not request.user or not request.user.is_authenticated:
            return False
        
        # MODIFIED: The core logic has changed completely.
        # Instead of checking a single profile, we check if ANY of the user's
        # associated business profiles meet the criteria.
        # `request.user.business_profiles` comes from the `related_name` we set in models.py.
        
        # Check if the user is a member of any business profile that is a 'seller' or 'both'.
        return request.user.business_profiles.filter(
            business_type__in=[BusinessProfile.BusinessType.SELLER, BusinessProfile.BusinessType.BOTH]
        ).exists()