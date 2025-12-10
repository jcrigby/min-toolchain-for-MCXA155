#!/bin/bash
set -e

# MCXA155 Minimal Bootstrap
# Run in empty directory to create complete project structure
# Downloads and vendors SDK files for offline, reproducible builds

PROJECT_NAME="mcxa155-minimal"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "MCXA155 Minimal Project Bootstrap"
echo "=========================================="
echo ""

# Create directory structure
echo "Creating directory structure..."
mkdir -p src
mkdir -p build
mkdir -p scripts
mkdir -p docs
mkdir -p sdk/cmsis
mkdir -p sdk/device
mkdir -p sdk/drivers

echo "Directories created"
echo ""

# Download and vendor SDK files
echo "Downloading SDK files..."

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "ERROR: git is required to download SDK files"
    echo "Please install git and try again"
    exit 1
fi

# Download CMSIS from ARM
echo "  Fetching ARM CMSIS..."
CMSIS_TMP=$(mktemp -d)
git clone --depth 1 --filter=blob:none --sparse https://github.com/ARM-software/CMSIS_6.git "$CMSIS_TMP" 2>/dev/null
cd "$CMSIS_TMP"
git sparse-checkout set CMSIS/Core/Include 2>/dev/null
CMSIS_COMMIT=$(git rev-parse HEAD)
CMSIS_DATE=$(git log -1 --format=%ci | cut -d' ' -f1)
cp CMSIS/Core/Include/core_cm33.h "$SCRIPT_DIR/sdk/cmsis/"
cp CMSIS/Core/Include/cmsis_version.h "$SCRIPT_DIR/sdk/cmsis/"
cp CMSIS/Core/Include/cmsis_compiler.h "$SCRIPT_DIR/sdk/cmsis/"
cp CMSIS/Core/Include/cmsis_gcc.h "$SCRIPT_DIR/sdk/cmsis/"
cd "$SCRIPT_DIR"
rm -rf "$CMSIS_TMP"
echo "  CMSIS files downloaded (commit: ${CMSIS_COMMIT:0:8})"

# Download NXP SDK
echo "  Fetching NXP MCUXpresso SDK..."
SDK_TMP=$(mktemp -d)
git clone --depth 1 --filter=blob:none --sparse https://github.com/nxp-mcuxpresso/mcux-sdk.git "$SDK_TMP" 2>/dev/null
cd "$SDK_TMP"
git sparse-checkout set devices/MCXA155 drivers/common drivers/lpuart 2>/dev/null
SDK_COMMIT=$(git rev-parse HEAD)
SDK_DATE=$(git log -1 --format=%ci | cut -d' ' -f1)

# Copy device files
cp devices/MCXA155/MCXA155.h "$SCRIPT_DIR/sdk/device/"
cp devices/MCXA155/MCXA155_features.h "$SCRIPT_DIR/sdk/device/"
cp devices/MCXA155/system_MCXA155.h "$SCRIPT_DIR/sdk/device/"
cp devices/MCXA155/system_MCXA155.c "$SCRIPT_DIR/sdk/device/"
cp devices/MCXA155/fsl_device_registers.h "$SCRIPT_DIR/sdk/device/"
cp devices/MCXA155/gcc/startup_MCXA155.S "$SCRIPT_DIR/sdk/device/"
cp devices/MCXA155/gcc/MCXA155_flash.ld "$SCRIPT_DIR/sdk/device/"

