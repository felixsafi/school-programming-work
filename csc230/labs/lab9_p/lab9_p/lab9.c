#define F_CPU 16000000UL

#include "CSC230.h"

/*
 * Our 6 LED strip occupies ardruino pins 42, 44, 46, 48, 50, 52
 * and Gnd (ground)
 * Pin 42 Port L: bit 7 (PL7)
 * Pin 44 Port L: bit 5 (PL5)
 * Pin 46 Port L: bit 3 (PL3)
 * Pin 48 Port L: bit 1 (PL1)
 * Pin 50 Port B: bit 3 (PB3)
 * Pin 52 Port B: bit 1 (PB1)
*/
void set_led_by_num(int led_number);

int main (void)
{
  /* set PORTL and PORTB for output*/
  DDRL = 0xFF;
  DDRB = 0xFF;
  while (1)
  {
// 	  for(int i = 1; i<=5; i++)
// 	  {
// 		set_led_by_num(i);
// 		_delay_ms(100); 
// 		PORTB = 0x00;
// 		PORTL = 0x00;
// 	  }
// 	  for(int i = 4; i>=0; i--)
// 	  {
// 		  set_led_by_num(i);
// 		  _delay_ms(100);
// 		  PORTB = 0x00;
// 		  PORTL = 0x00;
// 	  }
			PORTB = 0x00;
	  PORTL = 0x00;
  }
}

void set_led_by_num(int led_number){
	/*
	Turns on a specified LED, and turns all on if invalid int received.
	
	Arguments:
		int: Led number to turn on
	*/
	switch (led_number)
	{
		case 0: //turn led 1 on
			PORTB = 0b00001010;
			break;
		case 1: //led 2 on
			PORTB = 0b00001000;
			PORTL = 0b00000010;
			break;
		case 2: //led 3 on
			PORTL = 0b00001010;
			break;
		case 3: //led 4 on
			PORTL = 0b00101000;
			break;
		case 4: //led 5 on
			PORTL = 0b10100000;
			break;
		case 5: //led 6 on
			PORTL = 0b10000000;
			PORTB = 0b00000010;
			break;
		default: //turn all on if invalid number received
			PORTB = 0b00001010;
			PORTL = 0b10101010;
	}
}

