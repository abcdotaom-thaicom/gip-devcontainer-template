SHELL := /bin/bash
UID := $(shell id -u)
GID := $(shell id -g)
USER := $(shell id -un)

export UID GID USER

IMAGE_NAME ?= ghcr.io/abcdotaom-thaicom/gip-dev-gpu-base:v1.0.1
IMAGE_TAG ?= v1
FULL_IMAGE := $(IMAGE_NAME):$(IMAGE_TAG)

# ========== UTILITIES ==========

# Pre-built Docker Image
ghcr:
	@echo "📦 Pulling pre-built image from GHCR..."
	docker pull $(IMAGE_NAME)
	@echo "✅ Done. Run 'make shell' to start using it."

# Generates .env file
gen-env:
	@echo "UID=$(shell id -u)" > .env
	@echo "GID=$(shell id -g)" >> .env
	@echo "USER=$(shell id -un)" >> .env
	@echo "✅ .env generated with UID=$(UID), GID=$(GID), USER=$(USER)"


# Check container status
status:
	docker compose ps -a

# Access the shell of a container that is running with `up`
shell:
	docker compose exec dev bash

# View the logs of the container running with `up`
logs:
	docker compose logs -f --tail=100 dev

# Check if python, pip, and uv are working
check-env:
	docker compose run --rm dev python -m pip list && docker compose run --rm dev uv pip list

# Check if you are ready to run Docker (permissions, GPU, etc.)
doctor:
	@echo "Checking environment..."
	@docker info >/dev/null 2>&1 && echo "✅ Docker daemon is running" || echo "❌ Docker not running"
	@docker compose version >/dev/null 2>&1 && echo "✅ Docker Compose is installed" || echo "❌ Missing Docker Compose"
	@nvidia-smi >/dev/null 2>&1 && echo "✅ GPU detected: $$(nvidia-smi --query-gpu=name --format=csv,noheader)" || echo "⚠️  No GPU detected"
	@echo "UID: $(UID), GID: $(GID), USER: $(USER)"

# Start and use the container completely (build → up → bash)
start:
	@if ! docker compose ps -q dev | grep -q .; then \
		$(MAKE) rebuild && $(MAKE) up; \
	else \
		echo "⚙️  Container already running."; \
	fi
	@echo "🖥️  Entering shell..."
	@$(MAKE) shell

# Start the container and access it (up → bash)
dev:
	@$(MAKE) up
	@echo "🔁 Container started. Entering container shell..."
	@$(MAKE) shell

# Start and use a new container from scratch (build → up → bash)
restart:
	@$(MAKE) rebuild
	@$(MAKE) up
	@echo "🔁 Container started. Entering container shell..."
	@$(MAKE) shell

# Check if the GPU is available
check-gpu:
	docker compose run --rm dev python -c "import tensorflow as tf; print('GPU:', tf.config.list_physical_devices('GPU'))"

# View the disk usage of the Docker system
disk-usage:
	docker system df

# ========== COMMON TASKS ==========

# Enter the container temporarily (removed after use)
run:
	docker compose run --rm dev

# Run the container in the background (keeps running until 'down' is executed, suitable for long-running dev environments such as Jupyter, FastAPI, or background systems)
up: gen-env
	@echo "UID=$(UID), GID=$(GID), USER=$(USER)"
	docker compose up -d

# Stop the background container
down:
	docker compose down

# Rebuild the image from scratch (without cache)
rebuild:
	docker compose build --no-cache --force-rm

# Stop the container and remove associated volumes (does not remove images)
clean:
	docker compose down --volumes --remove-orphans

# Clean everything including containers, images, and cache
deepclean:
	docker compose down --volumes --remove-orphans
	docker image prune -f
	docker builder prune -af