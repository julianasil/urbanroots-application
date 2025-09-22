# reports/urls.py
from django.urls import path
# --- NEW: Import the new view ---
from .views import SellerReportSummaryView, DailySalesSummaryView

urlpatterns = [
    # This is your existing URL, no changes needed here
    path('seller-summary/', SellerReportSummaryView.as_view(), name='seller-report-summary'),
    
    # --- NEW: Add this line for the chart data endpoint ---
    # This will be accessible at /api/reports/daily-summary/
    path('daily-summary/', DailySalesSummaryView.as_view(), name='daily-report-summary'),
]