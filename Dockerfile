FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    tar \
    xz-utils \
    git \
    make \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN cd /tmp && \
    wget -q https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    tar xf arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    mv arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi /opt/gcc-arm && \
    rm arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz

ENV PATH="/opt/gcc-arm/bin:${PATH}"

RUN cd /tmp && \
    git clone --depth 1 https://github.com/nxp-mcuxpresso/mcux-sdk.git && \
    mkdir -p /opt/sdk && \
    cd mcux-sdk && \
    cp devices/MCXA155/MCXA155.h /opt/sdk/ && \
    cp devices/MCXA155/MCXA155_features.h /opt/sdk/ && \
    cp devices/MCXA155/system_MCXA155.h /opt/sdk/ && \
    cp devices/MCXA155/fsl_device_registers.h /opt/sdk/ && \
    cp devices/MCXA155/system_MCXA155.c /opt/sdk/ && \
    cp CMSIS/Core/Include/core_cm33.h /opt/sdk/ && \
    cp CMSIS/Core/Include/cmsis_gcc.h /opt/sdk/ && \
    cp CMSIS/Core/Include/cmsis_compiler.h /opt/sdk/ && \
    cp CMSIS/Core/Include/cmsis_version.h /opt/sdk/ && \
    cp devices/MCXA155/gcc/startup_MCXA155.S /opt/sdk/ && \
    cp devices/MCXA155/gcc/MCXA155_flash.ld /opt/sdk/ && \
    cp devices/MCXA155/drivers/fsl_common.h /opt/sdk/ && \
    cp devices/MCXA155/drivers/fsl_common.c /opt/sdk/ && \
    cp devices/MCXA155/drivers/fsl_clock.h /opt/sdk/ && \
    cp devices/MCXA155/drivers/fsl_clock.c /opt/sdk/ && \
    cp devices/MCXA155/drivers/fsl_lpuart.h /opt/sdk/ && \
    cp devices/MCXA155/drivers/fsl_lpuart.c /opt/sdk/ && \
    cd / && \
    rm -rf /tmp/mcux-sdk

CMD ["make", "help"]
