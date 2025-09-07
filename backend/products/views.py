from rest_framework import viewsets, permissions, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Product
from .serializers import ProductSerializer


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
    queryset = Product.objects.select_related('seller_profile').all()
    serializer_class = ProductSerializer
    permission_classes = [IsSellerOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['seller_profile', 'is_active', 'unit']
    search_fields = ['name', 'description']
    ordering_fields = ['price', 'created_at']
