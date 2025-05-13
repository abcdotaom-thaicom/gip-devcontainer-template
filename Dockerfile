# ARG BASE_IMAGE
# FROM ${BASE_IMAGE}

# RUN apt-get update && apt-get install -y \
#     python3 python3-venv python3-pip \
#     curl git build-essential ca-certificates docker.io \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# ENV HOME=/home/vscode
# RUN useradd -ms /bin/bash vscode

# # RUN pip3 install --upgrade pip && pip3 install uv
# RUN pip3 install --no-cache-dir --upgrade pip && pip3 install --no-cache-dir uv

# COPY requirements.txt /tmp/requirements.txt

# RUN uv venv /opt/venv && \
#     . /opt/venv/bin/activate && \
#     uv pip install --no-cache-dir -r /tmp/requirements.txt

# RUN echo "source /opt/venv/bin/activate" >> /home/vscode/.bashrc
# ENV PATH="/opt/venv/bin:$PATH"

# USER vscode
# WORKDIR /workspaces

FROM python:3.10-slim AS builder

RUN apt-get update && apt-get install -y gcc g++ gdal-bin libgdal-dev && \
    pip install --upgrade pip uv

COPY requirements.txt /tmp/requirements.txt

RUN uv venv /opt/venv && \
    . /opt/venv/bin/activate && \
    uv pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm -rf /root/.cache /tmp/* && \
    find /opt/venv -type d -name "__pycache__" -exec rm -rf {} + && \
    find /opt/venv -type f -name "*.pyc" -delete

FROM python:3.10-slim
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN useradd -ms /bin/bash vscode
USER vscode
WORKDIR /workspaces
