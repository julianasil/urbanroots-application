# backend/users/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, BusinessProfile

class CustomUserAdmin(UserAdmin):
    # This is the configuration for the CustomUser model in the admin panel.
    model = CustomUser

    # Which fields to display in the user list view
    list_display = ('email', 'username', 'full_name', 'role', 'is_staff')

    # Make the list view searchable by these fields
    search_fields = ('email', 'username', 'full_name')

    # Make the list view filterable by these fields
    list_filter = ('role', 'is_staff', 'is_superuser', 'groups')
    
    # How the fields are arranged in the "Edit User" form
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal Info', {'fields': ('full_name', 'username', 'business_profile')}),
        ('Permissions', {'fields': ('role', 'is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )

    # Fields for the "Add User" form
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'full_name', 'username', 'password', 'password2'),
        }),
    )

# Register your models with the admin site so you can manage them
admin.site.register(CustomUser, CustomUserAdmin)
admin.site.register(BusinessProfile)