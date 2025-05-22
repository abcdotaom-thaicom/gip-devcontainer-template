# -------- Stage 1: Builder --------
FROM python:3.10-slim AS builder

ARG DEBIAN_FRONTEND=noninteractive

# Install system dependencies for building GDAL
RUN apt-get update && apt-get install -y \
    curl git build-essential cmake ninja-build pkg-config \
    python3 python3-pip python3-venv python3-dev \
    libsqlite3-dev libcurl4-openssl-dev libssl-dev \
    libtiff-dev libjpeg-dev libpng-dev libgeos-dev \
    libproj-dev libspatialite-dev libwebp-dev libxml2-dev \
    libopenjp2-7-dev zlib1g-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Build GDAL 3.11.0 from source
WORKDIR /tmp
RUN curl -L -o gdal.tar.gz https://github.com/OSGeo/gdal/archive/refs/tags/v3.11.0.tar.gz && \
    tar -xzf gdal.tar.gz && \
    cd gdal-3.11.0 && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j$(nproc) && make install && ldconfig

# Set environment so pip can find GDAL headers
ENV CPLUS_INCLUDE_PATH=/usr/local/include
ENV C_INCLUDE_PATH=/usr/local/include

# Install uv and setup virtual environment
RUN pip install --upgrade pip && pip install uv

# Copy and install requirements inside venv
COPY requirements.txt /tmp/requirements.txt
RUN uv venv /opt/venv && \
    uv pip install --python=/opt/venv/bin/python GDAL==3.11.0 && \
    uv pip install --python=/opt/venv/bin/python --no-cache-dir -r /tmp/requirements.txt && \
    /opt/venv/bin/python -c "from osgeo import gdal; print('✅ GDAL OK:', gdal.VersionInfo())" && \
    rm -rf /root/.cache /tmp/* && \
    find /opt/venv -type d -name "__pycache__" -exec rm -rf {} + && \
    find /opt/venv -type f -name "*.pyc" -delete

# -------- Stage 2: Runtime --------
FROM python:3.10-slim

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
ARG DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip libpython3.10 git openssh-client \
    libsqlite3-0 libcurl4 libssl3 libtiff-dev libjpeg62-turbo libpng16-16 \
    libgeos-dev libproj-dev libspatialite7 libwebp7 libxml2 \
    libopenjp2-7 zlib1g \
    python-is-python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy venv and GDAL libs from builder
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/include /usr/local/include
RUN ldconfig

# Create non-root user
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID --create-home $USERNAME && \
    mkdir -p /home/$USERNAME/.ssh && chmod 700 /home/$USERNAME/.ssh && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME

ENV PATH="/opt/venv/bin:/usr/local/bin:/usr/bin:$PATH"
ENV PYTHONPATH="/opt/venv/lib/python3.10/site-packages"
ENV HOME=/home/$USERNAME

USER $USERNAME
WORKDIR /workspaces

CMD ["bash"]
