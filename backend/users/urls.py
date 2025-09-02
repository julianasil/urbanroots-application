# users/urls.py
from django.urls import path
from .views import me, update_profile

urlpatterns = [
    path("me/", me, name="me"),
    path("profile/update/", update_profile, name="profile-update"),
]
