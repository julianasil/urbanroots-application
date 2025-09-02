from django.db import models

class Profile(models.Model):
    # This will match the Supabase "profiles" table
    id = models.UUIDField(primary_key=True, editable=False)  # maps to Supabase auth.users UUID
    email = models.EmailField(unique=True)
    full_name = models.CharField(max_length=255, blank=True, null=True)
    bio = models.TextField(blank=True, null=True)  # new biography field
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.email
