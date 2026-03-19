/*
 * Pico application board example (SH1106 chipset)
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
 *              -c "program app_board_sh1106_pico2.elf verify reset exit"
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000"
 *
 * gdb-multiarch app_board_sh1106_pico2.elf
 *  target remote localhost:3333
 *  load
 *  monitor reset init
 *  continue
 *
 * With the home made Pico probe:
 *
 * sudo openocd -f interface/picoprobe.cfg -f target/rp2040.cfg \
 *              -c "program ./app_board_sh1106_pico2.elf verify reset exit"
 *
 * On the z88r:
 *
 * scp app_board_sh1106_pico2.elf z88r:tmp
 *
 * sudo pinctrl set 23 op
 * sudo pinctrl set 24 op
 * sudo pinctrl set 23 dl; sudo pinctrl set 24 dh    (left side Pico)
 * sudo openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg -c "program ./app_board_sh1106_pico2.elf verify reset exit"
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

/*
 * v1.0, Pins 16 and 17 connect the 2 Picos' UARTs. Only, UART0 is
 * already used on Pico1, so this Pico to Pico connection can't
 * use UARTs, it has to be something else. Transputer?
 */
static const uint32_t     PICO2PICO_TX_GPIO           = 16;
static const uint32_t     PICO2PICO_RX_GPIO           = 17;

int main()
{  
  bi_decl(bi_program_description("Pico application board Pico2 binary."));

  gpio_init( LED_PIN );
  gpio_set_dir( LED_PIN, GPIO_OUT );
  gpio_put(LED_PIN, 1);

  /* Screen initialisation */
  i2c_init(i2c_default, 400 * 1000);
  gpio_set_function(PICO_DEFAULT_I2C_SDA_PIN, GPIO_FUNC_I2C);
  gpio_set_function(PICO_DEFAULT_I2C_SCL_PIN, GPIO_FUNC_I2C);
  gpio_pull_up(PICO_DEFAULT_I2C_SDA_PIN);
  gpio_pull_up(PICO_DEFAULT_I2C_SCL_PIN);
    
  sleep_ms( 200 );

  SH1106_Init();

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

  SH1106_GotoXY(2,2);
  SH1106_Puts("Z88:   <Running>", &Font_7x10, 1);
  SH1106_GotoXY(2,18);
  SH1106_Puts("SLOT1: 128K RAM", &Font_7x10, 1);
  SH1106_GotoXY(2,30);
  SH1106_Puts("SLOT2: eprom1.img", &Font_7x10, 1);
  SH1106_GotoXY(2,42);
  SH1106_Puts("SLOT3: <EMPTY>", &Font_7x10, 1);

  SH1106_UpdateScreen();

  /* Infinite loop does nothing */
  while(1)
  {
    gpio_put(LED_PIN, 1);
    sleep_ms(500);
    gpio_put(LED_PIN, 0);
    sleep_ms(500);
  }
}
