# Claude Code Context

This file provides context for Claude Code when working on this project.

## Project Overview

Minimal MCU toolchain for NXP MCXA155 (Cortex-M33) that builds in Docker without requiring the full 500MB+ NXP SDK. All necessary SDK files are vendored locally.

## How This Was Created

SDK files were extracted from these GitHub repositories using sparse checkout:

1. **ARM CMSIS Core** - https://github.com/ARM-software/CMSIS_6
   - Path: `CMSIS/Core/Include/`
   - Files: `core_cm33.h`, `cmsis_compiler.h`, `cmsis_gcc.h`, `cmsis_version.h`, `m-profile/*`

2. **NXP MCUXpresso SDK** - https://github.com/nxp-mcuxpresso/mcux-sdk
   - Device files: `devices/MCXA155/` (headers, system files, startup, linker script)
   - Device-specific drivers: `devices/MCXA155/drivers/` (fsl_clock, fsl_reset)
   - Common drivers: `drivers/common/`, `drivers/lpuart/`, `drivers/gpio/`, `drivers/port/`
   - **MCX-specific SPC**: `drivers/mcx_spc/` (NOT `drivers/spc/` - wrong variant)
   - Utilities: `utilities/debug_console_lite/`, `utilities/str/`, `utilities/assert/`
   - Components: `components/uart/`, `components/lists/`

3. **NXP SDK Examples** - https://github.com/nxp-mcuxpresso/mcux-sdk-examples
   - Board files from: `frdmmcxa156/driver_examples/lpuart/polling/`
   - Files: `board.c/h`, `clock_config.c/h`, `pin_mux.c/h`, main example code

## Current State

- **Builds successfully** in Docker with xPack ARM GCC 13.2.1
- **Not yet tested** on actual hardware

## Available Examples

Examples are in `src/examples/`. Select with `EXAMPLE=name`:

- **lpuart_polling** (default) - UART echo at 115200 baud
- **gpio_led** - Blinks red LED on GPIO3 pin 12

## SDK File Locations

```
sdk/
├── cmsis/           # ARM CMSIS Core headers
│   └── m-profile/   # M-profile intrinsics
├── device/          # MCXA155 device files
├── drivers/         # Peripheral drivers
├── utilities/       # Debug console, string formatting
└── components/      # UART adapter, lists
```

## Adding More SDK Drivers

To add a new peripheral driver (e.g., SPI, I2C, Timer):

1. **Find the driver** in mcux-sdk repo:
   ```bash
   git clone --depth 1 --filter=blob:none --sparse https://github.com/nxp-mcuxpresso/mcux-sdk.git /tmp/mcux-sdk
   cd /tmp/mcux-sdk
   git sparse-checkout set drivers/<peripheral>
   ```

2. **Check for device-specific versions** - some drivers have MCX-specific variants:
   - `drivers/mcx_spc/` instead of `drivers/spc/`
   - `devices/MCXA155/drivers/` for clock/reset

3. **Copy files**:
   ```bash
   cp /tmp/mcux-sdk/drivers/<peripheral>/fsl_<peripheral>.{c,h} sdk/drivers/
   ```

4. **Update Makefile** - add to `C_SOURCES`:
   ```makefile
   $(SDK_DRIVERS)/fsl_<peripheral>.c \
   ```

5. **Update sdk/README.md** with the new files

## Common Pitfalls

1. **Wrong SPC driver**: Use `drivers/mcx_spc/` not `drivers/spc/` - MCXA155 has different registers
2. **Clock API differences**: MCXA uses `kCLOCK_GateLPUART0` not `kCLOCK_Lpuart0`
3. **Missing m-profile headers**: CMSIS 6 needs `m-profile/` subdirectory
4. **Debug console dependencies**: Requires utilities (str, assert) and components (uart adapter, lists)

## Build Commands

```bash
docker compose run build                        # Build default example (lpuart_polling)
docker compose run build make EXAMPLE=gpio_led  # Build GPIO LED example
docker compose run build make clean             # Clean build artifacts
docker compose run shell                        # Interactive shell with toolchain
```

## Adding New Examples

1. **Find example** in mcux-sdk-examples repo:
   ```bash
   git clone --depth 1 --filter=blob:none --sparse https://github.com/nxp-mcuxpresso/mcux-sdk-examples.git /tmp/examples
   cd /tmp/examples
   git sparse-checkout set frdmmcxa156/driver_examples/<peripheral>
   ```

2. **Copy main source** to `src/examples/<name>.c`

3. **Update pin_mux.c** if needed (merge pin configs from example's pin_mux.c)

4. **Build with**: `make EXAMPLE=<name>`

## Key Defines

The Makefile sets these important defines:
- `CPU_MCXA155VLH` - Device variant
- `SDK_DEBUGCONSOLE=1` - Enable debug console lite
- `SERIAL_PORT_TYPE_UART=1` - Use UART for serial port backend
