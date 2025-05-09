ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip \
    curl git build-essential ca-certificates docker.io \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV HOME=/home/vscode
RUN useradd -ms /bin/bash vscode

RUN pip3 install --upgrade pip && pip3 install uv

COPY requirements.txt /tmp/requirements.txt

RUN uv venv /opt/venv && \
    . /opt/venv/bin/activate && \
    uv pip install -r /tmp/requirements.txt

RUN echo "source /opt/venv/bin/activate" >> /home/vscode/.bashrc
ENV PATH="/opt/venv/bin:$PATH"

USER vscode
WORKDIR /workspaces
