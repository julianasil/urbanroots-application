# backend/users/views.py
from rest_framework import generics, serializers, status
from rest_framework.permissions import IsAuthenticated
from .models import CustomUser, BusinessProfile
from .serializers import UserSerializer, BusinessProfileSerializer
from rest_framework.generics import ListAPIView 
from rest_framework.views import APIView
from rest_framework.response import Response

# This is the view that was missing, for fetching the CustomUser details.
class UserProfileView(generics.RetrieveAPIView):
    """
    View to retrieve the profile of the currently authenticated user.
    We use RetrieveAPIView because we only want to GET the data.
    """
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        # This special method returns the user object associated with the request token.
        return self.request.user

# This view is for GETTING or UPDATING an existing business profile.
class BusinessProfileView(generics.RetrieveUpdateAPIView):
    """
    Allows the authenticated user to retrieve or update their own business profile.
    """
    serializer_class = BusinessProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        profile = self.request.user.business_profile
        # This check prevents an error if the user has no profile yet.
        if profile is None:
            raise serializers.ValidationError("User does not have a business profile.")
        return profile

# This view is specifically for CREATING a new business profile.
class BusinessProfileCreateView(generics.CreateAPIView):
    """
    Allows a new user to create their business profile.
    """
    serializer_class = BusinessProfileSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        user = self.request.user
        # This check prevents a user from creating more than one profile.
        if user.business_profile is not None:
            raise serializers.ValidationError("User already has a business profile.")
        
        # Save the new profile and link it to the user who made the request.
        profile = serializer.save()
        user.business_profile = profile
        user.save()

class UnclaimedBusinessProfileListView(ListAPIView):
    """
    Provides a list of business profiles that are not yet associated
    with any user.
    """
    serializer_class = BusinessProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # The double underscore queries the reverse relationship.
        # We are looking for profiles where the related 'customuser' is null.
        return BusinessProfile.objects.filter(customuser__isnull=True)
    
class ClaimBusinessProfileView(APIView):
    """
    Allows an authenticated user to claim an existing, unclaimed business profile.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        profile_id = request.data.get('profile_id')

        if user.business_profile is not None:
            return Response(
                {'error': 'User already has a business profile.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not profile_id:
            return Response(
                {'error': 'Profile ID is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            profile_to_claim = BusinessProfile.objects.get(profile_id=profile_id)
            
            # Check if the profile is already claimed by another user
            if hasattr(profile_to_claim, 'customuser'):
                return Response(
                    {'error': 'This profile is already claimed.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # All checks passed, link the profile to the user
            user.business_profile = profile_to_claim
            user.save()
            return Response(
                {'success': 'Profile claimed successfully.'},
                status=status.HTTP_200_OK
            )

        except BusinessProfile.DoesNotExist:
            return Response(
                {'error': 'Profile not found.'},
                status=status.HTTP_404_NOT_FOUND
            )

