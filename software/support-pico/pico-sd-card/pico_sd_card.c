/*
 * Support Pico SD card Example, a Raspberry Pi Pico SD card test
 * Copyright (C) 2025 Derek Fountain
 */

/*
 * This is an updated version of the example code which comes with
 * no-OS-FatFS-SD-SPI-RPi-Pico. Licence isn't specified in the original
 * so assuming Apache Licence, as per the rest of that project..
 */

/*
 * cmake -DCMAKE_BUILD_TYPE=Debug ..
 * make -j10
 *
 * With the RPi Debug Probe:
 * 
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" \
 *              -c "program pico_sd_card.elf verify reset exit"
 * sudo openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000"
 *
 * gdb-multiarch pico_sd_card.elf
 *  target remote localhost:3333
 *  load
 *  monitor reset init
 *  continue
 *
 * With the home made Pico probe:
 *
 * sudo openocd -f interface/picoprobe.cfg -f target/rp2040.cfg \
 *              -c "program ./pico_sd_card.elf verify reset exit"
 *
 * On the z88r:
 *
 * scp pico_sd_card.elf z88r:tmp
 *
 * sudo pinctrl set 23 op
 * sudo pinctrl set 24 op
 * sudo pinctrl set 23 dl; sudo pinctrl set 24 dl
 * sudo openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg -c "program ./pico_sd_card.elf verify reset exit"
 *
 * sudo minicom -D /dev/ttyAMA0 -b 115200
 */

#include <stdio.h>
#include "pico.h"
#include "pico/stdlib.h"
#include "pico/binary_info.h"

#include "f_util.h"

#include "hw_config.h"

int main()
{
  bi_decl(bi_program_description("Pico SD card example binary."));

  // Do this before calling uart_init to avoid losing data
  gpio_set_function(0, UART_FUNCSEL_NUM(uart0, 0));
  gpio_set_function(1, UART_FUNCSEL_NUM(uart0, 1));

  // Initialise UART 0
  uart_init(uart0, 115200);

  uart_puts(uart0, "Hello, world!\r\n");

  char panic_buffer[512];
    
  sd_card_t *pSD = sd_get_by_num(0);
  FRESULT fr = f_mount(&pSD->fatfs, pSD->pcName, 1);
  if( fr != FR_OK )
  {
    sprintf( panic_buffer, "f_mount error: %s (%d)\n", FRESULT_str(fr), fr);
    uart_puts(uart0, panic_buffer);
    for(;;);
  }

  uart_puts(uart0, "Mount succeeded\r\n");

  FIL fil;
  const char* const filename = "test.txt";
  fr = f_open(&fil, filename, FA_READ);
  if( fr != FR_OK && fr != FR_EXIST )
  {
    sprintf( panic_buffer, "f_open(%s) error: %s (%d)\n", filename, FRESULT_str(fr), fr);
    uart_puts(uart0, panic_buffer);
    for(;;);
  }

  uart_puts(uart0, "Open succeeded\r\n");

  char line_buffer[256+1];
  if( f_gets( line_buffer, 256, &fil ) == NULL )
  {
    sprintf( panic_buffer, "f_gets(%s) error: %s (%d)\n", filename, FRESULT_str(fr), fr);
    uart_puts(uart0, panic_buffer);
    for(;;);
  }

  uart_puts(uart0, "f_gets succeeded\r\n");
      
  uart_puts(uart0, line_buffer);

  fr = f_close(&fil);
  if (FR_OK != fr) {
    sprintf( panic_buffer, "f_close error: %s (%d)\n", FRESULT_str(fr), fr);
    uart_puts(uart0, panic_buffer);
    for(;;);
  }

  f_unmount(pSD->pcName);

  uart_puts(uart0, "Goodbye, world!\r\n");
  for (;;);
}
