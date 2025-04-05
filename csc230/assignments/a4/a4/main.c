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
#define ROWS_ON_SCREEN 2

volatile uint16_t subsecond_vtl_counter = 0; 
volatile uint8_t sw_status = 0; ///< bool for tracking if sw is on

//:.:.:.|Function Prototypes|.:.:.:
void timer_init();
void set_initial_screen();
void convert_num_to_char_array(const int *timer_val, const int *chars_to_display, char *formatted_display_values, const int *powers_of_ten);
void update_screen(const char *char_array, const int *length, const int *sw_val, const int *x_axis_location);
// void button_init();

//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
//--> | ISRs |------------------------------------------------
//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
/**
 * @brief ISR that updated "subsecond_vtl_counter" on timer interrupt
 */
ISR(TIMER1_COMPA_vect){
	subsecond_vtl_counter++;
}

/**
 * @brief ISR that updates the status of the stopwatch
 */
 ISR(PCINT0_vect){
 	sw_status = !sw_status; //flip status when button pressed
 }

//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
//--> | Main Program |----------------------------------------
//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.

int main( void )
{
	DDRL = 0xFF; //#Debug
	//saved variables	
	int last_index = NUMBER_OF_TIME_VALS_TRACKED-1;
	
	int timer_values[NUMBER_OF_TIME_VALS_TRACKED] = {0, 0, 0, 0};
	int timer_overflow_values[NUMBER_OF_TIME_VALS_TRACKED] = {1000, 60, 60, 60};
	int number_of_digits_for_values[NUMBER_OF_TIME_VALS_TRACKED] = {3, 2, 2, 2};
	int screen_location_of_values[NUMBER_OF_TIME_VALS_TRACKED] = {9,6,3,0};
		
	int pow_of_ten[NUMBER_OF_TIME_VALS_TRACKED] = {1,10,100,1000};
		
	int sw_on_copy = 0;
	
	lcd_init(); // initialize the LCD Screen
	set_initial_screen();
	//update_screen("00:00:00.000   ", 0); //set top and bottom screens to 0
	cli();
	timer_init(); //set up and start the timer
	sei();
	
	while(1){ 
		cli();//stop interrupts while updating the values
		sw_on_copy = sw_status; //copy this value to use while interrupts are off, it will be used later
		timer_values[0] = subsecond_vtl_counter;
		subsecond_vtl_counter = subsecond_vtl_counter%1000;
		sei(); //resume 	

		for (int i=0; i<=last_index; i++){
		//for each place value tracked
			char temp_array[number_of_digits_for_values[i]];
			convert_num_to_char_array(&timer_values[i], &number_of_digits_for_values[i], temp_array, pow_of_ten);
			
			if(timer_values[i]>=timer_overflow_values[i]){
			//zeros the current place value being looked at, and increments the next, if overflow occurs
				
				//safety check for hours overflow. Just mods the total hours by val
				timer_values[i]=timer_values[i]%timer_overflow_values[i];
				if(i!=last_index) timer_values[i+1]++;	
			}
			else{ 
			//if no overflow happens update the screen then break, as no larger p.v will have changed
				update_screen(temp_array, &number_of_digits_for_values[i], &sw_on_copy, &screen_location_of_values[i]);
				break;
			}
			update_screen(temp_array, &number_of_digits_for_values[i], &sw_on_copy, &screen_location_of_values[i]);
		}			
	}
}


/**
 * @brief Updates main timer on the LCD
 *
 * @param current_time - string via char pointer	
 * @param sw_on - if true row 2 time is paused, sync times if false
 */

// void print_time() {
// 	lcd_xy(row, 0);
// 	for (int i = NUMBER_OF_TIME_VALS_TRACKED - 1; i >= 0; i--) {
// 		int value = time_values[i][VALUE_INDEX];
// 		int digits = time_values[i][2];
// 
// 		for (int d = digits - 1; d >= 0; d--) {
// 			uint8_t digit = (value / power_of_10(d)) % 10;
// 			lcd_putchar(digit + 48);
// 		}
// 
// 		if (i >= 2) lcd_putchar(':');
// 		else if (i == 1) lcd_putchar('.');
// 	}
	


void update_screen(const char *char_array, const int *length, const int *sw_val, const int *x_axis_location){
	int rows_to_print = (!*sw_val); //evaluates to 0 if sw on and 1 if sw off
	int x = *x_axis_location;

	for(int j=0; j<*length; j++){
	//update each char based on how many there is to display
		for(int i=0; i<=rows_to_print; i++){
		//runs for row 0 if sw on and both if sw is off
			lcd_xy(x, i);
			lcd_putchar(char_array[j]);
		}
		x++;
	}
}

void convert_num_to_char_array(const int *timer_val, const int *chars_to_display, char *formatted_display_values, const int *powers_of_ten){
	for(int i = 0; i<*chars_to_display; i++){
		formatted_display_values[i] = '0' + (*timer_val / powers_of_ten[(*chars_to_display-1)-i]) % 10; 
	}
}

//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
//--> | Initializing |----------------------------------------
//:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.

/**
 * @brief sets the screen to all zeros adds ":" and "." in correct place
 */
void set_initial_screen(){
	for(int i=0; i<ROWS_ON_SCREEN; i++){
		for(int j=0; j<12; j++){	
			lcd_xy(j,i);
			
			if(j==2||j==5)lcd_putchar(':'); //add the ":"s
			else if(j==8) lcd_putchar('.'); //add the "."
			else lcd_putchar('0');	//add the "0"s
		}
	}
}

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