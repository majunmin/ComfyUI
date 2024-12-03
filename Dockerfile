FROM python:3.12-slim
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
      mkdir -p /app/data/ && \
      chown  -R ${USER_UID}:${USER_GID} /var/log/eas && \
      chown  -R ${USER_UID}:${USER_GID} /app/data/

USER ${USER_UID}:${USER_GID}

WORKDIR /app
ENV VIRTUAL_ENV=/app/venv
ENV VIRTUAL_ENV_CUSTOM=/app/custom_venv

RUN python -m venv ${VIRTUAL_ENV}


ENV PATH="${VIRTUAL_ENV_CUSTOM}/bin:${VIRTUAL_ENV}/bin:${PATH}"


RUN git clone --recurse-submodules https://github.com/majunmin/ComfyUI.git && git checkout v0.0.1

WORKDIR  /app/code/ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
    && git clone https://github.com/tsogzark/ComfyUI-load-image-from-url.git \
    && git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git \
    && git clone https://github.com/erosDiffusion/ComfyUI-enricos-nodes.git \
    && git clone https://github.com/shadowcz007/comfyui-mixlab-nodes.git \
    && git clone https://github.com/sipie800/ComfyUI-PuLID-Flux-Enhanced.git \
    && git clone https://github.com/Gourieff/comfyui-reactor-node.git \
    && git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git

WORKDIR  /app/code/ComfyUI/custom_nodes

RUN pip install -r --no-cache-dir requirements.txt \
    && pip install -r --no-cache-dir custom_nodes/ComfyUI-Manager/requirements.txt \
    && pip install -r --no-cache-dir custom_nodes/comfyui-mixlab-nodes/requirements.txt \
    && pip install -r --no-cache-dir custom_nodes/ComfyUI-PuLID-Flux-Enhanced/requirements.txt \
    && pip install -r --no-cache-dir custom_nodes/comfyui-reactor-node/requirements.txt



ENV COMFYUI_ADDRESS=0.0.0.0
ENV COMFYUI_PORT=8000
ENV COMFYUI_EXTRA_ARGS=""
ENV INPUT_DIR = "/app/data/input"
ENV OUTPUT_DIR = "/app/data/output"

CMD \
    if [ -d "${VIRTUAL_ENV_CUSTOM}" ]; then \
        rsync -aP "${VIRTUAL_ENV}/" "${VIRTUAL_ENV_CUSTOM}/" ;\
        sed -i "s!${VIRTUAL_ENV}!${VIRTUAL_ENV_CUSTOM}!g" "${VIRTUAL_ENV_CUSTOM}/pyvenv.cfg" ;\
    fi ;\
    python -u main.py --listen ${COMFYUI_ADDRESS} --port ${COMFYUI_PORT} --input-directory "${INPUT_DIR}" --output-directory "${OUTPUT_DIR}"
