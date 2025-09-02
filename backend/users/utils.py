# users/utils.py
from django.db import transaction
from .models import Profile

def _safe_username(base: str) -> str:
    # keep it simple; strip spaces and lowercase
    return base.strip().replace(" ", "_").lower()

@transaction.atomic
def ensure_profile_for_supabase_user(supabase_user: dict) -> Profile:
    """
    Create a local Profile if missing, using Supabase user info.
    Returns (existing or new) Profile.
    """
    supa_id = supabase_user["id"]                   # UUID string
    meta = (supabase_user.get("user_metadata") or {})
    email = supabase_user.get("email") or ""
    preferred = meta.get("username") or (email.split("@")[0] if email else "user")

    full_name = meta.get("full_name") or (
        (meta.get("first_name") or "") + " " + (meta.get("last_name") or "")
    ).strip()

    # Already exists?
    try:
        return Profile.objects.get(id=supa_id)
    except Profile.DoesNotExist:
        pass

    # Pick a unique username
    base = _safe_username(preferred or "user")
    candidate = base
    i = 1
    while Profile.objects.filter(username=candidate).exists():
        i += 1
        candidate = f"{base}{i}"

    return Profile.objects.create(
        id=supa_id,
        username=candidate,
        full_name=full_name,
    )
