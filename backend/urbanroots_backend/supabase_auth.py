# backend/supabase_auth.py
import os
import requests

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")

def get_user_from_token(access_token: str):
    """
    Validate Supabase JWT and return user dict, or None.
    """
    if not access_token:
        return None
    try:
        res = requests.get(
            f"{SUPABASE_URL}/auth/v1/user",
            headers={
                "Authorization": f"Bearer {access_token}",
                "apikey": SUPABASE_ANON_KEY,
            },
            timeout=6,
        )
        if res.status_code == 200:
            return res.json()
        return None
    except requests.RequestException:
        return None
