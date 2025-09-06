# backend/users/urls.py
from django.urls import path
from .views import UserProfileView, BusinessProfileView, BusinessProfileCreateView, UnclaimedBusinessProfileListView, ClaimBusinessProfileView

urlpatterns = [
    path('user/', UserProfileView.as_view(), name='user-profile'),
    path('profile/', BusinessProfileView.as_view(), name='business-profile'),
    path('profile/create/', BusinessProfileCreateView.as_view(), name='business-profile-create'),
    path('profiles/unclaimed/', UnclaimedBusinessProfileListView.as_view(), name='unclaimed-profiles-list'),
    path('profile/claim/', ClaimBusinessProfileView.as_view(), name='business-profile-claim'),
]