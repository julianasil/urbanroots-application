# backend/shipments/admin.py
from django.contrib import admin
from .models import LogisticsProvider, Shipment

@admin.register(LogisticsProvider)
class LogisticsProviderAdmin(admin.ModelAdmin):
    """
    Admin configuration for LogisticsProvider model.
    """
    list_display = ('name', 'tracking_url_template', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('name',)


@admin.register(Shipment)
class ShipmentAdmin(admin.ModelAdmin):
    """
    Admin configuration for the Shipment model.
    """
    list_display = ('shipment_id', 'order', 'seller_profile', 'logistics_provider', 'status', 'shipped_date')
    list_filter = ('status', 'logistics_provider', 'seller_profile')
    search_fields = ('shipment_id', 'order__order_id', 'tracking_number')
    ordering = ('-shipped_date',)
    
    # Make foreign key fields read-only in the admin to prevent accidental changes
    readonly_fields = ('order', 'seller_profile')