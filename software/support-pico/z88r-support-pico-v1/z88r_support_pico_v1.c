/*
 * Support Pico code for the Z88R, for V1 boards
 * Copyright (C) 2026 Derek Fountain
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
 * export PICO_SDK_PATH=/home/derek/BEETLE/Derek/dev/Pico/pico-sdk-v2.x
 * cmake -DCMAKE_BUILD_TYPE=Debug ..
 * make -j10
 *
 * With the RPi Debug Probe:
 * 
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" \
 *              -c "program z88r_support_pico_v1.elf verify reset exit"
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000"
 *
 * gdb-multiarch z88r_support_pico_v1.elf
 *  target remote localhost:3333
 *  load
 *  monitor reset init
 *  continue
 *
 * With the home made Pico probe:
 *
 * sudo openocd -f interface/picoprobe.cfg -f target/rp2040.cfg \
 *              -c "program ./z88r_support_pico_v1.elf verify reset exit"
 *
 * On the z88r:
 *
 * scp z88r_support_pico_v1.elf z88r:tmp
 *
 * sudo pinctrl set 23 op
 * sudo pinctrl set 24 op
 * sudo pinctrl set 23 dl; sudo pinctrl set 24 dl
 * sudo openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg -c "program ./z88r_support_pico_v1.elf verify reset exit"
 *
 * sudo minicom -D /dev/ttyAMA0 -b 115200
 */

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include "pico.h"
#include "pico/stdlib.h"
#include "pico/binary_info.h"

#include "app_board_link.h"

const uint32_t LED_PIN = PICO_DEFAULT_LED_PIN;

/*
 * Goals:
 *
 * listen to the UART connecting us to the CM4, waiting for instructions (async)
 * listen to dual shifts hardware (GPIOs?) which indicate stuff needs waking up (async, assuming GPIOs)
 * listen to the UART connecting us to the application board Pico1, waiting for instructions (async)
 * listen to the link (Transputer?) connecting us to the application board Pico2, waiting for instructions (PIOs, not sure if they're async)
 * listen to the I2C bus, waiting for signal from RTC (not sure)
 * 
 * be able to latch own power supply (and that of the keyboard pico)
 * be able to send data to CM4
 * be able to signal the CM4 to turn on/off
 * be able to signal the CM4 to go into standby/reboot
 * be able to turn on/off the application board
 * be able to send binary signal to application board
 */


int main()
{
  bi_decl(bi_program_description("Z88R Support Pico code, for V1 boards"));

  gpio_init( LED_PIN );
  gpio_set_dir( LED_PIN, GPIO_OUT );
  gpio_put(LED_PIN, 1);

  /* Sit trying to connect to the application board */
  do
  {
    sleep_ms(125);

    gpio_put(LED_PIN, 0);

    if( connect_to_application_board_pico1() )
      break;
      
    sleep_ms(125);

    gpio_put(LED_PIN, 1);

  } while(1);


  while(1)
  {
    gpio_put(LED_PIN, 1);
    sleep_ms(1000);

#if USING_UART_APP_BOARD_LINK
    /* These strings are just name:value pairs for now. */
    send_msg_to_application_board_pico1( "DATE:19/03/26\n" );
    sleep_ms(100);
    send_msg_to_application_board_pico1( "TIME:17:29\n" );
    sleep_ms(100);
    send_msg_to_application_board_pico1( "WIFI SSD:del2019\n" );
    sleep_ms(100);
    send_msg_to_application_board_pico1( "WIFI PWR:91%\n" );
    sleep_ms(100);
    send_msg_to_application_board_pico1( "BATT:74%\n" );
    sleep_ms(100);
    send_msg_to_application_board_pico1( "OS:5.10.17\n" );
    sleep_ms(100);
    /* This isn't supported at the other end as yet */
    send_msg_to_application_board_pico1( "PICO2:PUTS:<NO SSD INSERTED>\n" );
#endif

    gpio_put(LED_PIN, 0);
    sleep_ms(500);
  }
}
