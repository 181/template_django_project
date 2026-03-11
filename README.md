# template_django_project

Use this project as a base template project for all Django projects

## Prerequisites

* Python **3.11 or 3.12+** installed (Django 6.0 requires recent Python versions).
* Command-line/shell access.

## Step-by-Step: Setting Up a New Django Project

### 1. Create a Project Directory

```bash
mkdir template_django_project
cd template_django_project
```

### 2. Create and Activate a Virtual Environment

macOS / Linux:

```bash
python3 -m venv venv
source venv/bin/activate
```

Windows:

```bash
python -m venv venv
venv\Scripts\activate
```

### 3. Install Django

```bash
pip install django
```

This installs the latest Django release (e.g., 6.0.x).

### 4. Verify Django Installation

```bash
python -m django --version
```

### 5. Create a New Django Project

```bash
django-admin startproject config .
```

Using `.` installs the project in the current directory.
So the command creates:

```python
<current folder>/
    manage.py
    config/
        __init__.py
        settings.py
        urls.py
        asgi.py
        wsgi.py
    venv
```

### 6. Run the Development Server

```bash
python manage.py runserver
```

Visit **[http://127.0.0.1:8000/](http://127.0.0.1:8000/)** in a browser to verify it’s running.

---

## Optional Steps

### Create and Register an App

#### Create an app:

```bash
python manage.py startapp core
```

#### Register it:

Add `'core'` to `INSTALLED_APPS` in `config/settings.py`.

### Define a Simple View and URL

**In `core/views.py`:**

```python
from django.http import HttpResponse

def home(request):
    return HttpResponse("Hello world")
```

**In `core/urls.py`:** (manually create urls.py)

```python
from django.urls import path
from .views import home

urlpatterns = [
    path('', home),
]
```

Include in `config/urls.py`:

```python
from django.urls import path, include

urlpatterns = [
    path('', include('core.urls')),
]
```

### Apply Database Migrations

```bash
python manage.py migrate
```

### Create a Superuser

```bash
python manage.py createsuperuser
# python manage.py createsuperuser --username admin --email admin@admin.com 
```

Then navigate **[http://127.0.0.1:8000/admin/](http://127.0.0.1:8000/admin/)**.

---

## Notes on Version Choices

* **Django 6.0+** gives you the newest features and performance improvements. ([EOL.Wiki][1])
* **Django 5.2** is a good choice if you prioritize LTS (longer security support). ([gdevops.frama.io][2])

If you want steps focused specifically on Django 5.2 or how to use additional tools (e.g., Docker, Postgres, REST APIs), let me know.

[1]: https://eol.wiki/django?utm_source=chatgpt.com "Django End of Life (EOL) Dates & Support Status | EOL.Wiki"
[2]: https://gdevops.frama.io/django/versions/?utm_source=chatgpt.com "Django Versions — Django versions"


