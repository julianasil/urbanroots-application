import uuid
from django.db import models
from django.conf import settings  # ✅ for linking to your CustomUser

class Product(models.Model):
    product_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # ❌ Temporarily removing BusinessProfile (business app not ready yet)
    # seller_profile = models.ForeignKey(
    #     'business.BusinessProfile',
    #     on_delete=models.CASCADE,
    #     related_name='products'
    # )

    # ✅ Temporary replacement: link to a user (optional)
    seller = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='products'
    )

    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    unit = models.CharField(max_length=50)
    stock_quantity = models.IntegerField(default=0)
    image = models.ImageField(upload_to='product_images/', blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} ({self.product_id})"
