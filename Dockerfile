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

# Install ARM GCC toolchain (xPack release from GitHub - more reliable than ARM CDN)
RUN cd /tmp && \
    curl -L -o gcc-arm.tar.gz \
      https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v13.2.1-1.1/xpack-arm-none-eabi-gcc-13.2.1-1.1-linux-x64.tar.gz && \
    tar xzf gcc-arm.tar.gz && \
    mv xpack-arm-none-eabi-gcc-13.2.1-1.1 /opt/gcc-arm && \
    rm gcc-arm.tar.gz

ENV PATH="/opt/gcc-arm/bin:${PATH}"

# SDK files are vendored in sdk/ directory (mounted via docker-compose)
# No git clone needed - faster builds, offline capable

CMD ["make", "help"]
