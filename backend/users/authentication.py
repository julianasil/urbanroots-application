# backend/users/authentication.py

import jwt
from django.conf import settings
from rest_framework import authentication, exceptions
from .models import CustomUser

class SupabaseJWTAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        auth_header = authentication.get_authorization_header(request).split()

        if not auth_header or auth_header[0].lower() != b'bearer':
            return None

        if len(auth_header) != 2:
            raise exceptions.AuthenticationFailed('Invalid token header.')

        token = auth_header[1].decode('utf-8')

        try:
            # --- THIS IS THE FIX ---
            # We must provide the 'audience' claim for Supabase JWTs.
            # We also add better exception handling to see the exact error.
            payload = jwt.decode(
                token,
                settings.SUPABASE_JWT_SECRET,
                algorithms=['HS256'],
                audience='authenticated' # <-- CRITICAL ADDITION
            )
        except jwt.ExpiredSignatureError:
            print("DEBUG: Token has expired.")
            raise exceptions.AuthenticationFailed('Token has expired.')
        except jwt.InvalidAudienceError:
            print("DEBUG: Invalid audience in token.")
            raise exceptions.AuthenticationFailed('Invalid token audience.')
        except jwt.InvalidSignatureError:
            print("DEBUG: Invalid signature in token. Check your SUPABASE_JWT_SECRET.")
            raise exceptions.AuthenticationFailed('Invalid token signature.')
        except Exception as e:
            # This will print the exact error to your Django console for debugging.
            print(f"DEBUG: An unexpected error occurred during token decoding: {e}")
            raise exceptions.AuthenticationFailed(f'Error decoding token.')

        supabase_user_id = payload.get('sub')
        if not supabase_user_id:
            raise exceptions.AuthenticationFailed('Token is missing user ID (sub).')

        # Use the user_metadata from the token for full_name and username if available
        user_metadata = payload.get('user_metadata', {})

        full_name = user_metadata.get('full_name', '').strip()

        name_parts = full_name.split(' ')
        first_name = name_parts[0]
        last_name = ' '.join(name_parts[1:]) if len(name_parts) > 1 else ''

        user, created = CustomUser.objects.get_or_create(
            id=supabase_user_id,
            defaults={
                'email': payload.get('email', ''),
                'username': user_metadata.get('username', payload.get('email')), # Fallback to email
                'first_name': first_name,
                'last_name': last_name,
            }
        )
        
        if created:
            print(f"DEBUG: Created new Django user for Supabase ID: {supabase_user_id}")

        return (user, None)