# backend/users/models.py

import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser

# First, define the BusinessProfile model as it's a dependency for CustomUser.
class BusinessProfile(models.Model):
    class BusinessType(models.TextChoices):
        SELLER = 'seller', 'Seller'
        BUYER = 'buyer', 'Buyer'
        BOTH = 'both', 'Both'

    profile_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company_name = models.CharField(max_length=255, blank=True, null=True)
    contact_number = models.CharField(max_length=50)
    address = models.TextField()
    business_type = models.CharField(
        max_length=10,
        choices=BusinessType.choices,
        default=BusinessType.BUYER
    )

    def __str__(self):
        return self.company_name or f"Profile {self.profile_id}"


# Now, create the CustomUser model to match the ERD.
class CustomUser(AbstractUser):
    class Role(models.TextChoices):
        ADMIN = 'admin', 'Admin'
        STAFF = 'staff', 'Staff'
        USER = 'user', 'User'

    # Override the default integer ID with a UUID, matching the ERD's 'user_id'
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False, verbose_name='user_id')

    email = models.EmailField(unique=True)
    # Establish the One-to-One link to BusinessProfile
    business_profile = models.OneToOneField(
        BusinessProfile, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True
    )

    # Replace first_name and last_name with full_name
    full_name = models.CharField(max_length=200)
    
    # We don't need the default first_name and last_name anymore
    first_name = None
    last_name = None
    
    # Add the role field from the ERD
    role = models.CharField(
        max_length=10,
        choices=Role.choices,
        default=Role.USER
    )
    
    # Tell Django to use 'email' for login instead of 'username'
    USERNAME_FIELD = 'email'
    # 'username' and 'full_name' are now required fields when creating a user from the command line
    REQUIRED_FIELDS = ['username', 'full_name']
    
    def __str__(self):
        return self.email