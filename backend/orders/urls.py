# backend/orders/urls.py
from django.urls import path
from .views import OrderListCreateView, CancelOrderView, OrderDetailView, SalesListView, SaleDetailView, ManageSaleView

urlpatterns = [
    path('', OrderListCreateView.as_view(), name='order-list-create'),
    path('<uuid:pk>/', OrderDetailView.as_view(), name='order-detail'),
    path('<uuid:pk>/cancel/', CancelOrderView.as_view(), name='order-cancel'),
    path('sales/', SalesListView.as_view(), name='sales-list'),
    path('sales/<uuid:pk>/', SaleDetailView.as_view(), name='sale-detail'),
    path('sales/<uuid:pk>/manage/', ManageSaleView.as_view(), name='sale-manage'),
]