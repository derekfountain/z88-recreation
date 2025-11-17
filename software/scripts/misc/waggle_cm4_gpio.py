#!/usr/bin/python3

# CM4 GPIO waggler, shows on the 'scope.
#
# https://lab.arts.ac.uk/books/raspberry-pi/page/what-are-gpio-pins-on-raspberry-pi
#
# The CM4 uses BCM mode, so if you run this with GPIO 7:
#
#  ./waggle_cm4_gpio.py 7
#
# and connect the probe to pin 26 (halfway along top side) of the HAT
# connector, you'll see a square-ish wave on the scope.

import sys
from time import sleep

if len(sys.argv) != 2:
    print( "Usage ",sys.argv[0]," gpio" )
    sys.exit(-1)

test_gpio = int(sys.argv[1])

from time import sleep

import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(True)
GPIO.setup(test_gpio, GPIO.OUT)

state = GPIO.LOW

try:
    while True:
        if state == GPIO.LOW:
            state = GPIO.HIGH
        else:
            state = GPIO.LOW
        
        print("Toggle GPIO ",test_gpio," ",state)
        GPIO.output(test_gpio, state)
        sleep(0.20)

except KeyboardInterrupt:
    print("Ctrl-C")
    
finally:
    GPIO.cleanup
    print("Exit")
    
    
