/*
  Blink

*/

#include <Deferal.h>

#ifndef LED_BUILTIN
#define LED_BUILTIN 13
#endif

static bool led_is_on;
static Deferal myTimer(500);

void
led_on(int led)
{
    digitalWrite(led, HIGH);
    led_is_on = true;
}

void
led_off(int led)
{
    digitalWrite(led, LOW);
    led_is_on = false;
}

void
toggle_led(int led)
{
    if (led_is_on) {
	led_off(led);
    }
    else {
	led_on(led);
    }
}

void setup()
{
    pinMode(LED_BUILTIN, OUTPUT);
    led_off(LED_BUILTIN);
}

void loop()
{
    if (!myTimer.running()) {
	toggle_led(LED_BUILTIN);
	myTimer.again();
    }
    // We can add code to do all sorts of things here, without the
    // timing of our led blinks being affected.
    
}
