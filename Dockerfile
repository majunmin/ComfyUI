FROM python:3.11-slim
LABEL maintainer="majunminq@163.com"

ARG USERNAME=comfyui
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN <<EOF
    groupadd --gid ${USER_GID} ${USERNAME}
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}
EOF

RUN <<EOF
    apt-get update
    apt-get install -y --no-install-recommends \
        wget \
        git \
        git-lfs \
        gcc \
        g++ \
        build-essential \
        fonts-recommended \
        python3-dev    \
        libgl1 \
        rsync \
                libglib2.0-dev
        rm -rf /var/lib/apt/lists/*
EOF

RUN   mkdir -p /var/log/eas && \
      mkdir -p /code/stable-diffusion-webui/data && \
      chown  -R ${USER_UID}:${USER_GID} /var/log/eas && \
      chown  -R ${USER_UID}:${USER_GID} /code/stable-diffusion-webui/data

USER ${USER_UID}:${USER_GID}

WORKDIR /app
ENV VIRTUAL_ENV=/app/venv
ENV VIRTUAL_ENV_CUSTOM=/app/custom_venv

RUN python -m venv ${VIRTUAL_ENV}


ENV PATH="${VIRTUAL_ENV_CUSTOM}/bin:${VIRTUAL_ENV}/bin:${PATH}"


RUN git clone --recurse-submodules https://github.com/majunmin/ComfyUI.git \
    && cd ComfyUI && git checkout feature/v0.2.4

WORKDIR  /app/ComfyUI

RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir pip-system-certs \
    && cd custom_nodes \
    && git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
    && git clone https://github.com/Gourieff/comfyui-reactor-node.git \
    && git clone https://github.com/balazik/ComfyUI-PuLID-Flux.git \
    && pip install --no-cache-dir -r ComfyUI-Manager/requirements.txt \
    && pip install --no-cache-dir -r comfyui-reactor-node/requirements.txt \
    && pip install --no-cache-dir -r ComfyUI-PuLID-Flux/requirements.txt


ENV COMFYUI_ADDRESS=0.0.0.0
ENV COMFYUI_PORT=8000
ENV COMFYUI_EXTRA_ARGS=""

CMD \
    if [ -d "${VIRTUAL_ENV_CUSTOM}" ]; then \
        rsync -aP "${VIRTUAL_ENV}/" "${VIRTUAL_ENV_CUSTOM}/" ;\
        sed -i "s!${VIRTUAL_ENV}!${VIRTUAL_ENV_CUSTOM}!g" "${VIRTUAL_ENV_CUSTOM}/pyvenv.cfg" ;\
    fi ;\
    python -u main.py --listen ${COMFYUI_ADDRESS} --port ${COMFYUI_PORT}
