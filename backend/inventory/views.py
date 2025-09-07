from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import StockLog
from .serializers import StockLogSerializer
from .services import adjust_stock


class StockLogViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = StockLog.objects.select_related('product', 'created_by').all()
    serializer_class = StockLogSerializer
    permission_classes = [IsAuthenticated]


class AdjustStockAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, format=None):
        """
        POST body:
        {
          "product": "<uuid>",
          "change": -3,     # negative to reduce, positive to add
          "reason": "Manual correction"
        }
        """
        data = request.data
        product_id = data.get('product')

        try:
            change = int(data.get('change', 0))
        except (TypeError, ValueError):
            return Response({'detail': 'Invalid change value'}, status=status.HTTP_400_BAD_REQUEST)

        if change == 0:
            return Response({'detail': 'change must be non-zero'}, status=status.HTTP_400_BAD_REQUEST)

        reason = data.get('reason', '')

        try:
            log = adjust_stock(product_id=product_id, change=change, user=request.user, reason=reason)
        except ValueError as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        return Response(StockLogSerializer(log).data, status=status.HTTP_201_CREATED)
