# reports/views.py

from datetime import timedelta
from django.utils import timezone
from django.db.models.functions import TruncDate
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from django.db.models import Sum, F

# Import your specific models
from products.models import Product
from orders.models import OrderItem
from users.models import BusinessProfile

# --- (Your existing, working view. No changes have been made here.) ---
class SellerReportSummaryView(APIView):
    """
    Provides a detailed summary report for the logged-in seller, aggregating
    data based on their specific products.
    """
    # permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        seller_profile = request.user.business_profiles.first()

        if not seller_profile:
            return Response(
                {"error": "No business profile associated with this user."},
                status=status.HTTP_403_FORBIDDEN
            )

        seller_order_items = OrderItem.objects.filter(
            product__seller_profile=seller_profile
        )

        if not seller_order_items.exists():
            return Response({
                "message": "No sales data available yet.",
                "summary": {
                    "total_revenue": 0,
                    "products_sold": 0,
                    "total_orders": 0,
                },
                "top_products": [],
            }, status=status.HTTP_200_OK)

        total_revenue = seller_order_items.aggregate(
            total=Sum('price_at_purchase')
        )['total'] or 0
        total_orders_count = seller_order_items.values('order').distinct().count()
        products_sold_count = seller_order_items.values('product').distinct().count()

        top_products = seller_order_items.values(
            'product__name'
        ).annotate(
            product_name=F('product__name'),
            total_quantity=Sum('quantity')
        ).order_by(
            '-total_quantity'
        ).values(
            'product_name', 'total_quantity'
        )[:5]

        report_data = {
            'summary': {
                'total_revenue': total_revenue,
                'total_orders': total_orders_count,
                'products_sold': products_sold_count,
            },
            'top_products': list(top_products),
        }

        return Response(report_data, status=status.HTTP_200_OK)


# --- NEW: This class was missing. It provides the data for the sales chart. ---
class DailySalesSummaryView(APIView):
    """
    Provides a daily summary of sales revenue for the logged-in seller
    for the last 30 days, suitable for a chart.
    """
    # permission_classes = [IsAuthenticated] # Uncomment when ready for auth

    def get(self, request, *args, **kwargs):
        # 1. Identify the seller's profile
        seller_profile = request.user.business_profiles.first()
        if not seller_profile:
            return Response(
                {"error": "No business profile associated with this user."},
                status=status.HTTP_403_FORBIDDEN
            )

        # 2. Define the date range for the report (last 30 days)
        end_date = timezone.now()
        start_date = end_date - timedelta(days=30)

        # 3. The Core Query: Filter, Group, and Aggregate sales by day
        daily_sales = OrderItem.objects.filter(
            product__seller_profile=seller_profile,
            order__order_date__gte=start_date 
        ).annotate(
            date=TruncDate('order__order_date')
        ).values(
            'date'
        ).annotate(
            revenue=Sum('price_at_purchase')
        ).order_by(
            'date'
        ).values(
            'date', 'revenue'
        )

        # 4. Return the data as a list of dictionaries
        return Response(list(daily_sales), status=status.HTTP_200_OK)