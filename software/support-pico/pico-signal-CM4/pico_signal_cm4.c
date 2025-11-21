/*
 * Pico signal CM4 Example, a Raspberry Pi Pico test
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
 *              -c "program pico_signal_cm4.elf verify reset exit"
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000"
 *
 * gdb-multiarch pico_signal_cm4.elf
 *  target remote localhost:3333
 *  load
 *  monitor reset init
 *  continue
 *
 * With the home made Pico probe:
 *
 * sudo openocd -f interface/picoprobe.cfg -f target/rp2040.cfg \
 *              -c "program ./pico_signal_cm4.elf verify reset exit"
 *
 * On the z88r:
 *
 * scp pico_signal_cm4.elf z88r:tmp
 *
 * sudo pinctrl set 23 op
 * sudo pinctrl set 24 op
 * sudo pinctrl set 23 dl; sudo pinctrl set 24 dl
 * sudo openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg -c "program ./pico_signal_cm4.elf verify reset exit"
 *
 * sudo minicom -D /dev/ttyAMA0 -b 115200

 * The test program on the CM4 end looks like this:

#!/usr/bin/env python3

import RPi.GPIO as GPIO

BUTTON_GPIO = 15

if __name__ == '__main__':
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(BUTTON_GPIO, GPIO.IN, pull_up_down=GPIO.PUD_UP)

    while True:
        GPIO.wait_for_edge(BUTTON_GPIO, GPIO.FALLING)
        print("Button pressed!")


 */

#include <stdio.h>
#include "pico.h"
#include "pico/stdlib.h"
#include "pico/binary_info.h"

const uint LED_PIN  = PICO_DEFAULT_LED_PIN;
const uint TEST_PIN = 0;

int main()
{
  bi_decl(bi_program_description("Pico UART control example binary."));

  gpio_init( LED_PIN );
  gpio_set_dir( LED_PIN, GPIO_OUT );
  gpio_put(LED_PIN, 0);

  gpio_init( TEST_PIN );
  gpio_set_dir( TEST_PIN, GPIO_OUT );
  gpio_put(TEST_PIN, 1);

  while(1)
  {
    gpio_put(LED_PIN, 1);

    gpio_put(TEST_PIN, 0);
    sleep_ms(100);
    gpio_put(TEST_PIN, 1);

    gpio_put(LED_PIN, 0);

    sleep_ms(5000);
  }
}