# Copy driver files
cp drivers/common/fsl_common.h "$SCRIPT_DIR/sdk/drivers/"
cp drivers/common/fsl_common.c "$SCRIPT_DIR/sdk/drivers/"
cp drivers/common/fsl_common_arm.h "$SCRIPT_DIR/sdk/drivers/"
cp drivers/common/fsl_common_arm.c "$SCRIPT_DIR/sdk/drivers/"
cp devices/MCXA155/drivers/fsl_clock.h "$SCRIPT_DIR/sdk/drivers/"
cp devices/MCXA155/drivers/fsl_clock.c "$SCRIPT_DIR/sdk/drivers/"
cp devices/MCXA155/drivers/fsl_reset.h "$SCRIPT_DIR/sdk/drivers/"
cp devices/MCXA155/drivers/fsl_reset.c "$SCRIPT_DIR/sdk/drivers/"
cp drivers/lpuart/fsl_lpuart.h "$SCRIPT_DIR/sdk/drivers/"
cp drivers/lpuart/fsl_lpuart.c "$SCRIPT_DIR/sdk/drivers/"

cd "$SCRIPT_DIR"
rm -rf "$SDK_TMP"
echo "  NXP SDK files downloaded (commit: ${SDK_COMMIT:0:8})"

# Create SDK README
cat > sdk/README.md << SDKEOF
# SDK Files

Vendored SDK files for MCXA155 minimal toolchain.

## Sources

### ARM CMSIS Core (cmsis/)
- Repository: https://github.com/ARM-software/CMSIS_6
- Commit: $CMSIS_COMMIT
- Date: $CMSIS_DATE
- License: Apache-2.0

### NXP MCUXpresso SDK (device/, drivers/)
- Repository: https://github.com/nxp-mcuxpresso/mcux-sdk
- Commit: $SDK_COMMIT
- Date: $SDK_DATE
- License: BSD-3-Clause

## Updating

Re-run bootstrap.sh to fetch latest SDK files.
SDKEOF

echo "SDK files vendored"
echo ""

# Create .gitignore
echo "Creating .gitignore..."
cat > .gitignore << 'EOF'
build/
*.o
*.elf
*.bin
*.hex
*.map
.vscode/
.idea/
*.swp
*~
.DS_Store
EOF
echo ".gitignore created"

# Create Dockerfile
echo "Creating Dockerfile..."
cat > Dockerfile << 'EOF'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    tar \
    xz-utils \
    make \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Install ARM GCC toolchain
RUN cd /tmp && \
    wget --progress=dot:giga https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    tar xf arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    mv arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi /opt/gcc-arm && \
    rm arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz

ENV PATH="/opt/gcc-arm/bin:${PATH}"

# SDK files are vendored in sdk/ directory (mounted via docker-compose)
# No git clone needed - faster builds, offline capable

CMD ["make", "help"]
EOF
echo "Dockerfile created"

# Create docker-compose.yml
echo "Creating docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  build:
    build: .
    volumes:
      - .:/workspace
    working_dir: /workspace
    command: make clean all
  shell:
    build: .
    volumes:
      - .:/workspace
    working_dir: /workspace
    stdin_open: true
    tty: true
    command: /bin/bash
EOF
echo "docker-compose.yml created"

# Create Makefile
echo "Creating Makefile..."
cat > Makefile << 'EOF'
TARGET = firmware
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
AS = $(PREFIX)as
LD = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy
SIZE = $(PREFIX)size

SDK_CMSIS = sdk/cmsis
SDK_DEVICE = sdk/device
SDK_DRIVERS = sdk/drivers
BUILD_DIR = build

C_SOURCES = \
    src/main.c \
    $(SDK_DEVICE)/system_MCXA155.c \
    $(SDK_DRIVERS)/fsl_common.c \
    $(SDK_DRIVERS)/fsl_common_arm.c \
    $(SDK_DRIVERS)/fsl_clock.c \
    $(SDK_DRIVERS)/fsl_reset.c \
    $(SDK_DRIVERS)/fsl_lpuart.c

ASM_SOURCES = $(SDK_DEVICE)/startup_MCXA155.S

INCLUDES = -I$(SDK_CMSIS) -I$(SDK_DEVICE) -I$(SDK_DRIVERS) -Isrc

CPU = -mcpu=cortex-m33
FPU = -mfpu=fpv5-sp-d16
FLOAT_ABI = -mfloat-abi=hard

