/*
 */

#include "Arduino.h"
#include "HardwareSerial.h"


// Pin 13 has an LED connected on most Arduino boards.
// give it a name:
#define LED 13 

/**
 * @brief Turn on the LED.
 *
 * Doxygen comment
 */
static void
ledon()
{
    digitalWrite(LED, HIGH);
}


/**
 * @brief Turn off the LED.
 *
 * Doxygen comment
 */
static void
ledoff()
{
    digitalWrite(LED, LOW);
}

/**
 * @brief Entry point
 *
 * Doxygen comment
 */
int
main(void)
{
    init();

    pinMode(LED, OUTPUT);
    while (true) {
	ledon();
	delay(100);
	ledoff();
	delay(400);
    }
    return 0;
}
