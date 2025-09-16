# backend/users/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, BusinessProfile

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    
    # --- FIX: Replaced 'full_name' with 'first_name' and 'last_name' ---
    list_display = ['email', 'username', 'first_name', 'last_name', 'role', 'is_staff']
    
    # --- FIX: Updated the fieldsets to reflect the current model structure ---
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        # Replaced 'full_name' and added our new editable fields
        ('Personal info', {'fields': ('first_name', 'last_name', 'email', 'bio', 'phone_number', 'profile_picture')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
        ('Extra Info', {'fields': ('role',)}),
    )
    
    # --- FIX: Replaced 'full_name' in the search fields ---
    search_fields = ('email', 'username', 'first_name', 'last_name')
    
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'groups')
    
    # --- FIX: Updated the fields for the "add user" page ---
    add_fieldsets = UserAdmin.add_fieldsets + (
        # Replaced 'full_name' with 'first_name' and 'last_name'
        (None, {'fields': ('first_name', 'last_name', 'email', 'role')}),
    )

class BusinessProfileAdmin(admin.ModelAdmin):
    model = BusinessProfile
    list_display = ('company_name', 'business_type', 'contact_number')
    # This is the correct way to handle ManyToMany fields, no change needed.
    filter_horizontal = ('members',)

# We register the models with their custom admin configurations.
admin.site.register(CustomUser, CustomUserAdmin)
admin.site.register(BusinessProfile, BusinessProfileAdmin)