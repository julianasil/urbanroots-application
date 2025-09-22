# backend/shipments/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CreateShipmentView, LogisticsProviderViewSet, ConfirmDeliveryView

router = DefaultRouter()
router.register(r'providers', LogisticsProviderViewSet, basename='logistics-provider')

urlpatterns = [
    path('create/', CreateShipmentView.as_view(), name='shipment-create'),
    path('', include(router.urls)),
    path('<uuid:pk>/confirm-delivery/', ConfirmDeliveryView.as_view(), name='shipment-confirm-delivery'),
]
