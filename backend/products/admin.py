from django.contrib import admin
from .models import Product


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'seller_profile', 'price', 'stock_quantity', 'is_active', 'created_at', 'updated_at')
    list_filter = ('is_active', 'seller_profile__business_type')
    search_fields = ('name', 'description', 'seller_profile__company_name')
    ordering = ('-is_active', 'name')
