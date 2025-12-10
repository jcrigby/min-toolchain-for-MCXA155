# Development Guide

A minimal toolchain for NXP MCXA155 microcontroller development using Docker.

## Quick Start

```bash
# Build the default example (LPUART polling)
docker compose run build

# Build the GPIO LED example
docker compose run build make EXAMPLE=gpio_led

# List available examples
docker compose run build make list-examples

# Output is in build/firmware.bin
```

## What This Is

This project provides a self-contained build environment for MCXA155 firmware without needing the full NXP MCUXpresso SDK (~500MB). Instead, only the required SDK files are vendored locally (~3MB).

### Available Examples

| Example | Description |
|---------|-------------|
| `lpuart_polling` | UART echo at 115200 baud (default) |
| `gpio_led` | Blinks red LED on GPIO3 pin 12 |

Build with: `make EXAMPLE=<name>`

### Hardware Target

- **MCU**: NXP MCXA155 (Cortex-M33, 96MHz, 128KB Flash, 32KB RAM)
- **Board**: FRDM-MCXA156 evaluation board (compatible with MCXA155)

## Project Structure

```
├── src/
│   ├── examples/           # Example applications
│   │   ├── lpuart_polling.c  # UART echo example
│   │   └── gpio_led.c        # LED blink example
│   └── board/              # Board configuration
│       ├── board.c/h       # Board init, debug console
│       ├── clock_config.c/h # Clock tree setup
│       └── pin_mux.c/h     # Pin assignments
├── sdk/
│   ├── cmsis/              # ARM CMSIS Core headers
│   ├── device/             # MCXA155 device files
│   ├── drivers/            # NXP peripheral drivers
│   ├── utilities/          # Debug console, printf support
│   └── components/         # UART adapter layer
├── Dockerfile              # Build environment
├── Makefile                # Build rules
└── docker-compose.yml      # Docker configuration
```

## Adding New Peripherals

To use additional peripherals (SPI, I2C, Timers, etc.):

### 1. Get the driver from NXP SDK

```bash
# Clone with sparse checkout
git clone --depth 1 --filter=blob:none --sparse \
    https://github.com/nxp-mcuxpresso/mcux-sdk.git /tmp/mcux-sdk
cd /tmp/mcux-sdk
git sparse-checkout set drivers/lpspi  # example: SPI

# Copy to project
cp drivers/lpspi/fsl_lpspi.{c,h} /path/to/project/sdk/drivers/
```

### 2. Update Makefile

Add the source file to `C_SOURCES`:
```makefile
C_SOURCES = \
    ...
    $(SDK_DRIVERS)/fsl_lpspi.c \
```

### 3. Configure pins

Update `src/board/pin_mux.c` to configure the peripheral's pins.

## SDK Sources

Files are extracted from:

| Component | Repository | Path |
|-----------|------------|------|
| CMSIS Core | ARM-software/CMSIS_6 | CMSIS/Core/Include/ |
| Device files | nxp-mcuxpresso/mcux-sdk | devices/MCXA155/ |
| Drivers | nxp-mcuxpresso/mcux-sdk | drivers/*/ |
| Board examples | nxp-mcuxpresso/mcux-sdk-examples | frdmmcxa156/ |

See `sdk/README.md` for specific commit hashes and update instructions.

## Flashing

To program the FRDM-MCXA156 board:

### Option 1: Mass Storage Bootloader
1. Hold the ISP button while connecting USB
2. Board appears as a mass storage device
3. Copy `build/firmware.bin` to the device

### Option 2: blhost (NXP ISP tool)
```bash
blhost -u -- flash-image build/firmware.bin erase
```

### Option 3: Debug Probe
Use a J-Link or CMSIS-DAP probe with your preferred debugger.

## Troubleshooting

### Build fails with missing header
Check if you need to add a driver. See "Adding New Peripherals" above.

### SPC register errors
Make sure you're using `drivers/mcx_spc/` not `drivers/spc/` - the MCX family has a different SPC peripheral.

### Clock/reset errors
MCXA155 uses different clock APIs than other NXP parts:
- Use `kCLOCK_GateLPUART0` not `kCLOCK_Lpuart0`
- Use `CLOCK_SetClockDiv()` and `CLOCK_AttachClk()` pattern

## Interactive Shell

For debugging or manual builds:
```bash
docker compose run shell
# Now inside container with ARM toolchain available
arm-none-eabi-gcc --version
make clean && make
```
