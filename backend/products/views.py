from rest_framework import viewsets, permissions, filters, serializers
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.parsers import MultiPartParser, FormParser
from django_filters.rest_framework import DjangoFilterBackend
from .models import Product
from .serializers import ProductSerializer
from users.permissions import IsSellerOrReadOnly


class IsSellerOrReadOnly(permissions.BasePermission):
    """Safe methods for anyone; writes only for authenticated sellers of this product or admin/staff."""

    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user and request.user.is_authenticated

    def has_object_permission(self, request, view, obj: Product):
        if request.method in permissions.SAFE_METHODS:
            return True
        user_profile_id = getattr(request.user, 'business_profile_id', None)
        return getattr(request.user, 'role', None) in ('admin', 'staff') or user_profile_id == obj.seller_profile_id


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.select_related('seller_profile')
    serializer_class = ProductSerializer
    permission_classes = [IsSellerOrReadOnly]
    parser_classes = [MultiPartParser, FormParser]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['seller_profile', 'unit']
    search_fields = ['name', 'description']
    ordering_fields = ['price', 'created_at']

    def perform_create(self, serializer):
        """
        Overrides the default create behavior to automatically assign the
        logged-in user's business profile as the seller.
        """
        if self.request.user.business_profile is None:
            # This is a crucial check to ensure the user has a profile.
            raise serializers.ValidationError("You must have a business profile to create a product.")
        
        serializer.save(seller_profile=self.request.user.business_profile)
