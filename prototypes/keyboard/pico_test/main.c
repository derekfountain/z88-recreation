/* 
 * The MIT License (MIT)
 *
 * Copyright (c) 2024 Derek Fountain
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

/* Test program, prints out the matrix of connections from the Z88 keyboard. */

/*
 * cmake -DCMAKE_BUILD_TYPE=Debug ..
 * make -j10
 *
 * With the RPi Debug Probe:
 * 
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" \
 *              -c "program pico_usb_keyboard.elf verify reset exit"
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000"
 *
 * gdb-multiarch pico_usb_keyboard.elf
 *  target remote localhost:3333
 *  load
 *  monitor reset init
 *  continue
 *
 * With the home made Pico probe:
 *
 * sudo openocd -f interface/picoprobe.cfg -f target/rp2040.cfg \
 *              -c "program ./program pico_usb_keyboard.elf verify reset exit"
 *
 * 
 *
 */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "pico/stdlib.h"

/*
 * SK6 is the left side connector as you look at the front of the machine.
 * It's on the shorter membrane tail. It carries the address bus inputs.
 * SK7 has the longer tail and is the switch outputs.
 *
 * For both connectors I've decided the left side is 1, the right side is 8.
 */
const uint32_t SK6_1_GPIO = 1;  // A15
const uint32_t SK6_2_GPIO = 0;  // A14
const uint32_t SK6_3_GPIO = 2;  // A13
const uint32_t SK6_4_GPIO = 3;  // A12
const uint32_t SK6_5_GPIO = 4;  // A11
const uint32_t SK6_6_GPIO = 5;  // A10
const uint32_t SK6_7_GPIO = 6;  // A9
const uint32_t SK6_8_GPIO = 7;  // A8

const uint32_t SK7_1_GPIO = 13; // D7
const uint32_t SK7_2_GPIO = 11; // D6
const uint32_t SK7_3_GPIO = 15; // D5
const uint32_t SK7_4_GPIO = 10; // D4
const uint32_t SK7_5_GPIO =  9; // D3
const uint32_t SK7_6_GPIO =  8; // D2
const uint32_t SK7_7_GPIO = 14; // D1
const uint32_t SK7_8_GPIO = 12; // D0

int main(void)
{
  stdio_init_all(); sleep_ms(50);

  uint32_t sk6_connector[8] = { SK6_1_GPIO,
				SK6_2_GPIO,
				SK6_3_GPIO,
				SK6_4_GPIO,
				SK6_5_GPIO,
				SK6_6_GPIO,
				SK6_7_GPIO,
				SK6_8_GPIO };

  uint32_t sk7_connector[8] = { SK7_1_GPIO,
				SK7_2_GPIO,
				SK7_3_GPIO,
				SK7_4_GPIO,
				SK7_5_GPIO,
				SK7_6_GPIO,
				SK7_7_GPIO,
				SK7_8_GPIO };

  for( uint32_t sk6_index = 0; sk6_index < 8; sk6_index++ )
  {
    gpio_init( sk6_connector[sk6_index] );
    gpio_set_dir( sk6_connector[sk6_index], GPIO_OUT );
			     
    gpio_put( sk6_connector[sk6_index], 1 );
  }

  for( uint32_t sk7_index = 0; sk7_index < 8; sk7_index++ )
  {
    gpio_init( sk7_connector[sk7_index] );
    gpio_set_dir( sk7_connector[sk7_index], GPIO_IN );
			     
    gpio_pull_up( sk7_connector[sk7_index] );
  }

  while (1)
  {
    for( uint32_t sk6_index = 0; sk6_index < 8; sk6_index++ )
    {
      gpio_put( sk6_connector[sk6_index], 0 );
      sleep_ms( 5 );
  
      uint32_t gpios_state = gpio_get_all();
      uint32_t sk7_state   = (gpios_state >> 8) & 0xFF;

      uint32_t d7 = ((gpios_state & (1 << SK7_8_GPIO)) != 0);
      uint32_t d6 = ((gpios_state & (1 << SK7_7_GPIO)) != 0);
      uint32_t d5 = ((gpios_state & (1 << SK7_6_GPIO)) != 0);
      uint32_t d4 = ((gpios_state & (1 << SK7_5_GPIO)) != 0);
      uint32_t d3 = ((gpios_state & (1 << SK7_4_GPIO)) != 0);
      uint32_t d2 = ((gpios_state & (1 << SK7_3_GPIO)) != 0);
      uint32_t d1 = ((gpios_state & (1 << SK7_2_GPIO)) != 0);
      uint32_t d0 = ((gpios_state & (1 << SK7_1_GPIO)) != 0);

      /*
       * Look at this diagram:
       * https://cambridgez88.jira.com/wiki/spaces/ZSM/pages/68780199/Figure+1.3+-+Keyboard+Matrix+Interconnections
       * and mentally rotate the output of this loop clockwise through 90deg
       */

      printf("GPIOs state = %c%c%c%c%c%c%c%c\n", d0+'0', d1+'0', d2+'0', d3+'0', d4+'0', d5+'0', d6+'0', d7+'0' );

      gpio_put( sk6_connector[sk6_index], 1 );
      sleep_ms( 5 );

      sleep_ms( 100 );
    }
    printf("\n");
  }
}
