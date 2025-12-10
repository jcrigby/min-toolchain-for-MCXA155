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
SDK_UTILITIES = sdk/utilities
SDK_COMPONENTS = sdk/components
BUILD_DIR = build

C_SOURCES = \
    src/main.c \
    src/board/board.c \
    src/board/clock_config.c \
    src/board/pin_mux.c \
    $(SDK_DEVICE)/system_MCXA155.c \
    $(SDK_DRIVERS)/fsl_common.c \
    $(SDK_DRIVERS)/fsl_common_arm.c \
    $(SDK_DRIVERS)/fsl_clock.c \
    $(SDK_DRIVERS)/fsl_reset.c \
    $(SDK_DRIVERS)/fsl_lpuart.c \
    $(SDK_DRIVERS)/fsl_gpio.c \
    $(SDK_DRIVERS)/fsl_spc.c \
    $(SDK_UTILITIES)/fsl_debug_console.c \
    $(SDK_UTILITIES)/fsl_str.c \
    $(SDK_UTILITIES)/fsl_assert.c \
    $(SDK_COMPONENTS)/fsl_adapter_lpuart.c \
    $(SDK_COMPONENTS)/fsl_component_generic_list.c

ASM_SOURCES = $(SDK_DEVICE)/startup_MCXA155.S

INCLUDES = \
    -I$(SDK_CMSIS) \
    -I$(SDK_DEVICE) \
    -I$(SDK_DRIVERS) \
    -I$(SDK_UTILITIES) \
    -I$(SDK_COMPONENTS) \
    -Isrc \
    -Isrc/board

CPU = -mcpu=cortex-m33
FPU = -mfpu=fpv5-sp-d16
FLOAT_ABI = -mfloat-abi=hard

# SDK_DEBUGCONSOLE=1 enables debug console lite
# SERIAL_PORT_TYPE_UART=1 configures UART as serial port backend
DEFINES = -DCPU_MCXA155VLH -DSDK_DEBUGCONSOLE=1 -DSERIAL_PORT_TYPE_UART=1

CFLAGS = $(CPU) $(FPU) $(FLOAT_ABI) -mthumb -Wall -Wextra -g3 -O2 -ffunction-sections -fdata-sections $(INCLUDES) $(DEFINES)
ASFLAGS = $(CPU) $(FPU) $(FLOAT_ABI) -mthumb -g3 $(INCLUDES)
LDFLAGS = $(CPU) $(FPU) $(FLOAT_ABI) -mthumb -T$(SDK_DEVICE)/MCXA155_flash.ld -Wl,--gc-sections -Wl,--print-memory-usage --specs=nano.specs --specs=nosys.specs -Wl,-Map=$(BUILD_DIR)/$(TARGET).map

C_OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(C_SOURCES:.c=.o)))
ASM_OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(ASM_SOURCES:.S=.o)))
OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)

vpath %.c $(SDK_DEVICE) $(SDK_DRIVERS) $(SDK_UTILITIES) $(SDK_COMPONENTS) src src/board
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
