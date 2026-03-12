from .base import *

# ALLOWED_HOSTS can be empty for tests

# Use an in-memory SQLite DB for faster tests (optional)
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}

INSTALLED_APPS += [
    "django_extensions",
]

# Optional: disable debug_toolbar middleware that slows down tests
MIDDLEWARE = [
    m for m in MIDDLEWARE if m != "debug_toolbar.middleware.DebugToolbarMiddleware"
]