CFLAGS = $(CPU) $(FPU) $(FLOAT_ABI) -mthumb -Wall -Wextra -g3 -O2 -ffunction-sections -fdata-sections $(INCLUDES) -DCPU_MCXA155VLH
ASFLAGS = $(CPU) $(FPU) $(FLOAT_ABI) -mthumb -g3 $(INCLUDES)
LDFLAGS = $(CPU) $(FPU) $(FLOAT_ABI) -mthumb -T$(SDK_DEVICE)/MCXA155_flash.ld -Wl,--gc-sections -Wl,--print-memory-usage --specs=nano.specs --specs=nosys.specs -Wl,-Map=$(BUILD_DIR)/$(TARGET).map

C_OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(C_SOURCES:.c=.o)))
ASM_OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(ASM_SOURCES:.S=.o)))
OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)

vpath %.c $(SDK_DEVICE) $(SDK_DRIVERS) src
vpath %.S $(SDK_DEVICE)

.PHONY: all clean help size
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).bin
	@echo "Build complete: $(BUILD_DIR)/$(TARGET).bin"

$(BUILD_DIR):
	@mkdir -p $@

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	@$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.S | $(BUILD_DIR)
	@$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS)
	@$(LD) $(LDFLAGS) $(OBJECTS) -o $@
	@$(SIZE) $@

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	@$(OBJCOPY) -O binary $< $@

size: $(BUILD_DIR)/$(TARGET).elf
	@$(SIZE) --format=berkeley $<

clean:
	@rm -rf $(BUILD_DIR)

help:
	@echo "MCXA155 Build Commands"
	@echo "  make           - Build firmware"
	@echo "  make clean     - Remove build artifacts"
	@echo "  make size      - Show binary size"
EOF
echo "Makefile created"

# Create src/main.c
echo "Creating src/main.c..."
cat > src/main.c << 'EOF'
#include <stdint.h>
#include <string.h>
#include "MCXA155.h"
#include "fsl_clock.h"
#include "fsl_lpuart.h"

#define LPUART_BAUDRATE 115200

void LPUART0_Init(void) {
    lpuart_config_t config;
    CLOCK_EnableClock(kCLOCK_Lpuart0);
    LPUART_GetDefaultConfig(&config);
    config.baudRate_Bps = LPUART_BAUDRATE;
    config.enableTx = true;
    LPUART_Init(LPUART0, &config, CLOCK_GetFreq(kCLOCK_Lpuart0));
}

int main(void) {
    SystemInit();
    LPUART0_Init();

    const char *msg = "\r\nHello from MCXA155!\r\n";
    LPUART_WriteBlocking(LPUART0, (uint8_t *)msg, strlen(msg));

    while (1) {
        for (volatile uint32_t i = 0; i < 20000000; i++);
    }
}

int _write(int fd, char *ptr, int len) {
    (void)fd;
    LPUART_WriteBlocking(LPUART0, (uint8_t *)ptr, len);
    return len;
}
EOF
echo "src/main.c created"

# Create README.md
echo "Creating README.md..."
cat > README.md << 'EOF'
# MCXA155 Minimal Firmware

Containerized ARM GCC toolchain for MCXA155 MCU. Builds hello world firmware.

## Build

```bash
docker-compose run build
```

Result: `build/firmware.bin`

## Flash

```bash
pip3 install spsdk

blhost -p /dev/ttyUSB0 -- flash-erase-all
blhost -p /dev/ttyUSB0 -- write-memory 0x0 build/firmware.bin
blhost -p /dev/ttyUSB0 -- reset

screen /dev/ttyUSB0 115200
```

## What's in the Container

