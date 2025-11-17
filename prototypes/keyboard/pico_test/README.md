# Z88 Recreate Test Keyboard

Test of the original Z88 rubber key keyboard into a Pico.

The two membrane tails were connected, left to right, to
GPIOs 0 through 15. i.e. the leftmost track on the left
connector went to GPIO0, the next track went to GPIO1,
the leftmost track on the right connector went to GPIO8,
etc.

See photo - left side connector is SK6, the address bus
lines, and each one goes through a 1N4148 diode to the
Pico's lower GPIOs (0-7). The right side is SK7, the data
lines, they just go straight to the Pico's higher GPIOs
(8-15).

The diodes are necessary. Without them combinations like
7,8 and M, or left-shift and space, don't work. Even with
them there are limitations. For example, right-shift and HELP
are OK, but right-shift, HELP and MENU shows as right-shift,
HELP, MENU and CAPSLOCK are pressed. Two keys seem to work
OK in all circumstances, A third key works as long as it's
not in the same data bus line as the other two. I think.
I'm not sure how that relates to the original machine
(my z88 is currently broken).

The output matrix looks like:

```
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
```

It matches the discussion at

https://cambridgez88.jira.com/wiki/spaces/ZSM/pages/68780095/9.+Keyboard+Handling

and the accompanying diagram:

https://cambridgez88.jira.com/wiki/spaces/ZSM/pages/68780199/Figure+1.3+-+Keyboard+Matrix+Interconnections

only the address lines go down the page, so the matrix is
rotated 90 degrees clockwise. See the fig13_90cw.png image
in with this source code.

So this is pound (i.e. UK currency symbol):

```
GPIOs state = 01111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
```

This is right shift:

```
GPIOs state = 11111110
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
```

This is DEL:

```
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111110
```

and this is '8':

```
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 11111111
GPIOs state = 01111111
```
