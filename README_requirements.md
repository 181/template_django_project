
## Requirements Folder for Django 6 (Base / Dev / Test / Prod)

Below is a **complete, ready-to-use requirements setup** designed for **Django 6**, with clean separation for:

* base (core app dependencies)
* dev (debugging + development tools)
* test (pytest + factories + coverage)
* prod (only what production needs)

This structure avoids leaking dev/test tools into production.

---

## Folder Structure

```bash
requirements/
├── base.txt
├── dev.txt
├── test.txt
└── prod.txt
```

---

## base.txt (Django 6 Core App Dependencies)

```text id="wpuzto"
Django>=6.0,<7.0
django-environ
psycopg2-binary
gunicorn
django-redis
djangorestframework
```

### Notes

* Keep this minimal — only what your app **must have to run**.
* `gunicorn` stays here or in `prod.txt` depending on preference.

---

## dev.txt (Local Development Tools)

```text id="fzs19a"
-r base.txt

# Debugging & profiling
django-debug-toolbar
django-extensions
django-silk

# Developer experience
ipython
black
flake8
```

### Notes

* Debug toolbar, extensions, Silk, and linters stay in dev only.
* Not installed in CI or production.

---

## test.txt (Testing & QA Tools)

```text id="tlj34i"
-r base.txt

pytest
pytest-django
pytest-cov
factory-boy
model-bakery
pytest-xdist
pytest-mock
coverage
```

### Notes

* Testing tools should not be in production.
* `pytest-django` automatically uses `testing.py` settings when configured in `pytest.ini`.

---

## prod.txt (Production)

```text id="cj52jm"
-r base.txt
```

### Notes

* Minimal set to prevent attack surface and speed up builds.
* Install only this in Docker/CI for production.

---

## How to Install per Environment

### Local Development

```bash
pip install -r requirements/dev.txt
pip install -r requirements/test.txt
```

### Testing / CI

```bash
pip install -r requirements/test.txt
```

### Production

```bash
pip install -r requirements/prod.txt
```

---

## Optional: Improve Workflow with pip-tools (Recommended)

If you'd like fully locked versions:

### 1. Install pip-tools

```bash
pip install pip-tools
```

### 2. Convert requirement files into `.in` files:

```bash
requirements/
├── base.in
├── dev.in
├── test.in
└── prod.in
```

### 3. Compile locked versions:

```bash
pip-compile requirements/base.in      -o requirements/base.txt
pip-compile requirements/dev.in       -o requirements/dev.txt
pip-compile requirements/test.in      -o requirements/test.txt
pip-compile requirements/prod.in      -o requirements/prod.txt
```

This produces deterministic, production-safe version locks.

---

## If You Want

I can generate a **pre-filled set of `.in` files** for pip-tools, or update your **Dockerfile and docker-compose** to reference these exact requirement files for dev/stage/prod.
