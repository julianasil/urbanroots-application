# backend/users/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, BusinessProfile

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    
    # This defines the columns shown in the list view of all users.
    list_display = ['email', 'username', 'full_name', 'role', 'is_staff']
    
    # MODIFIED: This is the main fix. We are manually defining the layout
    # of the user edit page to remove 'first_name' and 'last_name' and add 'full_name'.
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Personal info', {'fields': ('full_name', 'email')}), # Changed from first_name, last_name
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
        ('Extra Info', {'fields': ('role',)}), # Added our custom 'role' field here
    )
    
    # This tells the admin which fields to use for searching.
    search_fields = ('email', 'username', 'full_name')
    
    # This tells the admin which fields to use for filtering.
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'groups')
    
    # This defines the fields for the "add user" page.
    add_fieldsets = UserAdmin.add_fieldsets + (
        (None, {'fields': ('full_name', 'email', 'role')}),
    )

class BusinessProfileAdmin(admin.ModelAdmin):
    model = BusinessProfile
    list_display = ('company_name', 'business_type', 'contact_number')
    filter_horizontal = ('members',)

# We register the models with their custom admin configurations.
admin.site.register(CustomUser, CustomUserAdmin)
admin.site.register(BusinessProfile, BusinessProfileAdmin)