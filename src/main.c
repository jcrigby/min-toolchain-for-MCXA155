#include <stdint.h>
#include <string.h>
#include "MCXA155.h"
#include "fsl_clock.h"
#include "fsl_lpuart.h"

#define LPUART_BAUDRATE 115200

void LPUART0_Init(void) {
    lpuart_config_t config;
    CLOCK_EnableClock(kCLOCK_Lpuart0);
    LPUART_GetDefaultConfig(&config);
    config.baudRate_Bps = LPUART_BAUDRATE;
    config.enableTx = true;
    LPUART_Init(LPUART0, &config, CLOCK_GetFreq(kCLOCK_Lpuart0));
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
    LPUART_WriteBlocking(LPUART0, (uint8_t *)ptr, len);
    return len;
}
