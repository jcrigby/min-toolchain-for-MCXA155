#include <stdint.h>
#include <string.h>
#include "MCXA155.h"
#include "fsl_clock.h"
#include "fsl_lpuart.h"

#define LPUART_BAUDRATE 115200

void LPUART0_Init(void) {
    lpuart_config_t config;

    /* Attach FRO 12MHz clock to LPUART0 */
    CLOCK_SetClockDiv(kCLOCK_DivLPUART0, 1U);
    CLOCK_AttachClk(kFRO12M_to_LPUART0);

    /* Enable LPUART0 clock gate */
    CLOCK_EnableClock(kCLOCK_GateLPUART0);

    LPUART_GetDefaultConfig(&config);
    config.baudRate_Bps = LPUART_BAUDRATE;
    config.enableTx = true;
    LPUART_Init(LPUART0, &config, CLOCK_GetLpuartClkFreq(0));
}

int main(void) {
    SystemInit();
    LPUART0_Init();
    
    const char *msg = "\r\nHello from MCXA155!\r\n";
    LPUART_WriteBlocking(LPUART0, (uint8_t *)msg, strlen(msg));
    
    while (1) {
        for (volatile uint32_t i = 0; i < 20000000; i++);
    }
}

int _write(int fd, char *ptr, int len) {
    (void)fd;
    LPUART_WriteBlocking(LPUART0, (uint8_t *)ptr, len);
    return len;
}
