FROM nvidia/cuda:12.6.3-devel-ubuntu24.04
LABEL maintainer="majunminq@163.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV COMFYUI_BRANCH=v0.3.6-wow

RUN <<EOF
 apt-get update
 apt-get install -y --no-install-recommends \
 software-properties-common \
 && add-apt-repository ppa:deadsnakes/ppa \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
 wget \
 git \
 git-lfs \
 gcc \
 g++ \
 build-essential \
 fonts-recommended \
 python3.12 \
 python3.12-dev \
 python3.12-venv \
 python3-pip \
 libjpeg-dev \
 zlib1g-dev \
 libgl1 \
 rsync \
 libglib2.0-dev
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*
EOF

USER root


WORKDIR /app/code/ComfyUI

# 克隆 ComfyUI 仓库
RUN git clone https://github.com/majunmin/ComfyUI.git . && git checkout $COMFYUI_BRANCH

WORKDIR /app/code/ComfyUI

# 激活虚拟环境并安装依赖
RUN . /app/code/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --upgrade setuptools && \
    pip install diffusers && \
    pip install -r requirements.txt --no-cache-dir && \
    pip install -r https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/refs/heads/main/requirements.txt --no-cache-dir && \
    pip install -r https://raw.githubusercontent.com/shadowcz007/comfyui-mixlab-nodes/refs/heads/main/requirements.txt --no-cache-dir && \
    pip install -r https://raw.githubusercontent.com/sipie800/ComfyUI-PuLID-Flux-Enhanced/refs/heads/main/requirements.txt --no-cache-dir && \
    pip install -r https://raw.githubusercontent.com/Gourieff/comfyui-reactor-node/refs/heads/main/requirements.txt --no-cache-dir && \
    pip install -r https://raw.githubusercontent.com/ltdrdata/ComfyUI-Impact-Pack/refs/heads/Main/requirements.txt --no-cache-dir && \
    pip install -r https://raw.githubusercontent.com/pythongosssss/ComfyUI-WD14-Tagger/refs/heads/main/requirements.txt && \
    pip install -r https://raw.githubusercontent.com/chflame163/ComfyUI_LayerStyle/refs/heads/main/requirements.txt && \
    pip install -r https://raw.githubusercontent.com/city96/ComfyUI_NetDist/refs/heads/main/requirements.txt && \
    pip install -r https://raw.githubusercontent.com/city96/ComfyUI_NetDist/refs/heads/main/requirements.txt && \
    pip install -r https://raw.githubusercontent.com/Fannovel16/comfyui_controlnet_aux/refs/heads/main/requirements.txt && \
    pip install pip install simple-lama-inpainting


ENV COMFYUI_ADDRESS=0.0.0.0
ENV COMFYUI_PORT=8000
ENV COMFYUI_EXTRA_ARGS=""

# 启动 ComfyUI
CMD ["sh", "-c", "python main.py --listen 0.0.0.0 --port 8000"]
