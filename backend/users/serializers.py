# backend/users/serializers.py
from rest_framework import serializers
from .models import CustomUser, BusinessProfile

class BusinessProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = BusinessProfile
        fields = '__all__'

# --- NEW: Serializer for Updating User Profiles ---
# This serializer defines only the fields that a user is allowed to edit.
# This prevents users from changing sensitive information like their role or email.
class UserProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = [
            'first_name', 
            'last_name', 
            'bio', 
            'phone_number',
            'profile_picture',
        ]
        # This makes it so a user doesn't have to re-upload their picture every time
        # they update their text information.
        extra_kwargs = {
            'profile_picture': {'required': False, 'allow_null': True}
        }


# --- UPDATED: Serializer for Reading User Data ---
# This serializer is updated to show all the new fields from our model.
class UserSerializer(serializers.ModelSerializer):
    # The related name from the ManyToManyField is 'business_profiles' (plural).
    # We set many=True to indicate it's a list of profiles.
    business_profiles = BusinessProfileSerializer(many=True, read_only=True)
    
    # We can use a SerializerMethodField to include the full_name property from the model.
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = [
            'id', 
            'username', 
            'email', 
            'first_name',  # Added
            'last_name',   # Added
            'full_name',   # This now uses our method
            'bio',         # Added
            'phone_number',# Added
            'profile_picture', # Added
            'role', 
            'business_profiles', # Updated from 'business_profile'
        ]
        
        # We ensure sensitive or automatically-set fields remain read-only.
        read_only_fields = [
            'id', 
            'username', 
            'email', 
            'role', 
            'business_profiles', 
            'full_name',
        ]

    def get_full_name(self, obj):
        # This method calls the `full_name` property on the CustomUser model instance.
        return obj.full_name