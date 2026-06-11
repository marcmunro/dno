/*
 * Another version of blink using Deferals and demonstrating eeprom
 * usage.
 */

#include <Deferal.h>
#include <avr/eeprom.h>
static bool led_is_on;
static Deferal myTimer(500);

#define SENTINEL 0xdeadbeef
#define SERIAL_BAUD_RATE 115200

struct {
    uint32_t sentinel;
    char my_msg[40];
    uint16_t my_node_id;
} eeprom EEMEM = {
  	          SENTINEL,
		  "Here, put this fish in your ear",
		  42}; 

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
    Serial.begin(SERIAL_BAUD_RATE);
}


void
send_msg()
{
    char c;
    if (eeprom_read_dword(&eeprom.sentinel) == SENTINEL) {
        Serial.print("Node ");
        Serial.print(eeprom_read_word(&eeprom.my_node_id));
        Serial.print(" says ");
	for (int i = 0;
	     c = eeprom_read_byte(&(eeprom.my_msg[i]));
	     i++) {
	    Serial.print(c);
	}

	Serial.println();
    }
    else {
        Serial.print("eeprom not initialised: ");
        Serial.println(eeprom.sentinel);
    }
}

void loop()
{
    if (!myTimer.running()) {
	toggle_led(LED_BUILTIN);
	myTimer.again();
	send_msg();
    }
    // We can add code to do all sorts of things here, without the
    // timing of our led blinks being affected.
    
}

