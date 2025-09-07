from django.db import transaction
from django.db.models import F
from django.core.exceptions import ObjectDoesNotExist
from .models import StockLog


def adjust_stock(product_id, change: int, user=None, reason: str = '') -> StockLog:
    """
    Atomically adjust stock for a product and create a StockLog.

    Args:
        product_id: UUID/PK of products.Product
        change: int (positive to add, negative to remove)
        user: User making the change (optional)
        reason: string reason

    Raises:
        ValueError: if product not found or insufficient stock
    """
    from products.models import Product  # local import to avoid app loading cycles

    with transaction.atomic():
        try:
            product = Product.objects.select_for_update().get(product_id=product_id)
        except ObjectDoesNotExist:
            raise ValueError('Product not found')

        if change < 0 and (product.stock_quantity + change) < 0:
            raise ValueError('Insufficient stock')

        product.stock_quantity = F('stock_quantity') + change
        product.save()
        product.refresh_from_db()

        return StockLog.objects.create(
            product=product,
            change=change,
            reason=reason or '',
            created_by=user
        )
