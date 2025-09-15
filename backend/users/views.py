# backend/users/views.py
from rest_framework import generics, serializers, status
from rest_framework.permissions import IsAuthenticated
from .models import CustomUser, BusinessProfile
from .serializers import UserSerializer, BusinessProfileSerializer, UserProfileUpdateSerializer
from rest_framework.generics import ListAPIView 
from rest_framework.views import APIView
from rest_framework.response import Response

class UserProfileView(generics.RetrieveAPIView):
    """
    View to retrieve the profile of the currently authenticated user.
    """
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user

# --- MODIFIED: This view is updated to fix the frontend TypeError ---
class UserProfileUpdateView(generics.UpdateAPIView):
    """
    Allows the authenticated user to update their own personal profile information.
    Handles PUT and PATCH requests.
    """
    # This serializer is correctly used for validating the INCOMING data.
    serializer_class = UserProfileUpdateSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        # This ensures the user being updated is ALWAYS the user making the request.
        return self.request.user
    
    # --- FIX: Override the `update` method to control the JSON response ---
    def update(self, request, *args, **kwargs):
        # Allow the parent class to perform the actual database update first.
        # This saves the data from the request using UserProfileUpdateSerializer.
        super().update(request, *args, **kwargs)

        # After the update, get the fresh user instance from the database.
        user_instance = self.get_object()

        # Now, create a new serializer instance using the FULL UserSerializer.
        # This ensures the response contains all the fields the frontend expects.
        response_serializer = UserSerializer(user_instance, context={'request': request})
        
        # Return the complete, updated user profile data.
        return Response(response_serializer.data, status=status.HTTP_200_OK)


class BusinessProfileDetailView(generics.RetrieveUpdateAPIView):
    """
    Allows a team member to retrieve or update a specific business profile by its ID.
    """
    serializer_class = BusinessProfileSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'profile_id'

    def get_queryset(self):
        if self.request.user and self.request.user.is_authenticated:
            return self.request.user.business_profiles.all()
        return BusinessProfile.objects.none()

class BusinessProfileCreateView(generics.CreateAPIView):
    """
    Allows an authenticated user to create a new business profile.
    The creator will be automatically added as the first member of the business.
    """
    serializer_class = BusinessProfileSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        business_profile = serializer.save()
        business_profile.members.add(self.request.user)

class MyBusinessProfilesListView(ListAPIView):
    """
    Provides a list of all business profiles the authenticated user is a member of.
    """
    serializer_class = BusinessProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        if self.request.user and self.request.user.is_authenticated:
            return self.request.user.business_profiles.all()
        return BusinessProfile.objects.none()

class JoinableBusinessProfileListView(ListAPIView):
    """
    Provides a list of all business profiles that a user can potentially join.
    """
    serializer_class = BusinessProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return BusinessProfile.objects.all()
    
class JoinBusinessProfileView(APIView):
    """
    Allows a user to "join" an existing business profile, adding them
    to its list of members.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        profile_id = request.data.get('profile_id')

        if not profile_id:
            return Response({'error': 'Profile ID is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            profile_to_join = BusinessProfile.objects.get(profile_id=profile_id)
            
            if user in profile_to_join.members.all():
                return Response(
                    {'error': f'You are already a member of {profile_to_join.company_name}.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            profile_to_join.members.add(user)

            return Response(
                {'success': f'You have successfully joined {profile_to_join.company_name}.'},
                status=status.HTTP_200_OK
            )

        except BusinessProfile.DoesNotExist:
            return Response({'error': 'Profile not found.'}, status=status.HTTP_404_NOT_FOUND)