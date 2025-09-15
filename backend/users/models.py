# backend/users/models.py

import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser

# The BusinessProfile model remains unchanged.
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
    members = models.ManyToManyField(
        'CustomUser',
        related_name='business_profiles',
        blank=True
    )

    def __str__(self):
        return self.company_name or f"Profile {self.profile_id}"


# --- UPDATED CustomUser Model ---
class CustomUser(AbstractUser):
    class Role(models.TextChoices):
        ADMIN = 'admin', 'Admin'
        STAFF = 'staff', 'Staff'
        USER = 'user', 'User'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False, verbose_name='user_id')
    email = models.EmailField(unique=True)
    
    # --- ADDED FIELDS ---
    # Profile picture. Requires Pillow to be installed: `pip install Pillow`
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)
    bio = models.TextField(max_length=500, blank=True)
    phone_number = models.CharField(max_length=20, blank=True)

    # --- MODIFICATIONS ---
    # We will now use Django's built-in first_name and last_name fields.
    # So, we remove the `first_name = None` and `last_name = None` overrides.
    # We also remove the custom `full_name` field.
    # `first_name` and `last_name` are already part of the parent `AbstractUser`.
    
    role = models.CharField(
        max_length=10,
        choices=Role.choices,
        default=Role.USER
    )
    
    USERNAME_FIELD = 'email'
    # Update REQUIRED_FIELDS to use first_name and last_name
    REQUIRED_FIELDS = ['username', 'first_name', 'last_name']
    
    def __str__(self):
        return self.email

    # ADDED: A property to easily get the user's full name.
    @property
    def full_name(self):
        "Returns the user's full name."
        return f"{self.first_name} {self.last_name}".strip()