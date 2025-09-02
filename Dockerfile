# -------- Stage 1: Builder --------
FROM python:3.10-slim AS builder

ARG DEBIAN_FRONTEND=noninteractive

# Build deps (GDAL) + Java
RUN apt-get update && apt-get install -y \
    curl git build-essential cmake ninja-build pkg-config \
    python3 python3-pip python3-venv python3-dev \
    libsqlite3-dev libcurl4-openssl-dev libssl-dev \
    libtiff-dev libjpeg-dev libpng-dev libgeos-dev \
    libproj-dev libspatialite-dev libwebp-dev libxml2-dev \
    libopenjp2-7-dev zlib1g-dev \
    openjdk-17-jre-headless \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
# Build GDAL 3.11.0
RUN curl -L -o gdal.tar.gz https://github.com/OSGeo/gdal/archive/refs/tags/v3.11.0.tar.gz && \
    tar -xzf gdal.tar.gz && cd gdal-3.11.0 && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j"$(nproc)" && make install && ldconfig

ENV CPLUS_INCLUDE_PATH=/usr/local/include \
    C_INCLUDE_PATH=/usr/local/include

# uv + venv + project reqs
RUN pip install --upgrade pip && pip install uv
COPY requirements.txt /tmp/requirements.txt
RUN uv venv /opt/venv && \
    uv pip install --python=/opt/venv/bin/python GDAL==3.11.0 && \
    uv pip install --python=/opt/venv/bin/python --no-cache-dir -r /tmp/requirements.txt && \
    /opt/venv/bin/python -c "from osgeo import gdal; print('✅ GDAL OK:', gdal.VersionInfo())" && \
    rm -rf /root/.cache /tmp/* && \
    find /opt/venv -type d -name "__pycache__" -exec rm -rf {} + && \
    find /opt/venv -type f -name "*.pyc" -delete

# SNAP Desktop
RUN curl -L -o /tmp/snap_installer.sh https://download.esa.int/step/snap/12.0/installers/esa-snap_all_linux-12.0.0.sh && \
    chmod +x /tmp/snap_installer.sh && \
    /tmp/snap_installer.sh -q -dir /opt/snap && \
    rm /tmp/snap_installer.sh

# esa-snappy (อย่ารัน snappy-conf ใน build)
RUN uv pip install --python=/opt/venv/bin/python --no-cache-dir esa-snappy

# -------- Stage 2: Runtime --------
FROM python:3.10-slim
ARG DEBIAN_FRONTEND=noninteractive

# Runtime libs + Linux tools + Java
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip libpython3.10 git openssh-client \
    libsqlite3-0 libcurl4 libssl3 libtiff-dev libjpeg62-turbo libpng16-16 \
    libgeos-dev libproj-dev libspatialite7 libwebp7 libxml2 \
    libopenjp2-7 zlib1g python-is-python3 \
    iproute2 iputils-ping net-tools dnsutils procps psmisc lsof \
    bash-completion nano vim-tiny less htop \
    openjdk-17-jre-headless \
 && rm -rf /var/lib/apt/lists/*

# bring artifacts
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /opt/snap /opt/snap
RUN ldconfig

# Entrypoint (root only)
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV PATH="/opt/venv/bin:/usr/local/bin:/usr/bin:$PATH" \
    PYTHONPATH="/opt/venv/lib/python3.10/site-packages" \
    SNAP_HOME=/opt/snap \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /workspaces
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]
