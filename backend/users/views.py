# backend/users/views.py
from rest_framework import generics, serializers, status
from rest_framework.permissions import IsAuthenticated
from .models import CustomUser, BusinessProfile
from .serializers import UserSerializer, BusinessProfileSerializer
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

class BusinessProfileDetailView(generics.RetrieveUpdateAPIView):
    """
    Allows a team member to retrieve or update a specific business profile by its ID.
    """
    serializer_class = BusinessProfileSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'profile_id'

    def get_queryset(self):
        # Users can only interact with profiles they are a member of.
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

# --- ADDED: New views for the "Open Joining" feature ---

class JoinableBusinessProfileListView(ListAPIView):
    """
    Provides a list of all business profiles that a user can potentially join.
    """
    serializer_class = BusinessProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # This returns all business profiles in the system, so users can see all options.
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
            
            # This check prevents a user from joining the same business twice.
            if user in profile_to_join.members.all():
                return Response(
                    {'error': f'You are already a member of {profile_to_join.company_name}.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # The core logic: Add the current user to the members list.
            profile_to_join.members.add(user)

            return Response(
                {'success': f'You have successfully joined {profile_to_join.company_name}.'},
                status=status.HTTP_200_OK
            )

        except BusinessProfile.DoesNotExist:
            return Response({'error': 'Profile not found.'}, status=status.HTTP_404_NOT_FOUND)