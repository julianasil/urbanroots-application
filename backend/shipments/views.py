# backend/shipments/views.py
from django.db import transaction
from django.utils import timezone
from rest_framework import generics, status, serializers, viewsets, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Shipment, LogisticsProvider
from orders.serializers import CreateShipmentSerializer, ShipmentSerializer, LogisticsProviderSerializer
from orders.models import Order, OrderItem

class LogisticsProviderViewSet(viewsets.ModelViewSet):
    """
    Allows administrators to manage the list of available logistics providers.
    """
    queryset = LogisticsProvider.objects.all()
    serializer_class = LogisticsProviderSerializer
    permission_classes = [permissions.IsAuthenticated]


class CreateShipmentView(generics.CreateAPIView):
    """
    Creates a new Shipment for a set of OrderItems from a single Order.
    This is the core of the LDMS shipment creation logic.
    """
    serializer_class = CreateShipmentSerializer
    permission_classes = [IsAuthenticated]

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        seller_profile = request.user.business_profiles.first()
        if not seller_profile:
            return Response({'error': 'User has no business profile.'}, status=status.HTTP_403_FORBIDDEN)

        # --- VALIDATION ---
        # 1. Validate the Order
        try:
            order = Order.objects.get(pk=data['order_id'])
        except Order.DoesNotExist:
            return Response({'error': 'Order not found.'}, status=status.HTTP_404_NOT_FOUND)

        # 2. Validate the Logistics Provider
        try:
            provider = LogisticsProvider.objects.get(pk=data['logistics_provider_id'])
        except LogisticsProvider.DoesNotExist:
            return Response({'error': 'Logistics provider not found.'}, status=status.HTTP_404_NOT_FOUND)

        # 3. Validate the OrderItems
        items_to_ship = OrderItem.objects.filter(
            pk__in=data['order_item_ids'],
            order=order,
            product__seller_profile=seller_profile
        )

        if len(items_to_ship) != len(data['order_item_ids']):
            raise serializers.ValidationError("One or more items are invalid, do not belong to this order, or are not sold by you.")

        for item in items_to_ship:
            if item.shipment is not None:
                raise serializers.ValidationError(f"Item '{item.product.name}' is already part of another shipment.")

        # --- EXECUTION ---
        # 1. Create the new Shipment
        new_shipment = Shipment.objects.create(
            order=order,
            seller_profile=seller_profile,
            logistics_provider=provider,
            tracking_number=data['tracking_number'],
            status=Shipment.ShipmentStatus.IN_TRANSIT,
            shipped_date=timezone.now()
        )

        # 2. Link the verified OrderItems to the new Shipment
        items_to_ship.update(shipment=new_shipment)

        # 3. (Optional but Recommended) Update the main Order status
        # Check if all items in the original order are now shipped
        total_items_in_order = order.items.count()
        shipped_items_in_order = OrderItem.objects.filter(order=order, shipment__isnull=False).count()

        if total_items_in_order == shipped_items_in_order:
            order.status = Order.OrderStatus.SHIPPED
            order.save()
        else:
            # If only some items are shipped, you might set a 'partially_shipped' status
            order.status = Order.OrderStatus.PROCESSING # Or a new 'partially_shipped' status
            order.save()
            
        # Return the details of the shipment that was just created
        response_serializer = ShipmentSerializer(new_shipment)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)
# Create your views here.

class ConfirmDeliveryView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk, format=None): # pk is the shipment_id
        try:
            shipment = Shipment.objects.get(pk=pk, order__placing_user=request.user)
            
            shipment.status = Shipment.ShipmentStatus.DELIVERED
            shipment.delivered_date = timezone.now()
            shipment.save()
            
            order = shipment.order
            if not order.shipments.exclude(status=Shipment.ShipmentStatus.DELIVERED).exists():
                order.status = Order.OrderStatus.COMPLETED
                order.save()

            return Response({'success': 'Delivery confirmed.'}, status=status.HTTP_200_OK)
        except Shipment.DoesNotExist:
            return Response({'error': 'Shipment not found or you are not the buyer.'}, status=status.HTTP_404_NOT_FOUND)