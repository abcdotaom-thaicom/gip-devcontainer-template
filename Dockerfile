# -------- Stage 1: Builder --------
FROM nvidia/cuda:12.3.2-runtime-ubuntu22.04 AS builder
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

# Install uv
RUN pip install --upgrade pip && pip install uv

# Copy and install requirements inside venv
COPY requirements.txt /tmp/requirements.txt
RUN uv venv /opt/venv && \
    # uv pip install --python=/opt/venv/bin/python numpy==1.26.4 && \
    uv pip install --python=/opt/venv/bin/python GDAL==3.11.0 && \
    uv pip install --python=/opt/venv/bin/python --no-cache-dir -r /tmp/requirements.txt && \
    /opt/venv/bin/python -c "from osgeo import gdal; print('✅ GDAL OK:', gdal.VersionInfo())" && \
    rm -rf /root/.cache /tmp/*

# -------- Stage 2: Runtime --------
FROM nvidia/cuda:12.3.2-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip libpython3.10 git openssh-client \
    libsqlite3-0 libcurl4 libssl3 libtiff5 libjpeg-turbo8 libpng16-16 \
    libgeos-c1v5 libproj22 libspatialite7 libwebp7 libxml2 \
    libopenjp2-7 zlib1g \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Copy GDAL binaries and libraries
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/include /usr/local/include
RUN ldconfig

# Setup Python path
RUN ln -sf /opt/venv/bin/python3 /usr/local/bin/python

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONPATH="/opt/venv/lib/python3.10/site-packages"

WORKDIR /workspaces

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]
