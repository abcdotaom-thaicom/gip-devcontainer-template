# 🐳 GIP Development Container (CPU Base)

A reproducible and portable Python 3.10-based development environment designed for Geospatial Data Science, Data Engineering, and Python-based analytics—built with performance and team collaboration in mind.

This container includes a full Python virtual environment (via `uv`), GDAL compiled from source, and essential scientific and geospatial libraries. It is published as a base image to GitHub Container Registry (GHCR) and is intended to serve as a shared environment for teams across multiple servers.

---

## 🧭 Key Features

- **Python 3.10** with virtual environment via [`uv`](https://github.com/astral-sh/uv)
- **GDAL 3.11** compiled from source
- Pre-installed packages: GeoPandas, Rasterio, PyTorch (CPU), numpy, etc.
- Multi-stage Docker build optimized for CI/CD pipelines
- Ready for [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) in VS Code
- Compatible across **Linux-based Docker environments**, including cloud-based and on-prem servers

---

## 🏗️ Using the Official Base Image (GHCR)

Pull the pre-built CPU-based image:

```bash
docker pull ghcr.io/abcdotaom-thaicom/gip-dev-cpu-base:v1.0.1
```

Or use:

```bash
make ghcr
make shell
```

The image is hosted on:

[ghcr.io/abcdotaom-thaicom/gip-dev-cpu-base](https://github.com/users/abcdotaom-thaicom/packages/container/package/gip-dev-cpu-base)

---

## 🧪 Technology Stack Starter

- **Base Image**: `python:3.10-slim`
- **Geospatial Libraries**: GDAL, GeoPandas
- **Machine Learning**: PyTorch
- **Utilities**: uv

---

## 💻 DevContainer Support (VS Code)

This container is configured for DevContainers. To use with VS Code:

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open the project in VS Code
3. Choose **"Reopen in Container"**

VS Code will use `devcontainer.json` and Docker Compose to set up the environment.

---

## 📁 Repository Structure

```
.
├── Dockerfile                 # Multi-stage Docker build
├── docker-compose.yaml        # Service configuration
├── Makefile                   # Task automation
├── requirements.txt           # Python package list
├── .github/workflows/         # CI for GHCR publishing
├── devcontainer          # DevContainer integration
└── .gitignore                 # Clean repo hygiene
```

---

## 🚀 Quick Start

### 🧰 For Users **without `make`**

1. Install Docker (Linux) or Docker Desktop (Windows/Mac)
2. Run in temporary session:

   ```bash
   docker compose run --rm dev
   ```

3. Or run in background:

   ```bash
   docker compose up -d
   docker compose exec dev bash
   ```

4. Stop:

   ```bash
   docker compose down
   ```

---

### ⚙️ For Users **with `make` installed**

Run these high-level commands:

| Command          | Description                                  |
|------------------|----------------------------------------------|
| `make shell`     | Run container in a temporary shell session   |
| `make up`        | Start container in background                |
| `make exec`      | Attach to a running container                |
| `make start`     | Build → Run → Attach (Full lifecycle)        |
| `make rebuild`   | Rebuild image without cache                  |
| `make doctor`    | Environment readiness checks (Docker, GPU)   |
| `make ghcr`      | Pull pre-built image from GHCR               |
| `make check-env` | Validate Python and uv availability          |

---

## 👥 Maintainers

- **Thanakit S.** ([@abcdotaom-thaicom](https://github.com/abcdotaom-thaicom)) — _Geospatial Data Scientist_
- GIP (Geospatial Intelligence Platform) Team

---

## 📫 Need Help?

For questions, ideas, or issues, please [create an issue](https://github.com/abcdotaom-thaicom/gip-devcontainer-template/issues) or contact the maintainer directly.