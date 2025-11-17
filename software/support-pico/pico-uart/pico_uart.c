/*
 * Pico UART Example, a Raspberry Pi Pico UART test
 * Copyright (C) 2025 Derek Fountain
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
 */

/*
 * cmake -DCMAKE_BUILD_TYPE=Debug ..
 * make -j10
 *
 * With the RPi Debug Probe:
 * 
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" \
 *              -c "program pico_uart.elf verify reset exit"
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000"
 *
 * gdb-multiarch pico_uart.elf
 *  target remote localhost:3333
 *  load
 *  monitor reset init
 *  continue
 *
 * With the home made Pico probe:
 *
 * sudo openocd -f interface/picoprobe.cfg -f target/rp2040.cfg \
 *              -c "program ./pico_uart.elf verify reset exit"
 *
 * On the z88r:
 *
 * scp pico_uart.elf z88r:tmp
 *
 * sudo pinctrl set 23 op
 * sudo pinctrl set 24 op
 * sudo pinctrl set 23 dl; sudo pinctrl set 24 dl
 * sudo openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg -c "program ./pico_uart.elf verify reset exit"
 *
 * sudo minicom -D /dev/ttyAMA0 -b 115200
 */

#include <stdio.h>
#include "pico.h"
#include "pico/stdlib.h"
#include "pico/binary_info.h"

const uint LED_PIN = PICO_DEFAULT_LED_PIN;

int main()
{
  bi_decl(bi_program_description("Pico UART control example binary."));

  gpio_init( LED_PIN );
  gpio_set_dir( LED_PIN, GPIO_OUT );
  gpio_put(LED_PIN, 1);

  // Set the GPIO pin mux to the UART - pin 0 is TX, 1 is RX;
  // note use of UART_FUNCSEL_NUM for the general
  // case where the func sel used for UART depends on the pin number

  // Do this before calling uart_init to avoid losing data
  gpio_set_function(0, UART_FUNCSEL_NUM(uart0, 0));
  gpio_set_function(1, UART_FUNCSEL_NUM(uart0, 1));

  // Initialise UART 0
  uart_init(uart0, 115200);
//  uart_set_hw_flow(uart0, false, false);

  while(1)
  {
    gpio_put(LED_PIN, 1);
    uart_puts(uart0, "Hello, world!\r\n");
    gpio_put(LED_PIN, 0);

    sleep_ms(250);
  }
}
