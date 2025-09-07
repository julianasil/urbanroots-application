from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import StockLogViewSet, AdjustStockAPIView

router = DefaultRouter()
router.register(r'logs', StockLogViewSet, basename='stocklog')

urlpatterns = [
    path('', include(router.urls)),
    path('adjust/', AdjustStockAPIView.as_view(), name='adjust-stock'),
]
