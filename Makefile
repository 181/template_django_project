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
	$(MANAGE) runserver 127.0.0.1:$(PORT)

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
	ENV=$(ENV) $(PY) manage.py runserver 127.0.0.1:$(PORT)

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