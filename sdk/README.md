# SDK Files

Vendored SDK files for MCXA155 minimal toolchain. These files are extracted from
upstream repositories to enable offline, reproducible builds without requiring
large downloads during Docker build.

## Sources

### ARM CMSIS Core (cmsis/)

- **Repository:** https://github.com/ARM-software/CMSIS_6
- **Commit:** `20143a27aecaae3c46280a6f5ecc12c983292b2f`
- **Date:** 2025-12-05
- **License:** Apache-2.0
- **Files:**
  - `core_cm33.h` - Cortex-M33 core peripheral access
  - `cmsis_version.h` - CMSIS version definitions
  - `cmsis_compiler.h` - Compiler abstraction layer
  - `cmsis_gcc.h` - GCC-specific intrinsics
  - `m-profile/` - M-profile specific headers (cmsis_gcc_m.h, etc.)

### NXP MCUXpresso SDK (device/, drivers/, utilities/, components/)

- **Repository:** https://github.com/nxp-mcuxpresso/mcux-sdk
- **Commit:** `8a289764d763ad06e0c3a05c885644ed98b970af`
- **Date:** 2025-10-31
- **License:** BSD-3-Clause

#### Device Files (device/)
  - `MCXA155.h` - Device register definitions
  - `MCXA155_features.h` - Device feature flags
  - `system_MCXA155.h/c` - System initialization
  - `fsl_device_registers.h` - Register include wrapper
  - `startup_MCXA155.S` - GCC startup code
  - `MCXA155_flash.ld` - Linker script (flash config)

#### Driver Files (drivers/)
  - `fsl_common.h/c` - Common driver utilities
  - `fsl_common_arm.h/c` - ARM-specific utilities
  - `fsl_clock.h/c` - Clock configuration (MCXA155-specific)
  - `fsl_reset.h/c` - Reset control (MCXA155-specific)
  - `fsl_lpuart.h/c` - Low-power UART driver
  - `fsl_gpio.h/c` - GPIO driver
  - `fsl_port.h` - Port pin muxing (header only)
  - `fsl_spc.h/c` - System Power Controller driver

#### Utility Files (utilities/)
  - `fsl_debug_console.h/c` - Debug console lite (PRINTF support)
  - `fsl_str.h/c` - String formatting utilities
  - `fsl_assert.c` - Assert implementation

#### Component Files (components/)
  - `fsl_adapter_lpuart.c` - LPUART adapter for debug console
  - `fsl_adapter_uart.h` - UART adapter interface
  - `fsl_component_generic_list.h/c` - Generic linked list utility

## Directory Structure

```
sdk/
├── cmsis/           # ARM CMSIS Core headers
│   └── m-profile/   # M-profile specific headers
├── device/          # MCXA155 device files
├── drivers/         # Peripheral drivers
├── utilities/       # Debug console, string formatting
└── components/      # UART adapter, lists
```

## Updating

To update these files from upstream:

```bash
# Clone repos
git clone --depth 1 https://github.com/ARM-software/CMSIS_6.git /tmp/cmsis
git clone --depth 1 https://github.com/nxp-mcuxpresso/mcux-sdk.git /tmp/mcux-sdk

# Copy CMSIS
cp /tmp/cmsis/CMSIS/Core/Include/{core_cm33.h,cmsis_version.h,cmsis_compiler.h,cmsis_gcc.h} sdk/cmsis/
cp -r /tmp/cmsis/CMSIS/Core/Include/m-profile sdk/cmsis/

# Copy device files
cp /tmp/mcux-sdk/devices/MCXA155/{MCXA155.h,MCXA155_features.h,system_MCXA155.h,system_MCXA155.c,fsl_device_registers.h} sdk/device/
cp /tmp/mcux-sdk/devices/MCXA155/gcc/{startup_MCXA155.S,MCXA155_flash.ld} sdk/device/

# Copy drivers
cp /tmp/mcux-sdk/drivers/common/{fsl_common.h,fsl_common.c,fsl_common_arm.h,fsl_common_arm.c} sdk/drivers/
cp /tmp/mcux-sdk/devices/MCXA155/drivers/{fsl_clock.h,fsl_clock.c,fsl_reset.h,fsl_reset.c} sdk/drivers/
cp /tmp/mcux-sdk/drivers/lpuart/{fsl_lpuart.h,fsl_lpuart.c} sdk/drivers/
cp /tmp/mcux-sdk/drivers/gpio/{fsl_gpio.h,fsl_gpio.c} sdk/drivers/
cp /tmp/mcux-sdk/drivers/port/fsl_port.h sdk/drivers/
cp /tmp/mcux-sdk/drivers/spc/{fsl_spc.h,fsl_spc.c} sdk/drivers/

# Copy utilities
cp /tmp/mcux-sdk/utilities/debug_console_lite/{fsl_debug_console.h,fsl_debug_console.c} sdk/utilities/
cp /tmp/mcux-sdk/utilities/str/{fsl_str.h,fsl_str.c} sdk/utilities/
cp /tmp/mcux-sdk/utilities/assert/fsl_assert.c sdk/utilities/

# Copy components
cp /tmp/mcux-sdk/components/uart/{fsl_adapter_lpuart.c,fsl_adapter_uart.h} sdk/components/
cp /tmp/mcux-sdk/components/lists/{fsl_component_generic_list.h,fsl_component_generic_list.c} sdk/components/

# Update this README with new commit hashes and dates
```

## Notes

- NXP's mcux-sdk repo is being deprecated in favor of mcuxsdk-manifests
- These vendored files provide stability against upstream changes
- Total size: ~3MB (vs ~500MB full SDK clone)
- Example code from: https://github.com/nxp-mcuxpresso/mcux-sdk-examples (frdmmcxa156/driver_examples/lpuart/polling)
