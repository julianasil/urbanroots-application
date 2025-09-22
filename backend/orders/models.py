import uuid
from django.db import models
from django.conf import settings
from users.models import BusinessProfile
from products.models import Product

class Order(models.Model):
    class OrderStatus(models.TextChoices):
        PENDING = 'pending', 'Pending'
        PROCESSING = 'processing', 'Processing'
        SHIPPED = 'shipped', 'Shipped'
        COMPLETED = 'completed', 'Completed'
        CANCELLED = 'cancelled', 'Cancelled'

    order_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    placing_user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name='orders_placed')
    buyer_profile = models.ForeignKey(BusinessProfile, on_delete=models.SET_NULL, null=True, blank=True, related_name='orders_as_buyer')
    order_date = models.DateTimeField(auto_now_add=True)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=10, choices=OrderStatus.choices, default=OrderStatus.PENDING)
    shipping_address = models.TextField()
    tracking_number = models.CharField(max_length=100, blank=True, null=True)
    #estimated_delivery_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        ordering = ['-order_date']

    def __str__(self):
        return f"Order {self.order_id} - {self.status}"

class OrderItem(models.Model):
    order_item_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(Product, on_delete=models.SET_NULL, null=True)
    seller_profile = models.ForeignKey(BusinessProfile, on_delete=models.SET_NULL, null=True)
    quantity = models.IntegerField()
    price_at_purchase = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, default='processing')
    shipment = models.ForeignKey('shipments.Shipment', on_delete=models.SET_NULL, null=True, blank=True, related_name='items')

    def __str__(self):
        return f"{self.quantity} x {self.product.name if self.product else 'Deleted Product'}"