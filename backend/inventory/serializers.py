from rest_framework import serializers
from .models import StockLog


class StockLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = StockLog
        fields = ['log_id', 'product', 'change', 'reason', 'created_by', 'created_at']
        read_only_fields = ['log_id', 'created_by', 'created_at']
