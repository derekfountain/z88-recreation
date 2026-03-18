/*
 * Pico application board status example (SH1106 chipset)
 *
 * MIT License
 *
 * Copyright (c) 2021 David Schramm
 * Copyright (c) 2026 Derek Fountain
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * 
 */

/*
 * cmake -DCMAKE_BUILD_TYPE=Debug ..
 * make -j10
 *
 * With the RPi Debug Probe:
 * 
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" \
 *              -c "program app_board_sh1106_status.elf verify reset exit"
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000"
 *
 * gdb-multiarch app_board_sh1106_status.elf
 *  target remote localhost:3333
 *  load
 *  monitor reset init
 *  continue
 *
 * With the home made Pico probe:
 *
 * sudo openocd -f interface/picoprobe.cfg -f target/rp2040.cfg \
 *              -c "program ./app_board_sh1106_status.elf verify reset exit"
 *
 * On the z88r:
 *
 * scp app_board_sh1106_status.elf z88r:tmp
 *
 * sudo pinctrl set 23 op
 * sudo pinctrl set 24 op
 * sudo pinctrl set 23 dl; sudo pinctrl set 24 dh    (left side Pico)
 * sudo openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg -c "program ./app_board_sh1106_status.elf verify reset exit"
 *
 */

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "pico.h"
#include "pico/stdlib.h"
#include "pico/binary_info.h"
#include "hardware/i2c.h"
#include "hardware/uart.h"
#include "hardware/gpio.h"

#include "font.h"
#include "sh1106.h"

const uint LED_PIN              = PICO_DEFAULT_LED_PIN;

/*
 * SH1106 library uses these definitions. They are
 * defined in pico.h as 4 and 5. My hardware is
 * different.
 */
#undef PICO_DEFAULT_I2C_SDA_PIN
#define PICO_DEFAULT_I2C_SDA_PIN 20
#undef PICO_DEFAULT_I2C_SCL_PIN
#define PICO_DEFAULT_I2C_SCL_PIN 21

/* v1.0, Pico1 UART on the application board is wired up on UART0, pins 0 and 1 */
static       uart_inst_t *APPLICATION_BOARD_UART = uart0;
static const uint32_t     UART_TX_GPIO           = 0;
static const uint32_t     UART_RX_GPIO           = 1;
static const uint32_t     UART_BAUD_RATE         = 115200;
static const uint32_t     UART_IRQ               = UART0_IRQ;

// RX interrupt handler
void on_uart_rx()
{
  static uint8_t str[32];
  static uint32_t x = 0;

  while( uart_is_readable(APPLICATION_BOARD_UART) )
  {
    uint8_t ch = uart_getc(APPLICATION_BOARD_UART);
    if( ch == '\n' )
    {
      str[x] = 0;
      SH1106_GotoXY(1,20);
      SH1106_Puts(str, &Font_7x10, 1);
      str[0] = 0;
      x = 0;
    }
    else
    {
      str[x++] = ch;
    }
  }
    
  SH1106_UpdateScreen();
}

int main()
{  
  bi_decl(bi_program_description("Pico application board status binary."));

  gpio_init( LED_PIN );
  gpio_set_dir( LED_PIN, GPIO_OUT );
  gpio_put(LED_PIN, 1);

  /* Screen initialisation */
  i2c_init(i2c_default, 400 * 1000);
  gpio_set_function(PICO_DEFAULT_I2C_SDA_PIN, GPIO_FUNC_I2C);
  gpio_set_function(PICO_DEFAULT_I2C_SCL_PIN, GPIO_FUNC_I2C);
  gpio_pull_up(PICO_DEFAULT_I2C_SDA_PIN);
  gpio_pull_up(PICO_DEFAULT_I2C_SCL_PIN);
    
  sleep_ms( 500 );

  SH1106_Init();

  SH1106_GotoXY(1,1);
  SH1106_Puts("O", &Font_7x10, 1);

  SH1106_GotoXY(120,1);
  SH1106_Puts("O", &Font_7x10, 1);

  SH1106_GotoXY(1,53);
  SH1106_Puts("O", &Font_7x10, 1);

  SH1106_GotoXY(120,53);
  SH1106_Puts("O", &Font_7x10, 1);

  uint16_t x,y;
  for( x=0; x<128; x++ )
  {
    SH1106_DrawPixel( x,  0, 1);
    SH1106_DrawPixel( x, 63, 1);
  }
  for( y=0; y<64; y++ )
  {
    SH1106_DrawPixel( 0,   y, 1);
    SH1106_DrawPixel( 127, y, 1);
  }

  SH1106_UpdateScreen();

  /* Receiving end of UART link to main board */

  uint ret;
  if( (ret=uart_init( APPLICATION_BOARD_UART, UART_BAUD_RATE )) != UART_BAUD_RATE )
  {
    /*
     * I don't really care what speed the UART ends up running at, and the uart_init()
     * function rarely returns exactly 115200 anyway
     */
#if 0
    SH1106_GotoXY(10,10);
    uint8_t err[128]; sprintf(err, "%u", ret);
    SH1106_Puts(err, &Font_7x10, 1);
    SH1106_UpdateScreen();
#endif
  }

  gpio_set_function( UART_TX_GPIO, UART_FUNCSEL_NUM(APPLICATION_BOARD_UART, UART_TX_GPIO) );
  gpio_set_function( UART_RX_GPIO, UART_FUNCSEL_NUM(APPLICATION_BOARD_UART, UART_RX_GPIO) );

  /* No hardware flow is arranged on the board, the FIFO works well enough for speed control */
  uart_set_hw_flow( APPLICATION_BOARD_UART, false, false );
  uart_set_fifo_enabled( APPLICATION_BOARD_UART, true );

  /* Set up the handler for UART receive bytes */
  irq_set_exclusive_handler( UART_IRQ, on_uart_rx );
  irq_set_enabled( UART_IRQ, true );

  /* Now enable the UART to send interrupts - RX only */
  uart_set_irqs_enabled( APPLICATION_BOARD_UART, true, false );

  /* Infinite loop does nothing, let the interrupts handle everything */
  while(1)
  {
    gpio_put(LED_PIN, 1);
    sleep_ms(500);
    gpio_put(LED_PIN, 0);
    sleep_ms(500);
  }
}
