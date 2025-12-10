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
echo "✓ Done"
