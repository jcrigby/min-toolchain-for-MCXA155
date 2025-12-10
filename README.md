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
- NXP MCXA155 SDK (downloads from NXP GitHub)

No local installation needed. Everything happens in Docker.

## Project Structure

```
.
├── src/              # Source code
│   └── main.c
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
