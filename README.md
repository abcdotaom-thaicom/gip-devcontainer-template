# 🐳 GIP Development Container

A reproducible and portable Python 3.10-based development environment tailored for **Geospatial Data Science**, **Data Engineering**, and **Machine Learning** workflows—supporting both **CPU-only** and **GPU-accelerated** use cases.

This repository provides two separate environments:
- 🧠 `cpu-base`: Optimized for general-purpose data science and GIS workloads
- ⚡ `gpu-base`: Built for GPU-enabled systems with CUDA support (e.g., for PyTorch training, deep learning)

---

## 📦 Base Image Variants

- **CPU**: `ghcr.io/abcdotaom-thaicom/gip-dev-cpu-base`
- **GPU**: `ghcr.io/abcdotaom-thaicom/gip-dev-gpu-base`

---

## 🔧 Common Features

- Python 3.10 with virtual environment via [`uv`](https://github.com/astral-sh/uv)
- GDAL 3.11 built from source
- Ready-to-use DevContainer config for VS Code
- Multi-stage Docker builds for lean image size

---

# 💻 Part 1: CPU Base

## 🔹 Overview

A reproducible and portable Python 3.10-based development environment designed for Geospatial Data Science, Data Engineering, and Python-based analytics—built with performance and team collaboration in mind.

This container includes a full Python virtual environment (via `uv`), GDAL compiled from source, and essential scientific and geospatial libraries.

---

## 🧭 Key Features (CPU)

- Python 3.10 with `uv`
- GDAL 3.11 compiled from source
- Pre-installed packages: GeoPandas, Rasterio, PyTorch (CPU), NumPy
- Compatible across Linux-based environments
- DevContainer-ready

---

## 🏗️ Usage (CPU Image)

```bash
docker pull ghcr.io/abcdotaom-thaicom/gip-dev-cpu-base:v1.0.1
```

Or run with make:

```bash
make ghcr
```

[ghcr.io/abcdotaom-thaicom/gip-dev-cpu-base](https://github.com/users/abcdotaom-thaicom/packages/container/package/gip-dev-cpu-base)

---

# ⚡ Part 2: GPU Base

## 🔹 Overview

A GPU-accelerated development environment tailored for Geospatial Data Science, Deep Learning, and High-Performance Python workloads. Based on `nvidia/cuda:12.3.2-runtime-ubuntu22.04`.

---

## ⚡️ Key Features (GPU)

- CUDA 12.3 + NVIDIA runtime
- GDAL 3.11 compiled from source
- PyTorch (GPU), cuDNN, NumPy
- NVIDIA Container Toolkit support (`--gpus all`)
- DevContainer-ready

---

## 🏗️ Usage (GPU Image)

```bash
docker pull ghcr.io/abcdotaom-thaicom/gip-dev-gpu-base:v1.0.1
```

Or run with make:

```bash
make ghcr
```

[ghcr.io/abcdotaom-thaicom/gip-dev-gpu-base](https://github.com/users/abcdotaom-thaicom/packages/container/package/gip-dev-gpu-base)

---

## 🚨 GPU Runtime Requirements

- NVIDIA Driver (compatible with CUDA 12.3)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
- `docker` and `docker compose` installed
- Use Docker Compose with `--runtime=nvidia`

---

# 💼 DevContainer Support (VS Code)

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open project in VS Code
3. Select **"Reopen in Container"**
4. Use either `cpu-base` or `gpu-base` depending on your setup

💡 **Tip:** Before launching the DevContainer, ensure that the `.env` file is generated to correctly map user permissions inside the container:  
Run `make gen-env` or manually define:

```bash
echo "UID=$(id -u)" > .env
echo "GID=$(id -g)" >> .env
echo "USER=$(id -un)" >> .env
```

🔧 **Then edit `.devcontainer/devcontainer.json`** and replace:

```json
"remoteUser": "vscode"
```

with:

```json
"remoteUser": "Your USER"
```

---

## 🚀 Quick Start (Both Variants)

### 🧰 Without Makefile

Before running Docker Compose, generate the environment file:

```bash
echo "UID=$(id -u)" > .env
echo "GID=$(id -g)" >> .env
echo "USER=$(id -un)" >> .env
```

Then run the container:

```bash
docker compose run --rm dev
```

Or in the background:

```bash
docker compose up -d
docker compose exec dev bash
```

Stop:

```bash
docker compose down
```

---

### ⚙️ With Makefile

| Command          | Description                                  |
|------------------|----------------------------------------------|
| `make gen-env`   | Generate `.env` file for Compose             |
| `make run`       | Temporary container session                  |
| `make up`        | Start container in background                |
| `make shell`     | Attach to running container                  |
| `make start`     | Build → Run → Attach                         |
| `make rebuild`   | Rebuild image without cache                  |
| `make doctor`    | Check environment readiness (Docker, GPU)    |
| `make ghcr`      | Pull pre-built image from GHCR               |
| `make check-env` | Validate Python + uv                         |
| `make check-gpu` | Check GPU devices inside container (GPU only)|

---

## 📁 Repository Structure

```
.
├── Dockerfile               # Dockerfile (CPU or GPU variant)
├── docker-compose.yaml      # Docker Compose config
├── Makefile                 # Automation commands
├── requirements.txt         # Python dependencies
├── .github/
│   └── workflows/
│       └── publish-ghcr.yml # CI workflow
├── .devcontainer/
│   └── devcontainer.json    # VS Code DevContainer
└── main.py                  # Example script or entry point
```

---

## 👥 Maintainers

- **Thanakit S.** ([@abcdotaom-thaicom](https://github.com/abcdotaom-thaicom)) — _Geospatial Data Scientist_
- GIP (Geospatial Intelligence Platform) Team

---

## 📫 Need Help?

Feel free to [create an issue](https://github.com/abcdotaom-thaicom/gip-devcontainer-template/issues) or ping the maintainer.
