# backend/orders/serializers.py
from rest_framework import serializers
from .models import Order, OrderItem
from shipments.models import Shipment, LogisticsProvider
from products.serializers import ProductSerializer
from users.serializers import BusinessProfileSerializer

class LogisticsProviderSerializer(serializers.ModelSerializer):
    class Meta:
        model = LogisticsProvider
        fields = ['provider_id', 'name', 'tracking_url_template']


class ShipmentItemSerializer(serializers.ModelSerializer):
    """ A simple serializer to show which items are in a shipment. """
    product = ProductSerializer(read_only=True)
    class Meta:
        model = OrderItem
        fields = ['order_item_id', 'product', 'quantity', 'price_at_purchase']


class ShipmentSerializer(serializers.ModelSerializer):
    items = ShipmentItemSerializer(many=True, read_only=True)
    logistics_provider = LogisticsProviderSerializer(read_only=True)
    class Meta:
        model = Shipment
        fields = [
            'shipment_id', 'order', 'seller_profile', 'logistics_provider',
            'tracking_number', 'status', 'shipped_date', 'items'
        ]


# --- This is the key serializer for our view ---
class CreateShipmentSerializer(serializers.Serializer):
    """
    Serializer for validating the data needed to create a shipment.
    """
    order_id = serializers.UUIDField(required=True)
    order_item_ids = serializers.ListField(
        child=serializers.UUIDField(),
        allow_empty=False,
        required=True
    )
    logistics_provider_id = serializers.UUIDField(required=True)
    tracking_number = serializers.CharField(max_length=100, required=True)

class OrderItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    seller_profile = BusinessProfileSerializer(read_only=True)
    
    class Meta:
        model = OrderItem
        fields = [
            'order_item_id', 
            'product', 
            'seller_profile', 
            'quantity', 
            'price_at_purchase', 
            'status'
        ]

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    buyer_profile = BusinessProfileSerializer(read_only=True)
    shipments = ShipmentSerializer(many=True, read_only=True)

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
            'buyer_profile',
            'shipments',
        ]
        read_only_fields = ['order_id', 'order_date', 'total_amount', 'status', 'items']

class CreateOrderSerializer(serializers.Serializer):
    cart_items = serializers.ListField(
        child=serializers.DictField(), required=True
    )
    shipping_address = serializers.CharField()