- Ubuntu 22.04
- ARM GCC 13.2 (downloads from ARM's CDN)
- NXP MCXA155 SDK (vendored in sdk/ - no download during build)

No local installation needed. Everything happens in Docker.

## Project Structure

```
.
├── src/              # Source code
│   └── main.c
├── sdk/              # Vendored SDK files (CMSIS + NXP drivers)
├── build/            # Compiled output (gitignored)
├── scripts/          # Utility scripts
├── docs/             # Documentation
├── Dockerfile        # Container definition
├── docker-compose.yml
├── Makefile
├── .gitignore
└── README.md
```

## Interactive Shell

```bash
docker-compose run shell
$ arm-none-eabi-objdump -d build/firmware.elf
$ make clean && make -j4
```
EOF
echo "README.md created"

# Create scripts/flash.sh
echo "Creating scripts/flash.sh..."
cat > scripts/flash.sh << 'EOF'
#!/bin/bash
# Flash firmware to MCXA155 via serial bootloader

if [ $# -lt 1 ]; then
    echo "Usage: $0 <device> [firmware.bin]"
    echo "Example: $0 /dev/ttyUSB0"
    exit 1
fi

DEVICE=$1
FIRMWARE=${2:-../build/firmware.bin}

if [ ! -f "$FIRMWARE" ]; then
    echo "ERROR: Firmware not found: $FIRMWARE"
    exit 1
fi

echo "Flashing to $DEVICE..."
blhost -p "$DEVICE" -- flash-erase-all
blhost -p "$DEVICE" -- write-memory 0x0 "$FIRMWARE"
blhost -p "$DEVICE" -- reset
echo "Done"
EOF
chmod +x scripts/flash.sh
echo "scripts/flash.sh created"

# Create docs/README.md
echo "Creating docs/README.md..."
cat > docs/README.md << 'EOF'
# Documentation

## Setup

1. Install Docker: https://www.docker.com/products/docker-desktop
2. Run: `docker-compose run build`
3. Flash: `blhost -p /dev/ttyUSB0 -- write-memory 0x0 build/firmware.bin`

## Project Layout

- `src/` - Your source code (main.c, modules, etc.)
- `sdk/` - Vendored SDK files (see sdk/README.md for sources)
- `scripts/` - Utility scripts (flashing, debugging, etc.)
- `build/` - Compiled output (do not commit)
- `Dockerfile` - Build environment definition
- `Makefile` - Build rules and compiler flags

## Adding Modules

1. Create new `.c` and `.h` files in `src/`
2. Update `Makefile` `C_SOURCES` to include them
3. Run `make clean all`

## Adding SDK Drivers

1. Copy driver files from NXP mcux-sdk repo to `sdk/drivers/`
2. Add source files to `Makefile` `C_SOURCES`
3. Update `sdk/README.md` with source info

## Customizing Compiler Flags

Edit `Makefile` section `CFLAGS` to add:
- Optimization: `-O0` (debug), `-O2` (balanced), `-O3` (fast)
- Warnings: `-Wall`, `-Wextra`, `-Werror`
- Features: `-fno-strict-aliasing`, etc.

## Resources

- NXP MCXA155 Reference Manual
- ARM Cortex-M33 Technical Reference
- GNU ARM Embedded Toolchain
EOF
echo "docs/README.md created"

echo ""
echo "=========================================="
echo "Project structure created successfully!"
echo "=========================================="
echo ""
echo "Directory structure:"
echo ""
tree -L 2 2>/dev/null || find . -not -path '*/\.*' -type f | sort | sed 's|^\./||'
echo ""
echo "Next steps:"
echo ""
echo "  1. Build firmware:"
echo "     docker-compose run build"
echo ""
echo "  2. Flash to hardware:"
echo "     pip3 install spsdk"
echo "     blhost -p /dev/ttyUSB0 -- flash-erase-all"
echo "     blhost -p /dev/ttyUSB0 -- write-memory 0x0 build/firmware.bin"
echo ""
echo "  3. Initialize git (optional):"
echo "     git init"
echo "     git add ."
echo "     git commit -m 'Initial MCXA155 project'"
echo ""
