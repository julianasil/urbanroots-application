from rest_framework import serializers
from .models import Product


class ProductSerializer(serializers.ModelSerializer):
    seller_profile = serializers.PrimaryKeyRelatedField(read_only=True)
    seller_profile_id = serializers.UUIDField(write_only=True, required=True)

    class Meta:
        model = Product
        fields = [
            'product_id',
            'seller_profile',
            'seller_profile_id',
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

    def create(self, validated_data):
        seller_id = validated_data.pop('seller_profile_id')
        validated_data['seller_profile_id'] = seller_id
        return super().create(validated_data)

    def update(self, instance, validated_data):
        # prevent changing the seller via updates (adjust if your business rules differ)
        validated_data.pop('seller_profile_id', None)
        return super().update(instance, validated_data)
