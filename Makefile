SHELL := /bin/bash
UID := $(shell id -u)
GID := $(shell id -g)
USER := $(shell id -un)

export UID GID USER

IMAGE_NAME ?= ghcr.io/abcdotaom-thaicom/gip-dev-cpu-base
IMAGE_TAG ?= v1
FULL_IMAGE := $(IMAGE_NAME):$(IMAGE_TAG)

# ========== UTILITIES ==========

# Pre-built Docker
ghcr:
	@echo "📦 Pulling pre-built image from GHCR..."
	docker pull $(IMAGE_NAME)
	@echo "✅ Done. Run 'make shell' to start using it."

# ตรวจสอบ container
status:
	docker compose ps -a

# เข้า shell ของ container ที่รันแบบ `up`
exec:
	docker compose exec dev bash

# ดู log ของ container ที่รันด้วย `up`
logs:
	docker compose logs -f --tail=100 dev

# ตรวจสอบว่า python, pip, uv ใช้ได้ไหม
check-env:
	docker compose run --rm dev python -m pip list && docker compose run --rm dev uv pip list

# ตรวจสอบว่าคุณพร้อมรัน Docker จริงไหม (permissions, GPU, etc.)
doctor:
	@echo "Checking environment..."
	@docker info >/dev/null 2>&1 && echo "✅ Docker daemon is running" || echo "❌ Docker not running"
	@docker compose version >/dev/null 2>&1 && echo "✅ Docker Compose is installed" || echo "❌ Missing Docker Compose"
	@nvidia-smi >/dev/null 2>&1 && echo "✅ GPU detected: $$(nvidia-smi --query-gpu=name --format=csv,noheader)" || echo "⚠️  No GPU detected"
	@echo "UID: $(UID), GID: $(GID), USER: $(USER)"

# เข้าใช้งาน container แบบครบวงจร (build → up → bash)
start:
	@if ! docker compose ps -q dev | grep -q .; then \
		$(MAKE) rebuild && $(MAKE) up; \
	else \
		echo "⚙️  Container already running."; \
	fi
	@echo "🖥️  Entering shell..."
	@$(MAKE) exec

# เปิดและเข้าใช้งาน container (up → bash)
dev:
	@$(MAKE) up
	@echo "🔁 Container started. Entering container shell..."
	@$(MAKE) exec

# เริ่มต้นเข้าใช้งาน container ใหม่แบบครบวงจร (build → up → bash)
restart:
	@$(MAKE) rebuild
	@$(MAKE) up
	@echo "🔁 Container started. Entering container shell..."
	@$(MAKE) exec

# ดูว่าใช้ GPU ได้ไหม
check-gpu:
	docker compose run --rm dev python -c "import tensorflow as tf; print('GPU:', tf.config.list_physical_devices('GPU'))"

# ดูขนาด disk usage ของ docker system
disk-usage:
	docker system df

# ========== COMMON TASKS ==========

# เข้าสู่ container แบบใช้งานชั่วคราว (ลบทิ้งหลังใช้งาน)
shell:
	docker compose run --rm dev

# รัน container แบบ background (อยู่ตลอด session จนกว่าจะสั่ง down เหมาะกับ server หรือ  long-running dev environment เช่น Jupyter, FastAPI server, หรือระบบเบื้องหลัง)
up:
	docker compose up -d

# ปิด container ที่รันแบบ background
down:
	docker compose down

# สร้าง image ใหม่ทั้งหมด (ไม่มี cache)
rebuild:
	docker compose build --no-cache --force-rm

# ปิด container และลบ volume ที่เกี่ยวข้อง (ไม่ลบ image)
clean:
	docker compose down --volumes --remove-orphans

# ล้างทุกอย่าง ทั้ง container, image, cache
deepclean:
	docker compose down --volumes --remove-orphans
	docker image prune -f
	docker builder prune -af
