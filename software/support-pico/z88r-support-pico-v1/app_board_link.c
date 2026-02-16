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


#include "app_board_link.h"

#if USING_UART_APP_BOARD_LINK

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#include "hardware/uart.h"
#include "hardware/gpio.h"

static bool   uart_configured        = false;
static bool   app_board_enabled      = false;

/* v1.0, Support Pico UART to the application board Pico is wired up on UART1, pins 12 and 12 */
static       uart_inst_t *APPLICATION_BOARD_UART = uart1;
static const uint32_t     UART_TX_PIN            = 11;
static const uint32_t     UART_RX_PIN            = 12;
static const uint32_t     UART_BAUD_RATE         = 115200;

static void enable_application_board( void )
{
  if( !app_board_enabled )
  {
    // Set the gpio
    // Pause to let the Picos come up

    app_board_enabled = true;
  }

  return;
}

static void disable_application_board( void )
{
  if( app_board_enabled )
  {
    // Unset the gpio

    app_board_enabled = false;
  }

  return;
}

/*
 * Application board Pico1 to Support Pico link code. All current hard coded to
 * use a UART at both ends as per v1.1.
 */

void send_msg_to_application_board_pico1( uint8_t *msg )
{
  if( uart_configured )
  {
    uart_puts( APPLICATION_BOARD_UART, (const char *)msg );
  }
}

bool connect_to_application_board_pico1( void )
{
  enable_application_board();

  gpio_set_function( UART_TX_PIN, UART_FUNCSEL_NUM(APPLICATION_BOARD_UART, UART_TX_PIN) );
  gpio_set_function( UART_RX_PIN, UART_FUNCSEL_NUM(APPLICATION_BOARD_UART, UART_RX_PIN));

  if( uart_init( APPLICATION_BOARD_UART, UART_BAUD_RATE ) != UART_BAUD_RATE )
    return false;

  uart_set_hw_flow( APPLICATION_BOARD_UART, false, false );

  uart_configured = true;

  return true;
}

void disconnect_from_application_board_pico1( void )
{
  if( uart_configured )
  {
    // Disconnect the UART

    uart_configured = false;
  }

  if( app_board_enabled )
  {
    disable_application_board();
  }
  
  return;
}


#else

/* Stubs if the application board doesn't connect to the Support Pico */

void connect_to_application_board_pico1( void )
{
  return;
}

void disconnect_from_application_board_pico1( void )
{
  return;
}

#endif
