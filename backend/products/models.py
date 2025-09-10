import uuid
from django.db import models
from users.models import BusinessProfile

class Product(models.Model):
    # These fields match your ERD exactly
    product_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # This is the correct link according to your ERD
    seller_profile = models.ForeignKey(BusinessProfile, on_delete=models.CASCADE)
    
    name = models.CharField(max_length=255)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    unit = models.CharField(max_length=50)
    stock_quantity = models.IntegerField()
    image = models.ImageField(upload_to='product_images/', blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name