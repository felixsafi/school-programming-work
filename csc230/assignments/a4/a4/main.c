/*
 * a4.c
 *
 * Created: 2025-04-01 5:26:15 PM
 * Author : Felix Safieh
 */ 

//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
//--> | Setup |-----------------------------------------------
//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.

//:.:.:.|Library Includes|.:.:.:
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>

//:.:.:.|Header File Includes|.:.:.:
#include "main.h"
#include "lcd_drv.h"

//:.:.:.|Defines / Global Variables|.:.:.:
#define NUMBER_OF_TIME_VALS_TRACKED 4 // How many units are used to track time
#define LENGTH_OF_SCREEN 16 //how many chars fit on the screen
#define MAX_CHAR_PER_VAL 3 //max number of characters used to display any time value
#define VALUE_INDEX 0 //where in the values array the actual count value is stored
#define OVF_INDEX 1 //where in the values array the overflow value is stored

volatile uint16_t smallest_counter = 0; ///< (1/100) of a second timer
volatile uint8_t sw_status = 0; ///< bool for tracking if sw is on

//:.:.:.|Function Prototypes|.:.:.:
void timer_init();
void update_screen(char* current_time, int sw_on); 
void generate_time_string(int time_values[NUMBER_OF_TIME_VALS_TRACKED][3], char* string_to_update);
// void button_init();

//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
//--> | ISRs |------------------------------------------------
//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
/**
 * @brief ISR that updated "smallest_counter" on timer interrupt
 */
ISR(TIMER1_COMPA_vect){
	smallest_counter++;
}

/**
 * @brief ISR that updates the status of the stopwatch
 */
 ISR(PCINT0_vect){
 	sw_status = 1; //flip status when button pressed
 }

//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
//--> | Main Program |----------------------------------------
//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.

int main( void )
{
	DDRL = 0xFF; //#Debug
	
	//main time values array
	//no logic for it but if chars to display exceeded the screen size would need to accommodate with scrolling or something
	int time_values[NUMBER_OF_TIME_VALS_TRACKED][3]={
			{0, 1000, 3}, //ms            -> initialized: 0, overflow: 100 ms    , chars to display: 3
			{0, 60, 2},   //seconds      -> initialized: 0, overflow: 60 seconds, chars to display: 2
			{0, 60, 2},   //minutes      -> initialized: 0, overflow: 60 minutes, chars to display: 2
			{0, 60, 2},   //hours        -> initialized: 0, overflow: 60 hours,   chars to display: 2
	};//{xx,yy, z}  //<unit>        -> initialized: xx,overflow: yy <units>, chars to display:<z (where z is at most MAX_CHARS_PER_VALUE> 
	
	char current_time_string[LENGTH_OF_SCREEN+1];///< char array holding all digits of the screen plus null term
	int last_index = NUMBER_OF_TIME_VALS_TRACKED-1; //used enough to make a variable

	lcd_init(); // initialize the LCD Screen
	//update_screen("00:00:00.000   ", 0); //set top and bottom screens to 0
	cli();
	timer_init(); //set up and start the timer
	sei();
	
	while(1){ 
		cli();//stop interrupts while updating the values
		int sw_on_copy = sw_status; //copy this value to use while interrupts are off, it will be used later
		int mseconds = smallest_counter;
		sei(); //resume 	
		
		if (mseconds>=1000){
			//reset the counter
			cli();
			smallest_counter = 0;
			sei();
		}
		
			time_values[0][0]++;


		//If counter value is equal to or exceeding the buffer (1000 in this case)			
			int i=0; //counter
			while (i<(last_index-1)){
			//for number of tracked values minus the last one go through each one
				
				if(time_values[i][VALUE_INDEX]>=time_values[i][OVF_INDEX]){
				//if said value equals or exceeds the overflow number set in the array at [i][1]
					
						time_values[i+1][VALUE_INDEX]++; //add one to next place value
						time_values[i][VALUE_INDEX]=0; //reset the overflowed value to 0
						
						switch (i){
							case 1:
								PORTL=0x10;
								break;
							case 2:
								PORTL=0xA0;
								break;
							default:
								PORTL=0x00;
						}		
				}
				else{
					break; //early exit if you get to a place value which doesn't overflow, since no other ones would after
				}
				i++;
			}
			
			if(time_values[last_index][VALUE_INDEX]>=time_values[last_index][OVF_INDEX]){
			//error check for if the final place value overflows just reset it to 0
					
				time_values[last_index][VALUE_INDEX]=0;
			}
			
			generate_time_string(time_values, current_time_string);
			update_screen(current_time_string, sw_on_copy); //pushes the update to the screen
				
	}
}

/**
 * @brief Updates main timer on the LCD
 *
 * @param current_time - string via char pointer	
 * @param sw_on - if true row 2 time is paused, sync times if false
 */
void update_screen(char* current_time, int sw_on){
	lcd_xy(0, 0); ///< Move cursor to the top left
	lcd_puts(current_time); ///< update the current time elapsed
	if(!sw_on){
		lcd_xy(1,0); ///< Move cursor to the top left
		lcd_puts(current_time); ///< update the stopwatch time
	}
}

/**
 * @brief Updates main timer on the LCD
 *
 * @param current_time - string via char pointer	
 * @param sw_on - if true row 2 time is paused, sync times if false
 */
void generate_time_string(int time_values[NUMBER_OF_TIME_VALS_TRACKED][3], char* string_to_update){
	/*
	char* pointer_to_str = string_to_update;
	for(int i=NUMBER_OF_TIME_VALS_TRACKED-1; i>=0; i--){
	//for each value append it to the string to return - go backwards so starts from largest unit                   
		pointer_to_str += sprintf(pointer_to_str, "%0*d", time_values[i][2], time_values[i][VALUE_INDEX]);
		if (i >= 2){
			 *pointer_to_str++ = ':'; //add : after every val down to seconds
		}
		else if (i==1) *pointer_to_str++ = '.'; //makes it seconds.ms
	}
	*pointer_to_str = '\0';
	*/
	string_to_update = "000000";
}

//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
//--> | Initializing |----------------------------------------
//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.

/**
 * @brief Start the timer for milliseconds
 */
void timer_init(){
	//TODO: add setup for the millisecond timer
	TCCR1A = 0;
	TCCR1B = (1 << WGM12);  // CTC mode
	OCR1A = 249;            // 1ms at 16MHz with /64 prescaler (16,000,000 / 64 / 1000 = 250 - 1)
	TIMSK1 |= (1 << OCIE1A); // Enable compare match A interrupt
	TCCR1B |= (1 << CS11) | (1 << CS10); // Start timer with /64 prescaler
}

/**
 * @brief set up the buttons
 */
//void button_init