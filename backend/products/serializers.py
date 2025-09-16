# backend/products/serializers.py
from rest_framework import serializers
from .models import Product
from users.models import BusinessProfile # Import the BusinessProfile model
from users.serializers import BusinessProfileSerializer # Import the BusinessProfileSerializer

class ProductSerializer(serializers.ModelSerializer):
    # This field will be used for GET requests to show the nested details of the seller.
    # It's read-only. We are renaming it for clarity.
    seller_profile_details = BusinessProfileSerializer(source='seller_profile', read_only=True)

    # This field will be used for POST/PUT requests (write operations).
    # It tells DRF to expect a UUID (the primary key) for the seller_profile.
    # Your Flutter app will send the profile_id here when creating a product.
    seller_profile = serializers.PrimaryKeyRelatedField(
        queryset=BusinessProfile.objects.all(),
        write_only=True
    )

    image = serializers.ImageField(max_length=None, use_url=True, required=False, allow_null=True)

    class Meta:
        model = Product
        fields = [
            'product_id', 
            'seller_profile',           # The write-only ID field for creating/updating
            'seller_profile_details',   # The read-only nested object field for reading
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