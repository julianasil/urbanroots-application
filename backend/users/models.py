# backend/users/models.py

import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser

# The BusinessProfile model is now the primary place for the relationship.
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

    # ADDED: A ManyToManyField to create a "team" of members for this business.
    # We use a string 'CustomUser' because CustomUser is defined later in the file.
    members = models.ManyToManyField(
        'CustomUser',
        related_name='business_profiles',
        blank=True
    )

    def __str__(self):
        return self.company_name or f"Profile {self.profile_id}"


# The CustomUser model is now simplified.
class CustomUser(AbstractUser):
    class Role(models.TextChoices):
        ADMIN = 'admin', 'Admin'
        STAFF = 'staff', 'Staff'
        USER = 'user', 'User'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False, verbose_name='user_id')
    email = models.EmailField(unique=True)
    
    # REMOVED: The OneToOneField that was causing the limitation.
    # business_profile = models.OneToOneField(
    #     BusinessProfile, 
    #     on_delete=models.SET_NULL, 
    #     null=True, 
    #     blank=True
    # )

    full_name = models.CharField(max_length=200)
    first_name = None
    last_name = None
    
    role = models.CharField(
        max_length=10,
        choices=Role.choices,
        default=Role.USER
    )
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username', 'full_name']
    
    def __str__(self):
        return self.email