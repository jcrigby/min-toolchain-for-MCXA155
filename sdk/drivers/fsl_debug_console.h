/*
 * Copyright 2024 NXP
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Minimal stub for debug console - the actual utility has many dependencies.
 * This stub allows board.c to compile without the full debug console component.
 */

#ifndef FSL_DEBUG_CONSOLE_H
#define FSL_DEBUG_CONSOLE_H

#include "fsl_common.h"

/*******************************************************************************
 * Definitions
 ******************************************************************************/

/* Serial port types - matches NXP serial_port_type_t */
typedef enum {
    kSerialPort_None = 0,
    kSerialPort_Uart = 1,
    kSerialPort_UsbCdc = 2,
    kSerialPort_Swo = 3,
    kSerialPort_Virtual = 4,
} serial_port_type_t;

/* Debug console type - we only support LPUART */
#define DEBUG_CONSOLE_DEVICE_TYPE_LPUART kSerialPort_Uart

/*******************************************************************************
 * API
 ******************************************************************************/

/*!
 * @brief Stub for debug console initialization.
 *
 * This is a no-op stub. The actual LPUART initialization is done
 * directly in main.c using the LPUART driver.
 */
static inline status_t DbgConsole_Init(uint8_t instance, uint32_t baudrate,
                                        uint8_t device, uint32_t clkSrcFreq)
{
    (void)instance;
    (void)baudrate;
    (void)device;
    (void)clkSrcFreq;
    return kStatus_Success;
}

#endif /* FSL_DEBUG_CONSOLE_H */
