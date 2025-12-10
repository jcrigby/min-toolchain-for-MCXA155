TARGET = firmware
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
AS = $(PREFIX)as
LD = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy
SIZE = $(PREFIX)size

SDK = /opt/sdk
BUILD_DIR = build

C_SOURCES = src/main.c $(SDK)/system_MCXA155.c $(SDK)/fsl_common.c $(SDK)/fsl_clock.c $(SDK)/fsl_lpuart.c
ASM_SOURCES = $(SDK)/startup_MCXA155.S

INCLUDES = -I$(SDK) -Isrc

CPU = -mcpu=cortex-m33
FPU = -mfpu=fpv5-sp-d16
FLOAT_ABI = -mfloat-abi=hard

CFLAGS = $(CPU) $(FPU) $(FLOAT_ABI) -mthumb -Wall -Wextra -g3 -O2 -ffunction-sections -fdata-sections $(INCLUDES) -DCPU_MCXA155VLH
ASFLAGS = $(CPU) $(FPU) $(FLOAT_ABI) -mthumb -g3
LDFLAGS = $(CPU) $(FPU) $(FLOAT_ABI) -mthumb -T$(SDK)/MCXA155_flash.ld -Wl,--gc-sections -Wl,--print-memory-usage --specs=nano.specs --specs=nosys.specs -Wl,-Map=$(BUILD_DIR)/$(TARGET).map

C_OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(C_SOURCES:.c=.o)))
ASM_OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(ASM_SOURCES:.S=.o)))
OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)

vpath %.c $(SDK) src
vpath %.S $(SDK)

.PHONY: all clean help size
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).bin
	@echo "✓ Build complete: $(BUILD_DIR)/$(TARGET).bin"

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
