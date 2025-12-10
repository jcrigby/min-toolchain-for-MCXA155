# Documentation

## Setup

1. Install Docker: https://www.docker.com/products/docker-desktop
2. Run: `docker-compose run build`
3. Flash: `blhost -p /dev/ttyUSB0 -- write-memory 0x0 build/firmware.bin`

## Project Layout

- `src/` - Your source code (main.c, modules, etc.)
- `scripts/` - Utility scripts (flashing, debugging, etc.)
- `build/` - Compiled output (do not commit)
- `Dockerfile` - Build environment definition
- `Makefile` - Build rules and compiler flags

## Adding Modules

1. Create new `.c` and `.h` files in `src/`
2. Update `Makefile` `C_SOURCES` to include them
3. Run `make clean all`

## Customizing Compiler Flags

Edit `Makefile` section `CFLAGS` to add:
- Optimization: `-O0` (debug), `-O2` (balanced), `-O3` (fast)
- Warnings: `-Wall`, `-Wextra`, `-Werror`
- Features: `-fno-strict-aliasing`, etc.

## Resources

- NXP MCXA155 Reference Manual
- ARM Cortex-M33 Technical Reference
- GNU ARM Embedded Toolchain
