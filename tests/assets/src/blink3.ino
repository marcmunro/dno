/*
  Blink3

*/

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

void setup()
{
    pinMode(LED_BUILTIN, OUTPUT);
    led_off(LED_BUILTIN);
}

