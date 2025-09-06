# backend/users/serializers.py
from rest_framework import serializers
from .models import CustomUser, BusinessProfile

class BusinessProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = BusinessProfile
        # This will include all fields from the BusinessProfile model in the API output.
        fields = '__all__'

class UserSerializer(serializers.ModelSerializer):
    # This tells the serializer to include the full details of the business profile,
    # not just its ID. It will use the BusinessProfileSerializer defined above.
    business_profile = BusinessProfileSerializer(read_only=True)

    class Meta:
        model = CustomUser
        # These are the specific fields from your CustomUser model that will be
        # exposed in the API.
        fields = [
            'id', 
            'email', 
            'username', 
            'full_name', 
            'role', 
            'business_profile',
        ]

        read_only_fields = ['id', 'email', 'role', 'business_profile']