/*
 * Z88 Recreate QMK Keyboard Map
 *
 * (C) Derek Fountain 2024
 *
 * Distributed under the same terms as the Z88 Recreation Project.
 * https://github.com/blackjetrock/z88-recreate
 */

#include QMK_KEYBOARD_H

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [0] = LAYOUT_64_ansi(
        /* D5       D4       D3       D1       D7       D0       D6       D2    */
        KC_TAB,  KC_LCTL, KC_F3,   KC_SCLN, KC_F1,   KC_QUOT, KC_LSFT, KC_COMM,      /* Top two lines are switched wrt the grid diagram, not sure why */
	KC_ESC,  KC_F2,   KC_CAPS, KC_SLSH, KC_RSFT, KC_NUHS, KC_LALT, KC_DOT,
	KC_1,    KC_Q,    KC_A,    KC_L,    KC_NO,   KC_0,    KC_SPC,  KC_Z,
	KC_2,    KC_W,    KC_S,    KC_M,    KC_NO,   KC_P,    KC_LEFT, KC_X,
	KC_3,    KC_E,    KC_D,    KC_K,    KC_NO,   KC_9,    KC_RGHT, KC_C,
	KC_4,    KC_R,    KC_F,    KC_J,    KC_EQL,  KC_O,    KC_DOWN, KC_V,
	KC_5,    KC_T,    KC_G,    KC_U,    KC_BSLS, KC_I,    KC_UP,   KC_B,
	KC_6,    KC_Y,    KC_H,    KC_7,    KC_BSPC, KC_8,    KC_ENT,  KC_N
    ),
};

/*
 * Bit of hook code follows. See
 *  https://docs.qmk.fm/#/custom_quantum_functions?id=example-process_record_user-implementation
 * The hook is called before every key press or release is
 * handled. If it's a shift, and both shifts end up down,
 * light the Pico's LED.
 *
 * In the big scheme of things this will turn on power to
 * CM4, displays, etc. Not sure about that bit yet. :)
 */
#include "hardware/gpio.h"

const uint8_t LED_PIN = 25;

void keyboard_pre_init_user(void)
{
  gpio_init( LED_PIN );
  gpio_set_dir( LED_PIN, GPIO_OUT );
  gpio_put(LED_PIN, 0);    
}

static bool right_shift_pressed = 0;
static bool left_shift_pressed  = 0;

bool process_record_user(uint16_t keycode, keyrecord_t *record)
{
  if( keycode != KC_RSFT && keycode != KC_LSFT )
  {
    /* Only interested in shift keys, just bail out back to QMK */
    return true;
  }

  if( keycode == KC_RSFT )
  {
    right_shift_pressed = record->event.pressed;
  }
  else
  {
    left_shift_pressed = record->event.pressed;
  }

  gpio_put(LED_PIN, (right_shift_pressed && left_shift_pressed) );

  return true;
}
