Here’s a **real-world Makefile** for a Django project using **`django-environ`** and multiple environments (dev, staging, prod). It works with `.env` files and passes the `ENV` variable into Django.

---

```makefile
# Makefile for Django project using django-environ

PY ?= python3          # Python interpreter
ENV ?= dev             # Default environment
MANAGE = ENV=$(ENV) $(PY) manage.py

.PHONY: help run migrate makemigrations shell test fmt lint collectstatic worker superuser clean

help:
	@echo "Django Makefile (multi-environment using django-environ)"
	@echo "Usage: make <target> ENV=dev|staging|prod"
	@echo ""
	@echo "Targets:"
	@echo "  run            Run development server"
	@echo "  migrate        Run migrations"
	@echo "  makemigrations Create migrations"
	@echo "  shell          Open Django shell"
	@echo "  test           Run tests"
	@echo "  fmt            Format code using black"
	@echo "  lint           Lint code using flake8"
	@echo "  collectstatic  Collect static files"
	@echo "  worker         Run Celery worker"
	@echo "  superuser      Create superuser"
	@echo "  clean          Remove pycache and pyc files"

# Run Django server
run:
	$(MANAGE) runserver 0.0.0.0:8000

# Apply migrations
migrate:
	$(MANAGE) migrate

# Create migrations
makemigrations:
	$(MANAGE) makemigrations

# Django shell
shell:
	$(MANAGE) shell

# Run tests
test:
	$(MANAGE) test

# Format code
fmt:
	black .

# Lint code
lint:
	flake8 .

# Collect static files
collectstatic:
	$(MANAGE) collectstatic --noinput

# Run Celery worker
worker:
	ENV=$(ENV) celery -A myproject worker -l info

# Create superuser
superuser:
	$(MANAGE) createsuperuser

# Clean __pycache__ and .pyc files
clean:
	find . -name "__pycache__" -exec rm -rf {} +
	find . -name "*.pyc" -delete
```

---

## **How it works**

1. `ENV` is passed as **a real environment variable** to Django.
2. `django-environ` in `settings.py` reads `.env` based on the `ENV` variable or a hard-coded `ENV_PATH`.
3. Example usage:

```bash
# Development
make run ENV=dev
make migrate ENV=dev

# Staging
make run ENV=staging
make migrate ENV=staging

# Production
make run ENV=prod
make collectstatic ENV=prod
```

---

## **Optional enhancement: auto-load .env files**

If you want `django-environ` to pick `.env.dev`, `.env.staging`, `.env.prod` automatically:

```makefile
MANAGE = ENV=$(ENV) ENV_PATH=.env.$(ENV) $(PY) manage.py
```

* This sets `ENV_PATH` for `django-environ` to read the correct `.env` file per environment.
* Then in `settings.py`:

```python
import environ
import os
env = environ.Env()
env.read_env(env.str("ENV_PATH", ".env"))
```

* Now Makefile + `django-environ` + `.env` files are fully integrated.

---

This Makefile is **production-ready** for multi-environment Django projects using `django-environ`.

I can also create a **full working example with dev/staging/prod .env files** and a **settings template** if you want to see it end-to-end. Do you want me to do that?

## add shortcut to rerun server on a port, even the port is used by another

You can add a **Makefile target** to do exactly that — check if the port is in use, kill it if needed, and then run Django. Here’s a clean way to integrate it with your existing Makefile:

---

```makefile id="f98djq"
# Shortcut to run Django server safely on a given port
runport:
	@PORT=8000; \
	PID=$$(lsof -t -i:$$PORT); \
	if [ -n "$$PID" ]; then \
		echo "Port $$PORT is in use by PID $$PID. Killing..."; \
		kill -9 $$PID; \
	else \
		echo "Port $$PORT is free."; \
	fi; \
	echo "Starting Django server on port $$PORT..."; \
	ENV=$(ENV) python3 manage.py runserver $$PORT
```

---

### **How it works**

1. `PORT=8000` → set the port to run the server.
2. `lsof -t -i:$PORT` → checks if the port is in use and returns the PID.
3. If a PID exists, it kills the process (`kill -9`).
4. Finally, runs Django on that port with the current environment (`ENV=$(ENV)`).

---

### **Usage**

```bash
# Run in development (default ENV=dev)
make runport

# Run in production
make runport ENV=prod
```

---

You can also **parameterize the port** if you want:

```makefile id="iok0pf"
runport:
	@PORT=${PORT:=8000}; \
	PID=$$(lsof -t -i:$$PORT); \
	if [ -n "$$PID" ]; then \
		echo "Port $$PORT is in use by PID $$PID. Killing..."; \
		kill -9 $$PID; \
	else \
		echo "Port $$PORT is free."; \
	fi; \
	echo "Starting Django server on port $$PORT..."; \
	ENV=$(ENV) python3 manage.py runserver $$PORT
```

