# backend/products/serializers.py
from rest_framework import serializers
from .models import Product
from users.models import BusinessProfile # Import the BusinessProfile model
from users.serializers import BusinessProfileSerializer # Import the BusinessProfileSerializer

class ProductSerializer(serializers.ModelSerializer):
    # This field will be used for GET requests to show the nested details of the seller.
    # It's read-only. We are renaming it for clarity.
    seller_profile = BusinessProfileSerializer(read_only=True)

    image = serializers.ImageField(max_length=None, use_url=True, required=False, allow_null=True)

    class Meta:
        model = Product
        fields = [
            'product_id', 
            'seller_profile',           # The write-only ID field for creating/updating
            'name', 
            'description', 
            'price', 
            'unit', 
            'stock_quantity', 
            'image', 
            'is_active',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['product_id', 'created_at', 'updated_at']