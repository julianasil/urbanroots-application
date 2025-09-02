# users/views.py
from django.http import JsonResponse, HttpRequest
from .decorators import require_supabase_user

@require_supabase_user
def me(request: HttpRequest):
    """
    Returns Supabase user info + local Profile.
    """
    u = request.supabase_user
    p = request.profile
    return JsonResponse({
        "supabase_user": {
            "id": u["id"],
            "email": u.get("email"),
            "user_metadata": u.get("user_metadata", {}),
        },
        "profile": {
            "id": str(p.id),
            "username": p.username,
            "full_name": p.full_name,
            "role": p.role,
            "created_at": p.created_at.isoformat(),
        }
    })

@require_supabase_user
def update_profile(request: HttpRequest):
    """
    Minimal example to update local profile fields.
    Accepts JSON: { "username": "...", "full_name": "...", "role": "..." }
    """
    if request.method != "POST":
        return JsonResponse({"error": "POST required"}, status=405)

    import json
    try:
        body = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        body = {}

    p = request.profile
    username = body.get("username")
    full_name = body.get("full_name")
    role = body.get("role")

    # enforce uniqueness if username changed
    from .models import Profile
    if username and username != p.username:
        if Profile.objects.filter(username=username).exclude(id=p.id).exists():
            return JsonResponse({"error": "username_taken"}, status=400)
        p.username = username

    if full_name is not None:
        p.full_name = full_name

    if role is not None:
        p.role = role

    p.save()
    return JsonResponse({"ok": True})