Then you can override the port when calling Make:

```bash
make runport PORT=9000 ENV=dev
```

---

I can integrate this **into your full Makefile** with `run`, `runport`, Celery, collectstatic, etc., ready to use for dev/staging/prod if you want. Do you want me to do that?

Here’s a **full Makefile** integrating everything you asked for:

* Multi-environment support (`ENV=dev|staging|prod`)
* Standard Django commands (`run`, `migrate`, `shell`, `test`, `collectstatic`, etc.)
* Celery worker/flower
* Safe port-run shortcut (`runport`) that checks/kills the port if in use
* Fully compatible with `django-environ` and `.env` files

---

```makefile
# Makefile for Django project with django-environ and safe port run

PY ?= python3
ENV ?= dev
PORT ?= 8000
MANAGE = ENV=$(ENV) $(PY) manage.py

.PHONY: help run runport migrate makemigrations shell test fmt lint collectstatic worker flower superuser clean docker-build docker-up docker-down

help:
	@echo "Django Makefile (multi-environment using django-environ)"
	@echo ""
	@echo "Usage: make <target> ENV=dev|staging|prod PORT=8000"
	@echo ""
	@echo "Targets:"
	@echo "  run            Run Django dev server (default port 8000)"
	@echo "  runport        Run Django server safely, kill port if in use"
	@echo "  migrate        Apply migrations"
	@echo "  makemigrations Create migrations"
	@echo "  shell          Django shell"
	@echo "  test           Run tests"
	@echo "  fmt            Format code using black"
	@echo "  lint           Lint code using flake8"
	@echo "  collectstatic  Collect static files"
	@echo "  worker         Run Celery worker"
	@echo "  flower         Run Celery Flower monitoring"
	@echo "  superuser      Create superuser"
	@echo "  clean          Remove __pycache__ and .pyc files"
	@echo "  docker-build   Build Docker containers"
	@echo "  docker-up      Start Docker containers"
	@echo "  docker-down    Stop Docker containers"

# Standard run (does not check port)
run:
	$(MANAGE) runserver 0.0.0.0:$(PORT)

# Safe run: check port, kill if used, then run server
runport:
	@PID=$$(lsof -t -i:$(PORT)); \
	if [ -n "$$PID" ]; then \
		echo "Port $(PORT) is in use by PID $$PID. Killing..."; \
		kill -9 $$PID; \
	else \
		echo "Port $(PORT) is free."; \
	fi; \
	echo "Starting Django server on port $(PORT)..."; \
	ENV=$(ENV) $(PY) manage.py runserver 0.0.0.0:$(PORT)

# Apply migrations
migrate:
	$(MANAGE) migrate

# Create migrations
makemigrations:
	$(MANAGE) makemigrations

# Django shell
shell:
	$(MANAGE) shell

# Run tests
test:
	$(MANAGE) test

# Format code with black
fmt:
	black .

# Lint code with flake8
lint:
	flake8 .

# Collect static files
collectstatic:
	$(MANAGE) collectstatic --noinput

# Run Celery worker
worker:
	ENV=$(ENV) celery -A myproject worker -l info

# Run Celery Flower
flower:
	ENV=$(ENV) celery -A myproject flower --port=5555

# Create superuser
superuser:
	$(MANAGE) createsuperuser

# Clean __pycache__ and .pyc
clean:
	find . -name "__pycache__" -exec rm -rf {} +
	find . -name "*.pyc" -delete

# Docker commands
docker-build:
	docker-compose build

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down
```

---

### **Usage examples**

#### Run server (default dev)

```bash
make run
make runport
```

#### Run on custom port

```bash
make runport PORT=9000 ENV=dev
```

#### Staging environment

```bash
make run ENV=staging
make migrate ENV=staging
make collectstatic ENV=staging
make worker ENV=staging
```

#### Production environment

```bash
make runport ENV=prod
make migrate ENV=prod
make collectstatic ENV=prod
make worker ENV=prod
make flower ENV=prod
```

---

### ✅ Features

1. **`ENV` variable** determines which `.env` file Django-environ reads.
2. **Safe port-run (`runport`)** kills existing process before starting.
3. **Full Makefile coverage**: server, migrations, shell, tests, formatting, lint, Celery, Docker.
4. Works out-of-the-box for **multi-environment projects** with `django-environ`.

---

If you want, I can **add automatic `.env` loading** into this Makefile so it chooses `.env.dev`, `.env.staging`, or `.env.prod` based on `ENV` automatically — no manual `ENV_PATH` setting needed.

Do you want me to do that next?
