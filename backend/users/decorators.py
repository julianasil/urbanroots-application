# users/decorators.py
from functools import wraps
from django.http import JsonResponse
from urbanroots_backend.supabase_auth import get_user_from_token
from .utils import ensure_profile_for_supabase_user

def require_supabase_user(view_func):
    @wraps(view_func)
    def _wrapped(request, *args, **kwargs):
        auth_header = request.META.get("HTTP_AUTHORIZATION") or request.headers.get("Authorization")
        token = ""
        if auth_header and auth_header.startswith("Bearer "):
            token = auth_header.split(" ", 1)[1].strip()

        supa_user = get_user_from_token(token)
        if not supa_user:
            return JsonResponse({"error": "Unauthorized"}, status=401)

        # make available to views
        request.supabase_user = supa_user
        request.supabase_user_id = supa_user["id"]

        # ensure local Profile exists
        request.profile = ensure_profile_for_supabase_user(supa_user)

        return view_func(request, *args, **kwargs)
    return _wrapped
