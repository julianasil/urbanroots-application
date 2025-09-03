# backend/urls.py (project)
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include(("users.urls", "users"), namespace="users")),
    path('api/auth/', include('dj_rest_auth.urls')),
]
