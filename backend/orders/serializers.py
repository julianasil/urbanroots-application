# backend/orders/serializers.py
from rest_framework import serializers
from .models import Order, OrderItem
from products.serializers import ProductSerializer

class OrderItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    
    class Meta:
        model = OrderItem
        fields = ['product', 'quantity', 'price_at_purchase']

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = [
            'order_id', 
            'order_date', 
            'total_amount', 
            'status', 
            'shipping_address',
            'tracking_number',
            'items',
        ]
        read_only_fields = ['order_id', 'order_date', 'total_amount', 'status', 'items']

class CreateOrderSerializer(serializers.Serializer):
    cart_items = serializers.ListField(
        child=serializers.DictField()
    )
    shipping_address = serializers.CharField()