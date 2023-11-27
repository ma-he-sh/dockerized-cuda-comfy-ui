FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive TZ=America/Toronto

ARG USE_PERSISTENT_DATA

RUN apt-get -o Acquire::Max-FutureTime=86400 update && apt-get install -y \
    git \
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev git git-lfs  \
    ffmpeg libsm6 libxext6 cmake libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/* \
    && git lfs install

WORKDIR /code
COPY ./requirements.txt /code/requirements.txt

RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

ARG PYTHON_VERSION=3.10.12

RUN curl https://pyenv.run | bash
ENV PATH=$HOME/.pyenv/shims:$HOME/.pyenv/bin:$PATH

RUN pyenv install $PYTHON_VERSION && \
    pyenv global $PYTHON_VERSION && \
    pyenv rehash && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir \
    datasets

VOLUME ["/src"]
WORKDIR /src

RUN git clone https://github.com/comfyanonymous/ComfyUI .
RUN pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121

RUN echo "environment ready"

RUN pip install -r requirements.txt

RUN echo "done"

CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "7860"]
