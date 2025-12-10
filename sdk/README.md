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

### NXP MCUXpresso SDK (device/, drivers/)

- **Repository:** https://github.com/nxp-mcuxpresso/mcux-sdk
- **Commit:** `8a289764d763ad06e0c3a05c885644ed98b970af`
- **Date:** 2025-10-31
- **License:** BSD-3-Clause
- **Device Files (device/):**
  - `MCXA155.h` - Device register definitions
  - `MCXA155_features.h` - Device feature flags
  - `system_MCXA155.h/c` - System initialization
  - `fsl_device_registers.h` - Register include wrapper
  - `startup_MCXA155.S` - GCC startup code
  - `MCXA155_flash.ld` - Linker script (flash config)
- **Driver Files (drivers/):**
  - `fsl_common.h/c` - Common driver utilities
  - `fsl_common_arm.h/c` - ARM-specific utilities
  - `fsl_clock.h/c` - Clock configuration (MCXA155-specific)
  - `fsl_reset.h/c` - Reset control (MCXA155-specific)
  - `fsl_lpuart.h/c` - Low-power UART driver

## Updating

To update these files from upstream:

```bash
# Clone repos
git clone --depth 1 https://github.com/ARM-software/CMSIS_6.git /tmp/cmsis
git clone --depth 1 https://github.com/nxp-mcuxpresso/mcux-sdk.git /tmp/mcux-sdk

# Copy CMSIS
cp /tmp/cmsis/CMSIS/Core/Include/{core_cm33.h,cmsis_version.h,cmsis_compiler.h,cmsis_gcc.h} sdk/cmsis/

# Copy device files
cp /tmp/mcux-sdk/devices/MCXA155/{MCXA155.h,MCXA155_features.h,system_MCXA155.h,system_MCXA155.c,fsl_device_registers.h} sdk/device/
cp /tmp/mcux-sdk/devices/MCXA155/gcc/{startup_MCXA155.S,MCXA155_flash.ld} sdk/device/

# Copy drivers
cp /tmp/mcux-sdk/drivers/common/{fsl_common.h,fsl_common.c,fsl_common_arm.h,fsl_common_arm.c} sdk/drivers/
cp /tmp/mcux-sdk/devices/MCXA155/drivers/{fsl_clock.h,fsl_clock.c,fsl_reset.h,fsl_reset.c} sdk/drivers/
cp /tmp/mcux-sdk/drivers/lpuart/{fsl_lpuart.h,fsl_lpuart.c} sdk/drivers/

# Update this README with new commit hashes and dates
```

## Adding More Drivers

To add additional peripheral drivers (e.g., SPI, I2C, GPIO):

1. Copy driver files from `mcux-sdk/drivers/<peripheral>/`
2. Add source files to `Makefile` C_SOURCES
3. Update this README

## Notes

- NXP's mcux-sdk repo is being deprecated in favor of mcuxsdk-manifests
- These vendored files provide stability against upstream changes
- Total size: ~2.3MB (vs ~500MB full SDK clone)
