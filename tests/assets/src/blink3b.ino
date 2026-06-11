/*
  Blink3 - part b

*/


void loop()
{
    if (!myTimer.running()) {
	toggle_led(LED_BUILTIN);
	myTimer.again();
    }
    // We can add code to do all sorts of things here, without the
    // timing of our led blinks being affected.
    
}
