/*
 * display.c
 *
 * Created: 2025-04-01 3:45:36 PM
 *  Author: felix
 */ 
#include "CSC230.h"

int main(void)
{

	lcd_init();    // initialize the displace via fxn in header file
	
	while(1){ //repeat indefinitely
		lcd_xy(0,0); //cursor position set to (col,row) 
		
		lcd_puts("Welcome to CSC230."); //display on the screen
		
		lcd_xy(4,1); //move cursor
		
		_delay_ms(500);
		
		//some other ways to declare a string
		char msg[10]; // 10 char array
		msg[0] = 'H'; //adding chars of the string 1-by-1
		msg[1] = 'i'; 
		msg[2] = '\0'; //null term
		
		lcd_puts(msg);// add string from char array
		
		char msg1[5]="Uvic";
		
		lcd_xy(8,1); //move the cursor again
		lcd_puts(msg1);
	}
	
}