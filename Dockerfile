# 使用官方的 Ubuntu 镜像作为基础镜像
FROM ubuntu:latest

# 设置环境变量，避免交互式配置提示
ENV DEBIAN_FRONTEND=noninteractive

# 更新包列表并安装必要的依赖项
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libgdbm-dev \
    libdb5.3-dev \
    libbz2-dev \
    libexpat1-dev \
    liblzma-dev \
    tk-dev \
    libffi-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 设置 Python 3.12 为默认 Python 版本
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# 安装 pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3

# 设置工作目录
WORKDIR /app/code

# 克隆 ComfyUI 仓库
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

WORKDIR  /app/code/ComfyUI/custom_nodes
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


WORKDIR  /app/code/ComfyUI/
RUN pip install -r --no-cache-dir requirements.txt \
    && pip install -r --no-cache-dir custom_nodes/ComfyUI-Manager/requirements.txt \
    && pip install -r --no-cache-dir custom_nodes/comfyui-mixlab-nodes/requirements.txt \
    && pip install -r --no-cache-dir custom_nodes/ComfyUI-PuLID-Flux-Enhanced/requirements.txt \
    && pip install -r --no-cache-dir custom_nodes/comfyui-reactor-node/requirements.txt



WORKDIR  /app/code/

# 创建虚拟环境
RUN python3 -m venv venv

# 激活虚拟环境并安装依赖
RUN . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 && \
    pip install -r requirements.txt

# 暴露 ComfyUI 的默认端口
EXPOSE 8000

# 启动 ComfyUI
CMD ["sh", "-c", ". venv/bin/activate && python main.py --listen 0.0.0.0 --port 8000"]