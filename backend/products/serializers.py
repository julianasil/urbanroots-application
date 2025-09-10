from rest_framework import serializers
from .models import Product
from users.serializers import BusinessProfileSerializer 


class ProductSerializer(serializers.ModelSerializer):
    seller_profile = BusinessProfileSerializer(read_only=True)

    class Meta:
        model = Product
        fields = [
            'product_id', 
            'seller_profile', 
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
        read_only_fields = ['product_id', 'seller_profile', 'created_at', 'updated_at']
