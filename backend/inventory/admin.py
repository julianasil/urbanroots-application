from django.contrib import admin
from .models import StockLog


@admin.register(StockLog)
class StockLogAdmin(admin.ModelAdmin):
    list_display = ('log_id', 'product', 'change', 'reason', 'created_by', 'created_at')
    search_fields = ('product__name', 'reason', 'created_by__username')
    list_filter = ('created_at', 'created_by')
    ordering = ('-created_at',)
