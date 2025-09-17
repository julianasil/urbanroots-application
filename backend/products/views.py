# backend/products/views.py
from rest_framework import viewsets, permissions, filters, serializers, status
from rest_framework.parsers import MultiPartParser, FormParser
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.response import Response
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

    def create(self, request, *args, **kwargs):
        # Create a mutable copy of the request data
        data = request.data.copy()
        
        # Add the image from request.FILES to the data dictionary
        # This is what the serializer is expecting.
        if 'image' in request.FILES:
            data['image'] = request.FILES['image']

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    # REMOVED: The temporary 'create' method with debugging has been removed.
    # The default ModelViewSet create behavior is now used, which is cleaner.

    # MODIFIED: The perform_create logic is now for validation.
    def perform_create(self, serializer):
        """
        Overrides the default create behavior to automatically assign the
        logged-in user's business profile as the seller.
        """
        # 1. Get the business profile directly from the authenticated user.
        seller_profile = self.request.user.business_profiles.first() # Use .first() assuming one for now

        # 2. Add a crucial safety check.
        if seller_profile is None:
            raise serializers.ValidationError("You must have a business profile to create a product.")
        
        # 3. Pass this profile object directly to the serializer's save method.
        # DRF is smart enough to know that this object should fill the 'seller_profile' field.
        serializer.save(seller_profile=seller_profile)