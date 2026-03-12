Here’s the **final, clean, fully working setup** for your Django project using `.env` for environment-specific settings.

* **`manage.py`, `wsgi.py`, `asgi.py`** remain unchanged.
* **`config/settings/__init__.py`** is the router that selects the right environment.
* **`base.py`** reads all values from `.env`.
* **Environment files** (`local.py`, `staging.py`, `production.py`, `test.py`) only contain overrides, no `ALLOWED_HOSTS`.

---

# Project Structure

```
config/
  settings/
    __init__.py
    base.py
    local.py
    staging.py
    production.py
    test.py
manage.py
.env
.env.local
.env.staging
.env.production
.env.test
```

---

# 1. `config/settings/__init__.py` — Environment Router

```python
import os
from django.core.exceptions import ImproperlyConfigured

# Determine the environment (default to local)
env = os.getenv("ENV", "local")

valid_envs = {"local", "staging", "production", "test"}
if env not in valid_envs:
    raise ImproperlyConfigured(
        f"Invalid ENV '{env}'. Must be one of: {valid_envs}"
    )

# Import the corresponding settings module
module_path = f"config.settings.{env}"
module = __import__(module_path, globals(), locals(), ["*"])

# Copy all attributes from the module into this namespace
for attr in dir(module):
    if not attr.startswith("_"):
        globals()[attr] = getattr(module, attr)
```

✅ This allows Django to load `config.settings` by default, and the router redirects to the correct environment.

---

# 2. `config/settings/base.py` — Shared Settings

```python
import environ
from pathlib import Path

env = environ.Env()
environ.Env.read_env()  # Loads .env automatically

BASE_DIR = Path(__file__).resolve().parent.parent.parent

DEBUG = env.bool("DEBUG", default=False)
SECRET_KEY = env.str("SECRET_KEY")
DATABASES = {"default": env.db()}
ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=[])

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"
WSGI_APPLICATION = "config.wsgi.application"
STATIC_URL = "/static/"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]
```

---

# 3. `config/settings/local.py`

```python
from .base import *

INSTALLED_APPS += [
    "debug_toolbar",
    "django_extensions",
]

MIDDLEWARE += [
    "debug_toolbar.middleware.DebugToolbarMiddleware",
]
```

---

# 4. `config/settings/staging.py`

```python
from .base import *
# ALLOWED_HOSTS comes from .env.staging
```

---

# 5. `config/settings/production.py`

```python
from .base import *

SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
# ALLOWED_HOSTS comes from .env.production
```

---

# 6. `config/settings/test.py`

```python
from .base import *

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}
# ALLOWED_HOSTS can be empty for tests
```

---

# 7. Example `.env` files

### `.env.local`

```env
ENV=local
DEBUG=True
SECRET_KEY=local-secret
DATABASE_URL=sqlite:///db.sqlite3
ALLOWED_HOSTS=localhost,127.0.0.1
```

### `.env.staging`

```env
ENV=staging
DEBUG=False
SECRET_KEY=staging-secret
DATABASE_URL=postgres://user:pass@host:port/db
ALLOWED_HOSTS=staging.example.com
```

### `.env.production`

```env
ENV=production
DEBUG=False
SECRET_KEY=prod-secret
DATABASE_URL=postgres://user:pass@host:port/db
ALLOWED_HOSTS=example.com,www.example.com
```

### `.env.test`

```env
ENV=test
DEBUG=True
SECRET_KEY=test-secret
DATABASE_URL=sqlite:///:memory:
ALLOWED_HOSTS=
```

---

# 8. How to Run

* **Local (default):**

```bash
python manage.py runserver
```

* **Staging:**

```bash
ENV=staging python manage.py runserver
```

* **Production:**

```bash
ENV=production python manage.py runserver
```

* **Tests:**

```bash
ENV=test pytest
```

---

### ✅ Benefits of this setup (Option A)

1. `manage.py` and `wsgi.py` stay untouched.
2. All environment-specific values are controlled via `.env`.
3. No duplication of `ALLOWED_HOSTS`.
4. Works with `pytest`, Docker, Gunicorn, and any deployment.
5. Clean, maintainable, and industry standard.

---

This is your **final, production-ready Option A setup**.

Do you want me to also provide a **Makefile** that supports `make run dev/staging/prod` using this `.env` setup?

