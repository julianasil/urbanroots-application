# users/urls.py
from django.urls import path
from .views import (
    UserProfileView,
    BusinessProfileCreateView,
    BusinessProfileDetailView,
    MyBusinessProfilesListView,
    # MODIFIED: Added the missing imports for the new views
    JoinableBusinessProfileListView,
    JoinBusinessProfileView,
)

urlpatterns = [
    # --- User-specific URLs ---
    path('me/', UserProfileView.as_view(), name='user-profile'),

    # --- Business Profile URLs ---
    path('business/create/', BusinessProfileCreateView.as_view(), name='business-profile-create'),
    path('business/my-profiles/', MyBusinessProfilesListView.as_view(), name='my-business-profiles-list'),
    
    # MODIFIED: Added the new URL patterns for the "open joining" feature
    path('business/joinable/', JoinableBusinessProfileListView.as_view(), name='joinable-business-profiles-list'),
    path('business/join/', JoinBusinessProfileView.as_view(), name='join-business-profile'),
    
    # This URL with a variable must come after the other static 'business/' URLs.
    path('business/<uuid:profile_id>/', BusinessProfileDetailView.as_view(), name='business-profile-detail'),
]