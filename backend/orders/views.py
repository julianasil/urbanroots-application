# backend/orders/views.py
from django.db import transaction
from rest_framework import serializers
from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Order, OrderItem
from products.models import Product
from .serializers import OrderSerializer, CreateOrderSerializer

class OrderListCreateView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Users can only see orders where they are the buyer
        if hasattr(self.request.user, 'business_profiles') and self.request.user.business_profiles:
             return Order.objects.filter(buyer_profile=self.request.user.business_profiles.first()).order_by('-order_date')
        return Order.objects.none() 

    def get_serializer_class(self):
        # Use different serializers for reading (GET) vs. writing (POST)
        if self.request.method == 'POST':
            return CreateOrderSerializer
        return OrderSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        cart_items = serializer.validated_data['cart_items']
        shipping_address = serializer.validated_data['shipping_address']
        buyer_profile = request.user.business_profiles.first()
        if not buyer_profile:
            return Response({'error': 'User has no business profile to place an order.'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            total_amount = 0
            order_items_to_create = []
            products_to_update = []

            for item_data in cart_items:
                product = Product.objects.get(pk=item_data['product_id'])
                quantity = item_data['quantity']
                
                if product.stock_quantity < quantity:
                    raise serializers.ValidationError(f"Not enough stock for {product.name}.")
                
                price = product.price
                total_amount += price * quantity
                
                product.stock_quantity -= quantity
                products_to_update.append(product)

                order_items_to_create.append(
                    OrderItem(product=product, quantity=quantity, price_at_purchase=price)
                )

            order = Order.objects.create(
                placing_user=request.user,
                buyer_profile=buyer_profile, # Use the fetched profile
                shipping_address=shipping_address,
                total_amount=total_amount
            )

            for item in order_items_to_create:
                item.order = order
            
            OrderItem.objects.bulk_create(order_items_to_create)
            Product.objects.bulk_update(products_to_update, ['stock_quantity'])

            final_serializer = OrderSerializer(order)
            return Response(final_serializer.data, status=status.HTTP_201_CREATED)

        except Product.DoesNotExist:
            return Response({'error': 'A product in your cart was not found.'}, status=status.HTTP_404_NOT_FOUND)
        except serializers.ValidationError as e:
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
        
class CancelOrderView(APIView):
    """
    An endpoint for a user to cancel their own order.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, pk, format=None):
        try:
            # Find the order by its primary key (pk) and ensure it belongs to the user
            order = Order.objects.get(pk=pk, placing_user=request.user)
            
            # Business Logic: Only allow cancellation if the order is 'pending'.
            if order.status != Order.OrderStatus.PENDING:
                return Response(
                    {'error': f'Cannot cancel an order with status "{order.status}".'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            order.status = Order.OrderStatus.CANCELLED
            
            with transaction.atomic():
                # Loop through all items in the order
                for item in order.items.all():
                    # CRITICAL: Check if the product associated with the order item still exists
                    if item.product:
                        # Lock the product row to prevent race conditions during the update
                        product = Product.objects.select_for_update().get(pk=item.product.pk)
                        product.stock_quantity += item.quantity
                        product.save()
                
                # After updating all product stocks, save the order's new status.
                order.save()

            # Return the updated order details
            serializer = OrderSerializer(order)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except Order.DoesNotExist:
            return Response(
                {'error': 'Order not found or you do not have permission to cancel it.'},
                status=status.HTTP_404_NOT_FOUND
            )
        
class OrderDetailView(generics.RetrieveAPIView):
    """
    Provides the details of a single order.
    Ensures the user requesting the order is the one who placed it.
    """
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # A user can only view orders where their profile is the buyer
        if hasattr(self.request.user, 'business_profiles') and self.request.user.business_profiles:
            # Assuming a user has one primary business profile for now
            return Order.objects.filter(buyer_profile=self.request.user.business_profiles.first())
        
        # If the user has no business profile, they can't have any orders.
        return Order.objects.none()
    
class SalesListView(generics.ListAPIView):
    """
    Provides a list of all orders that contain at least one item sold by
    the currently authenticated seller's business profile.
    """
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        print(f"\n--- DEBUG: SalesListView for user: {user.email} ---")

        # Check 1: Does the user have a business profile?
        if not hasattr(user, 'business_profiles') or not user.business_profiles.first():
            print(">>> DEBUG: User has NO business profile. Returning empty.")
            return Order.objects.none()
        
        seller_profile = user.business_profiles.first()
        print(f">>> DEBUG: User's Business Profile ID: {seller_profile.profile_id}")

        # Check 2: Are there any OrderItems sold by this profile?
        items_sold_by_user = OrderItem.objects.filter(
            product__seller_profile=seller_profile
        )
        print(f">>> DEBUG: Found {items_sold_by_user.count()} OrderItem(s) sold by this profile.")
        if not items_sold_by_user.exists():
            print(">>> DEBUG: No items found for this seller. Returning empty.")
            return Order.objects.none()

        # Check 3: What are the unique Order IDs for these items?
        order_ids_with_seller_items = items_sold_by_user.values_list(
            'order_id', flat=True
        ).distinct()
        print(f">>> DEBUG: Unique Order IDs containing seller's items: {list(order_ids_with_seller_items)}")

        # Final Query: Fetch the full Order objects
        queryset = Order.objects.filter(pk__in=order_ids_with_seller_items).order_by('-order_date')
        print(f">>> DEBUG: Final query found {queryset.count()} Order(s).")
        print("---------------------------------------------------\n")
        
        return queryset
    
class SaleDetailView(generics.RetrieveAPIView):
    """
    Provides the details of a single order from a seller's perspective.
    Grants access if the order contains any items sold by the authenticated seller.
    """
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        
        if not hasattr(user, 'business_profiles') or not user.business_profiles.first():
            return Order.objects.none()
        
        seller_profile = user.business_profiles.first()

        # This is the key security check for sellers:
        # Find all Order IDs that contain items sold by this seller.
        order_ids_with_seller_items = OrderItem.objects.filter(
            product__seller_profile=seller_profile
        ).values_list('order_id', flat=True).distinct()

        # The seller is only allowed to see orders from that list.
        return Order.objects.filter(pk__in=order_ids_with_seller_items)