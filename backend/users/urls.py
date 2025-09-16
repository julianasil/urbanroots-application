# users/urls.py
from django.urls import path
from .views import (
    UserProfileView,
    # --- ADDED: Import the new update view ---
    UserProfileUpdateView,
    BusinessProfileCreateView,
    BusinessProfileDetailView,
    MyBusinessProfilesListView,
    JoinableBusinessProfileListView,
    JoinBusinessProfileView,
)

urlpatterns = [
    # --- User-specific URLs ---
    path('me/', UserProfileView.as_view(), name='user-profile'),
    
    # --- NEW: URL for updating the user's profile ---
    path('me/update/', UserProfileUpdateView.as_view(), name='user-profile-update'),

    # --- Business Profile URLs ---
    path('business/create/', BusinessProfileCreateView.as_view(), name='business-profile-create'),
    path('business/my-profiles/', MyBusinessProfilesListView.as_view(), name='my-business-profiles-list'),
    path('business/joinable/', JoinableBusinessProfileListView.as_view(), name='joinable-business-profiles-list'),
    path('business/join/', JoinBusinessProfileView.as_view(), name='join-business-profile'),
    
    # This URL with a variable must come after the other static 'business/' URLs.
    path('business/<uuid:profile_id>/', BusinessProfileDetailView.as_view(), name='business-profile-detail'),
]