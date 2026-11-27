# gip-devcontainer-template

Starter files for a containerised Python development environment used by the GIP
(Geospatial Intelligence Platform) projects. Copy it into a new project to get a
`Dockerfile`, a `docker-compose.yaml`, a `Makefile` and a VS Code DevContainer config
that all agree with each other.

## Read this first: which branch has what

This repository is split by branch. The branch you are on decides what you get.

| Ref | What it holds |
|---|---|
| `main` (this README) | The minimal starter: `Dockerfile`, `docker-compose.yaml`, `Makefile`, `requirements.txt`, `.devcontainer/devcontainer.json`. Base image `tensorflow/tensorflow:2.15.0`, a `uv` virtualenv at `/opt/venv`, user `vscode`. |
| `origin/develop/dev-cpu-base` | The CPU image source: `python:3.10-slim`, GDAL 3.11.0 built from source, multi-stage build, `numpy`, `geopandas`, `torch`. Has the full Makefile (`ghcr`, `doctor`, `start`, `check-env`) and `publish-ghcr.yml`. |
| `origin/develop/dev-gpu-base` | The GPU image source: `nvidia/cuda:12.3.2-runtime-ubuntu22.04`, same GDAL build, adds `make check-gpu`. |
| Local `dev-cpu-base`, `dev-gpu-base`, `develop-base`, `dev-cpu-base-old` | Older local branches from the first setup (2025-05-09). Not the source of the published images. |

Published images (GitHub Container Registry):

- CPU: `ghcr.io/abcdotaom-thaicom/gip-dev-cpu-base`
- GPU: `ghcr.io/abcdotaom-thaicom/gip-dev-gpu-base`

## What is inside (`main`)

| File | Purpose |
|---|---|
| `Dockerfile` | `ARG BASE_IMAGE` -> installs python3, git, curl, build tools, `docker.io`; creates user `vscode`; installs `uv`; creates `/opt/venv` and installs `requirements.txt`; puts `/opt/venv/bin` first on `PATH`. |
| `docker-compose.yaml` | Service `dev`, image `gip-devcontainer-template`, container `gip-dev`, mounts the project at `/workspaces` and the Docker socket. |
| `Makefile` | `shell` (throw-away container), `up`, `down`, `rebuild` (no cache), `clean`. |
| `requirements.txt` | Python packages for the venv (currently only `Geopandas`). |
| `.devcontainer/devcontainer.json` | VS Code: service `dev`, workspace `/workspaces`, user `vscode`, Python and Jupyter extensions. |

Known rough edges on `main` (not changed here):

- `.devcontainer/devcontainer.json` points at `../docker-compose.yml`, but the file is named `docker-compose.yaml`, so "Reopen in Container" fails until one is renamed.
- `docker-compose.yaml` has `version: '3.10'`, which is a Python version, not a Compose file version (Compose ignores the key).
- The devcontainer name is `gip-python310-uv`, but the `main` base image is TensorFlow's, not the Python 3.10 image of the `develop/*` branches.

## Use it in a new project

Pick the published image (recommended for service work) or build from the template.

### A. Use the published image (what most projects do)

In the new project's `docker-compose.yaml`:

```yaml
services:
  dev:
    image: ghcr.io/abcdotaom-thaicom/gip-dev-cpu-base:v1.0.2
    container_name: myproject-dev
    working_dir: /workspaces
    volumes:
      - .:/workspaces
    command: bash -l
```

and in the `Makefile`:

```make
IMAGE_NAME ?= ghcr.io/abcdotaom-thaicom/gip-dev-cpu-base:v1.0.2
ghcr:
	docker pull $(IMAGE_NAME)
shell:
	docker compose run --rm dev
```

Pin an explicit tag. Do not use `latest`.

### B. Copy the template

```bash
git clone https://github.com/abcdotaom-thaicom/gip-devcontainer-template.git myproject
cd myproject
rm -rf .git                      # start a fresh history for the new project
# edit requirements.txt, container_name and image in docker-compose.yaml
make shell                       # builds on first use, opens a shell as user vscode
```

For VS Code: rename `docker-compose.yaml` to `docker-compose.yml` (or fix the path in
`.devcontainer/devcontainer.json`), then "Dev Containers: Reopen in Container".

## Which projects use it

Verified by searching `/fs2/thanakit` for `gip-dev-cpu-base`, `gip-dev-gpu-base`,
`gip-devcontainer-template` (2026-11-27).

Pull the published image by tag in `docker-compose.yaml` / `Makefile`:

| Project | Image tag |
|---|---|
| `poc`, `deforestation`, `other_task`, `rice_insurance` | `gip-dev-cpu-base:v1.0.2` |
| `satellogic-adapter` | `gip-dev-cpu-base:v1.0.3` |
| `gip-geospatial-orchestrator` | `gip-dev-gpu-base:v1.0.2` |
| `gistda_proc/flood` | `Makefile` default `gip-dev-cpu-base:v1.0.2`; its compose builds its own image `gistda-flood-pipeline:local` from its own Dockerfile |

Carry a copy of the template inside the project:

| Project | Where |
|---|---|
| `validation/index_timeseries` | `validation/index_timeseries/gip-devcontainer-template/` |
| `project_test` | `project_test/gip-devcontainer-template/` |

Derived from it, with its own image:

| Project | Note |
|---|---|
| `tgia` | README and `publish-ghcr.yml` copied from the template; compose uses `gip-dev-cpu-snappy:v1.0.3` and its own `Dockerfile` |

Other repos that mention the images (docs or examples only): see the search above for
`kevin_code/pipelines/*` (Dockerfiles/compose) and `athena/neurons/*`.

## Version and change notes

Git tags in this repository:

| Tag | Commit | Date | Meaning |
|---|---|---|---|
| `v1.0.0-cpu` | `48ce741` | 2025-05-22 | first CPU image |
| `v1.0.1-cpu` | `fd06be2` | 2025-05-22 | CPU image |
| `v1.0.1-gpu` | `cb54156` | 2025-05-23 | first GPU image (CUDA 12.3.2) |

Release process (on the `develop/*` branches): pushing a tag `vX.Y.Z-cpu` or `vX.Y.Z-gpu`
runs `.github/workflows/publish-ghcr.yml`, which builds the image and pushes
`gip-dev-<cpu|gpu>-base:vX.Y.Z`. (On `main` the `.github/workflows/publish-ghcr.yml` file is
present only as an untracked empty file.)

History:

- 2025-05-09: initial CPU DevContainer setup (what `main` still contains).
- 2025-05-21 to 2025-05-23: GDAL 3.11.0 multi-stage build, GPU variant, full Makefile, GHCR publish workflow, README (on `develop/*`).

Open gaps: projects reference image tags `v1.0.2` and `v1.0.3` that have no git tag in
this repository (the `v1.0.2`/`v1.0.3` builds were not found in the tag list), and `main`
has not received the `develop/*` work.

## Maintainers

Thanakit S. and the GIP team. Issues:
<https://github.com/abcdotaom-thaicom/gip-devcontainer-template/issues>
