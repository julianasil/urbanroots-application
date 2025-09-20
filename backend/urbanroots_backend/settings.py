# backend/urbanroots_backend/settings.py

import os
from pathlib import Path
from dotenv import load_dotenv
from corsheaders.defaults import default_headers

# --- Basic Django Setup ---
SUPABASE_JWT_SECRET = os.environ.get('SUPABASE_JWT_SECRET')
BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")
SECRET_KEY = 'django-insecure-ep95=d#wq%4v2n6gnu*m1_blu%+rl+w=%&t)cc*u184kxknh4g'
DEBUG = True
ALLOWED_HOSTS = []
ROOT_URLCONF = 'urbanroots_backend.urls'
WSGI_APPLICATION = 'urbanroots_backend.wsgi.application'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'


# --- Application Definition ---
# This is the verified, correct order for your apps.
INSTALLED_APPS = [
    'users.apps.UsersConfig',
    'products.apps.ProductsConfig',
    'orders.apps.OrdersConfig',
    #'inventory.apps.InventoryConfig',
    'reports.apps.ReportsConfig',

    # Django Built-in Apps
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Third-Party Apps
    'rest_framework',
    #'rest_framework.authtoken',
    #'dj_rest_auth',
    'corsheaders',
    'django_filters',

]

# --- Middleware ---
# This is the verified, correct order for middleware.
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',  # Must be high up
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# --- Templates, Database, and Password Validators ---
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [], 'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# --- Internationalization & Static Files ---
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True
STATIC_URL = 'static/'

# ==============================================================================
# --- CUSTOM APP CONFIGURATION ---
# All custom settings are grouped here for clarity.
# ==============================================================================

# 1. Custom User Model (This is what the error is about)
# This setting MUST come before other settings that depend on it.
AUTH_USER_MODEL = 'users.CustomUser'

# 2. Django REST Framework
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        # Set this to your custom authentication class
        'users.authentication.SupabaseJWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ]
}

# 3. dj-rest-auth (Connects authentication to your User Model)
#REST_AUTH = {
    #'USER_DETAILS_SERIALIZER': 'users.serializers.UserSerializer',
    #'LOGIN_SERIALIZER': 'dj_rest_auth.serializers.LoginSerializer',
    # These next two lines are needed because we use email for login
    #'USER_MODEL_USERNAME_FIELD': None,
    #'USER_MODEL_EMAIL_FIELD': 'email',
#}

# 4. CORS Headers (For connecting to your Flutter app)
CORS_ORIGIN_ALLOW_ALL = True
CORS_ALLOW_HEADERS = list(default_headers) + [
    "authorization",
]

MEDIA_ROOT = BASE_DIR / 'media'

MEDIA_URL = '/media/'