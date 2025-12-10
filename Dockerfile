FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    tar \
    xz-utils \
    make \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Install ARM GCC toolchain
RUN cd /tmp && \
    curl -L -O --progress-bar \
      -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
      https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    tar xf arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    mv arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi /opt/gcc-arm && \
    rm arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz

ENV PATH="/opt/gcc-arm/bin:${PATH}"

# SDK files are vendored in sdk/ directory (mounted via docker-compose)
# No git clone needed - faster builds, offline capable

CMD ["make", "help"]
