# backend/shipments/models.py
import uuid
from django.db import models
from users.models import BusinessProfile

class LogisticsProvider(models.Model):
    provider_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    tracking_url_template = models.URLField(max_length=255, blank=True, help_text="e.g., https://tracker.com?tn=")
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.name

class Shipment(models.Model):
    class ShipmentStatus(models.TextChoices):
        PREPARING = 'preparing', 'Preparing'
        IN_TRANSIT = 'in_transit', 'In Transit'
        DELIVERED = 'delivered', 'Delivered'
        FAILED = 'failed', 'Failed Delivery'

    shipment_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey('orders.Order', on_delete=models.CASCADE, related_name='shipments')
    seller_profile = models.ForeignKey(BusinessProfile, on_delete=models.CASCADE, related_name='shipments')
    logistics_provider = models.ForeignKey(LogisticsProvider, on_delete=models.SET_NULL, null=True, blank=True)
    tracking_number = models.CharField(max_length=100, blank=True)
    status = models.CharField(max_length=20, choices=ShipmentStatus.choices, default=ShipmentStatus.PREPARING)
    shipped_date = models.DateTimeField(null=True, blank=True)
    delivered_date = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Shipment for Order {self.order.order_id} by {self.seller_profile.company_name}"