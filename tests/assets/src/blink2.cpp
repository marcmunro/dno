/*
 * Another blink progrram for arduino.  This uses the Deferal library
 * in order to create non-blocking, and accurate waits.
 * 
 */

#include "Arduino.h"
#include "HardwareSerial.h"


// Pin 13 has an LED connected on most Arduino boards.
// give it a name:
#define LED 13 

#include <Deferal.h>

static bool led_is_on;
static Deferal myTimer(500);

static void
led_on(int led)
{
    digitalWrite(led, HIGH);
    led_is_on = true;
}

static void
led_off(int led)
{
    digitalWrite(led, LOW);
    led_is_on = false;
}

static void
toggle_led(int led)
{
    if (led_is_on) {
	led_off(led);
    }
    else {
	led_on(led);
    }
}

int
main(void)
{
    init();

    pinMode(LED, OUTPUT);
    while (true) {
	if (!myTimer.running()) {
	    toggle_led(LED_BUILTIN);
	    myTimer.again();
	}
    }
    return 0;
}
