# ref: https://github.com/Anjok07/ultimatevocalremovergui/issues/379
# Use the official Nvidia CUDA base image with Ubuntu 22.04
FROM nvcr.io/nvidia/cuda:12.2.0-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

# Combine package installations and cleanup in one layer
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        netbase \
        wget \
        tzdata \
        git \
        mercurial \
        openssh-client \
        subversion \
        procps \
        autoconf \
        automake \
        bzip2 \
        dpkg-dev \
        file \
        g++ \
        gcc \
        imagemagick \
        libbz2-dev \
        libc6-dev \
        libcurl4-openssl-dev \
        libdb-dev \
        libevent-dev \
        libffi-dev \
        libgdbm-dev \
        libglib2.0-dev \
        libgmp-dev \
        libjpeg-dev \
        libkrb5-dev \
        liblzma-dev \
        libmagickcore-dev \
        libmagickwand-dev \
        libmaxminddb-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libpng-dev \
        libpq-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libtool \
        libwebp-dev \
        libxml2-dev \
        libxslt-dev \
        libyaml-dev \
        make \
        patch \
        unzip \
        xz-utils \
        zlib1g-dev \
        default-libmysqlclient-dev \
        python3 \
        python3-dev \
        python3-pip \
        python3-tk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set non-root user
ARG USERNAME=uvr
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && rm -rf /var/lib/apt/lists/* \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install UVR dependencies
RUN apt-get update \
    && apt-get install -y \
        ffmpeg \
        x11-xserver-utils \
        xwayland \
        libx11-6 \
        libxext-dev \
        libxrender-dev \
        libxinerama-dev \
        libxi-dev \
        libxrandr-dev \
        libxcursor-dev \
        libxtst-dev \
        tk-dev \
        freeglut3-dev \
        libgirepository1.0-dev \
    && apt-get clean \ 
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/$USERNAME
USER $USERNAME

# Install UVR
WORKDIR /home/$USERNAME/UVR
COPY ./requirements.txt .
ENV PATH=/home/$USERNAME/.local/bin:$PATH

# Install Requirements and fix Dora scikit deps issue
RUN pip3 install -r requirements.txt && \ 
    pip3 install https://github.com/soudabot/Dora/archive/refs/heads/master.zip && \
    pip3 install pygobject

COPY . .

VOLUME [ "/home/$USERNAME/UVR/sources", "/home/$USERNAME/UVR/results" ]

CMD [ "python3", "UVR.py" ]
