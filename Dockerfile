FROM python:3.12-slim
LABEL maintainer="majunminq@163.com"

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
 python3-dev \
 libgl1 \
 rsync \
 libglib2.0-dev
 rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /app/code

# 克隆 ComfyUI 仓库
RUN git clone https://github.com/majunmin/ComfyUI.git .

WORKDIR /app/code/ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
&& git clone https://github.com/tsogzark/ComfyUI-load-image-from-url.git \
&& git clone https://github.com/JettHu/ComfyUI-TCD.git \
&& git clone https://github.com/fofr/ComfyUI-HyperSDXL1StepUnetScheduler.git \
&& git clone https://github.com/TheMistoAI/MistoControlNet-Flux-dev.git \
&& git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git \
&& git clone https://github.com/erosDiffusion/ComfyUI-enricos-nodes.git \
&& git clone https://github.com/shadowcz007/comfyui-mixlab-nodes.git \
&& git clone https://github.com/sipie800/ComfyUI-PuLID-Flux-Enhanced.git \
&& git clone https://github.com/Gourieff/comfyui-reactor-node.git \
&& git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git

WORKDIR /app/code/ComfyUI

# 创建虚拟环境
RUN python -m venv venv

# 激活虚拟环境并安装依赖
RUN . venv/bin/activate && \
    pip install -r requirements.txt --no-cache-dir && \
    pip install -r custom_nodes/ComfyUI-Manager/requirements.txt --no-cache-dir && \
    pip install -r custom_nodes/comfyui-mixlab-nodes/requirements.txt --no-cache-dir && \
    pip install -r custom_nodes/ComfyUI-PuLID-Flux-Enhanced/requirements.txt --no-cache-dir && \
    pip install -r custom_nodes/comfyui-reactor-node/requirements.txt --no-cache-dir

ENV COMFYUI_ADDRESS=0.0.0.0
ENV COMFYUI_PORT=8000
ENV COMFYUI_EXTRA_ARGS=""
ENV INPUT_DIR="/app/data/input"
ENV OUTPUT_DIR="/app/data/output"

# 启动 ComfyUI
CMD ["sh", "-c", ". venv/bin/activate && python main.py --listen 0.0.0.0 --port 8000"]
