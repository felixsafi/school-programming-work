/*
 * lab9_p.c
 *
 * Created: 2025-04-01 1:33:27 PM
 * Author : felix
 */ 

#include "CSC230.h"


int main(void)
{
	/*
	* Loop of lights flashing on then off using portL and portB
	* Turns light 4&6 on then delay
	* Turns them off, then another delay
	*/
	
    DDRL = 0xFF; //Set port L for output
	DDRB = 0xFF; //Set port B for output
    while (1) 
    {
		PORTL = 0x88; //set PortL 7&3 to high (on)
		PORTB = 0x00; //set PortB all low (off)
    
		_delay_ms(500); //hald second delay
		
		//turn all off
		PORTL = 0x00;
		PORTB = 0x00; 
		
		_delay_ms(500); //another delay
	}
	return 1;
}

