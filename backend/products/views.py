# backend/products/views.py
from rest_framework import viewsets, permissions, filters, serializers
from rest_framework.parsers import MultiPartParser, FormParser
from django_filters.rest_framework import DjangoFilterBackend
from .models import Product
from .serializers import ProductSerializer

# MODIFIED: This permission class now uses the correct 'team membership' logic.
class IsSellerOrReadOnly(permissions.BasePermission):
    """
    Allows read-only access for anyone.
    Allows write access (update/delete) only for authenticated users who are members
    of the product's associated business profile.
    """
    def has_permission(self, request, view):
        # Allow read-only methods for anyone.
        if request.method in permissions.SAFE_METHODS:
            return True
        # For write methods, just check if the user is logged in.
        # The detailed check will happen in has_object_permission.
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj: Product):
        # Read-only methods are always allowed.
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # For write methods, check if the authenticated user is a member of the
        # business profile that this product belongs to.
        if request.user and request.user.is_authenticated:
            # obj.seller_profile is the BusinessProfile linked to the product.
            # .members.all() gives us the list of user members for that business.
            return request.user in obj.seller_profile.members.all()
        
        return False


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.select_related('seller_profile')
    serializer_class = ProductSerializer
    permission_classes = [IsSellerOrReadOnly]
    parser_classes = [MultiPartParser, FormParser]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['seller_profile', 'unit']
    search_fields = ['name', 'description']
    ordering_fields = ['price', 'created_at']

    # REMOVED: The temporary 'create' method with debugging has been removed.
    # The default ModelViewSet create behavior is now used, which is cleaner.

    # MODIFIED: The perform_create logic is now for validation.
    def perform_create(self, serializer):
        """
        Validates that the user is a member of the business profile they are
        trying to assign this product to.
        """
        # The serializer's validated_data will contain the business profile instance
        # that the frontend sent the ID for.
        seller_profile_to_assign = serializer.validated_data['seller_profile']
        
        # Get all the business profiles the current user is a member of.
        user_businesses = self.request.user.business_profiles.all()

        # Check if the profile they're trying to assign is in their list of memberships.
        if seller_profile_to_assign not in user_businesses:
            raise serializers.ValidationError(
                "You are not a member of this business profile and cannot add products to it."
            )
        
        # If the check passes, save the serializer as normal.
        # The serializer will automatically handle linking the validated seller_profile.
        serializer.save()