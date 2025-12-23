# ============================================
# Neuroïne Dev Image
# Image unifiée dev/prod avec toolchain complet
# ============================================
FROM ubuntu:24.04

ARG LLVM_VERSION=18
ARG SCCACHE_VERSION=0.8.1

# Éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive

# Dépendances de base
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    ca-certificates \
    git \
    ninja-build \
    cmake \
    python3 \
    python3-pip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# LLVM Toolchain complet via apt.llvm.org
RUN wget -qO /tmp/llvm.sh https://apt.llvm.org/llvm.sh && \
    chmod +x /tmp/llvm.sh && \
    /tmp/llvm.sh ${LLVM_VERSION} all && \
    rm /tmp/llvm.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Symlinks pour commandes sans version
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VERSION} 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VERSION} 100 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-${LLVM_VERSION} 100 && \
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-${LLVM_VERSION} 100 && \
    update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-${LLVM_VERSION} 100 && \
    update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-${LLVM_VERSION} 100 && \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-${LLVM_VERSION} 100 && \
    update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-${LLVM_VERSION} 100 && \
    update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-${LLVM_VERSION} 100 && \
    update-alternatives --install /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-${LLVM_VERSION} 100 && \
    update-alternatives --install /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-${LLVM_VERSION} 100

# sccache (binaire précompilé)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then DOWNLOAD_ARCH="x86_64-unknown-linux-musl"; \
    elif [ "$ARCH" = "aarch64" ]; then DOWNLOAD_ARCH="aarch64-unknown-linux-musl"; fi && \
    curl -fsSL "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${DOWNLOAD_ARCH}.tar.gz" | tar xz -C /tmp && \
    mv /tmp/sccache-v${SCCACHE_VERSION}-${DOWNLOAD_ARCH}/sccache /usr/local/bin/sccache && \
    chmod +x /usr/local/bin/sccache && \
    rm -rf /tmp/sccache-*

# Utilisateur dev (UID/GID 1000 pour compatibilité)
RUN groupadd --gid 1000 dev && \
    useradd --uid 1000 --gid 1000 -m -s /bin/bash dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Variables d'environnement
ENV CC=clang \
    CXX=clang++ \
    CMAKE_CXX_COMPILER_LAUNCHER=sccache

USER dev
WORKDIR /workspace
