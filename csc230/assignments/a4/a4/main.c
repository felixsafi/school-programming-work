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

//:.:.:.|Header File Includes|.:.:.:
#include "main.h"
#include "lcd_drv.h"

//:.:.:.|Defines / Global Variables|.:.:.:
#define NUMBER_OF_TIME_VALS_TRACKED 4
#define LENGTH_OF_SCREEN 16
#define MAX_CHAR_PER_VAL 3

volatile uint8_t smallest_counter = 0; ///< (1/100) of a second timer
volatile uint8_t sw_status = 0; ///< bool for tracking if sw is on

//:.:.:.|Function Prototypes|.:.:.:
void timer_init();
void update_screen(char* current_time, bool sw_on); 
int* generate_time_string(int** time_values);
// void button_init();


//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
//--> | Main Program |----------------------------------------
//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.

int main( void )
{
	//main time values array
	//no logic for it but if chars to display exceeded the screen size would need to accommodate with scrolling or something
	int time_values[NUMBER_OF_TIME_VALS_TRACKED][3]={
			{0, 1000, 3} //milliseconds -> initialized: 0, overflow: 60 seconds, chars to display: 2
			{0, 60, 2}   //seconds      -> initialized: 0, overflow: 60 seconds, chars to display: 2
			{0, 60, 2}   //minutes      -> initialized: 0, overflow: 60 minutes, chars to display: 2
			{0, 60, 2}   //hours        -> initialized: 0, overflow: 60 hours,   chars to display: 2
		  //{xx,yy, z}  //<unit>        -> initialized: xx,overflow: yy <units>, chars to display:<z (where z is at most MAX_CHARS_PER_VALUE> 
		};
	
	char current_time_string[LENGTH_OF_SCREEN+1];///< char array holding all digits of the screen plus null term

	lcd_init(); // initialize the LCD Screen
	update_screen("00:00:00.000", 0); //set top and bottom screens to 0
	cli();
	timer_init(); //set up and start the timer
	
	while(1){ 
		cli();//stop interrupts while updating the values
			/** 
			*	This loop is kind of pointless for 2 time denominations that overflow,
			*   but its supposed to be modular so it could keep track of days,months,...
			*/
			int sw_on_copy = sw_status; //copy this value to use while interrupts are on
			
			if(smallest_counter>=time_values[0][1]){ 
				time_values[0][0]=smallest_counter; //set the counter via the volatile variable
			//check other numbers for overflow only if the smallest overflow
				int i=0; //counter
				while (i<(NUMBER_OF_TIME_VALS_TRACKED-1)){
				//for number of tracked values minus the last one
					if(time_values[i][0]>=time_values[i][1]){
					//if said value equals or exceeds the overflow number
							time_values[i+1][1]++; //add one to next place value
							time_values[i]=0; //reset the overflowed value to 0
					}
					else{
						break;
					}
				}
			
				if(time_values[i][0]>=time_values[i][1]){
				//error check for if the final place value overflows just take the remainder value
					i++; //move to the last value
					time_values[i][0]=(time_values[i][0]%time_values[i][1]); 
				}
				sei(); //resume interrupts
				
				// left this part outside the part where interrupts are disabled
				// b/c if the time values are counted its fine if screen update lags as values will eventually be correct
				// used a copy since you're not supposed to use values stored in an ISR while interrupts are on
				update_screen(generate_time_string(time_values), sw_on_copy); 
			}
			
			else{ //if the counter didn't overflow at the smallest place value, no need to update other places
				time_values[0]=smallest_counter; //updates only the smallest value
				update_screen(generate_time_string(time_values), sw_on_copy); //pushes the update to the screen
				sei(); //resume interrupts
			}
	}
}

/**
 * @brief Updates main timer on the LCD
 *
 * @param current_time - string via char pointer	
 * @param sw_on - if true row 2 time is paused, sync times if false
 */
void update_screen(char* current_time, bool sw_on){
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
int* generate_time_string(int** time_values){
	char time_string[LENGTH_OF_SCREEN+1]; //string to return with space for null term
	char* pointer_to_time_string = time_string;  //pointer to the return string
	for(int i=NUMBER_OF_TIME_VALS_TRACKED-1; i>=0; i--){
	//for each value append it to the string to return
		char temp[time_values[i][2]];                          
		pointer_to_time_string += sprintf(pointer_to_time_string, "0*%d", time_values[i][2], time_values[i]);
		if (i > 2){
			 *pointer_to_time_string++ = ':'; //add : after every val down to seconds
		}
		else if (i==1) *pointer_to_time_string++ = '.'; //makes it seconds.ms
	}
	pointer_to_time_string[LENGTH_OF_SCREEN]='\0'; //terminate the string
	return time_string;
}

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
	sw_status = !sw_status;; //flip status when button pressed
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
void button_init