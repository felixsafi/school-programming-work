/*
 * display_partA.asm
 *
 * Student name:Felix Safieh
 * Student ID:V00962305
 * Date of completed work:(2025-Mar-21)
 *   
 */ 
 #define LCD_LIBONLY

 .equ BOTH_ROWS = 0x00
 .equ TOP_ONLY = 0b00000001
 .equ BOT_ONLY = 0b00000010

 .def track_state = r20

 .include "m2560def.inc" 

 .cseg

 .org 0    
	jmp Start		   ; jumps to the timer setup, then goes through initial display setup

 .org 0x22            ; Timer1 Compare Match A vector (0x22 = address for OC1A)
    jmp timer_triggered   ; Jump to your ISR

 .cseg ; cautionary directive for post driver file

 ;    ____________________________________________
;   /_-_--__--___---____---_---____---___--__-_-/
;  /-------      SECTION FOR TIMING     -------/
; /_-_--__--___---____---_---____---___--__-_-/
;/___________________________________________/
	Start:
		;Initialize the stack pointer
		ldi     r16, low(RAMEND)
		out     SPL, r16
		ldi     r16, high(RAMEND)
		out     SPH, r16

		;Use timer1 in CTC mode
		ldi     r16, (1 << WGM12)
		sts     TCCR1B, r16

		;Set correct timing values
		ldi     r16, high(15624)
		sts     OCR1AH, r16
		ldi     r16, low(15624)
		sts     OCR1AL, r16

		;enable interrupt
		ldi     r16, (1 << OCIE1A)
		sts     TIMSK1, r16

		;Set prescaler
		ldi     r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
		sts     TCCR1B, r16

		;global interrupts on
		sei

		call lcd_init ;initialize the LCD display

		ldi r20, 0

	wait_for_timer: ; infinite loop that waits for timer to interrupt
		rjmp wait_for_timer

	timer_triggered:
		;Interrupt Service Routine - i.e what to do when the timer is triggered

		push    r16 ; Preserve r16
		in      r16, SREG ; Preserve the SREG
		push    r16 

		;Code to run when timer is triggered
			call init_strings ;initialize string
			call display_strings ;display strings on the screen
		

		pop     r16 ; put back SREG
		out     SREG, r16
		pop     r16 ; Put r16 back
		reti


;    ____________________________________________
;   /_-_--__--___---____---_---____---___--__-_-/
;  /-------SECTION FOR STRING FORMATTING-------/
; /_-_--__--___---____---_---____---___--__-_-/
;/___________________________________________/

init_strings:
		push r16
		
		; copy strings from program memory to data memory
		ldi r16, high(str1_in_data)		;this the destination
		push r16
		ldi r16, low(str1_in_data)
		push r16
		ldi r16, high(str1 << 1) ; this is the source
		push r16
		ldi r16, low(str1 << 1)
		push r16
		call str_init			; copy from program to data
		pop r16					; remove the parameters from the stack
		pop r16
		pop r16
		pop r16

		; copy strings from program memory to data memory
		ldi r16, high(str2_in_data)		;this the destination
		push r16
		ldi r16, low(str2_in_data)
		push r16
		ldi r16, high(str2 << 1) ; this is the source
		push r16
		ldi r16, low(str2 << 1)
		push r16
		call str_init			; copy from program to data
		pop r16					; remove the parameters from the stack
		pop r16
		pop r16
		pop r16

		pop r16
		ret

;    ____________________________________________
;   /_-_--__--___---____---_---____---___--__-_-/
;  /------- SECTION FOR DISPLAY CHANGES -------/
; /_-_--__--___---____---_---____---___--__-_-/
;/___________________________________________/
	display_strings:
		
		;This subroutine displays two string onto the screen
		;It requires that both strings fit the screen and start at the leftmost position

		
		push r16
		call lcd_clr ; clear the screen

		;check for display  
		;lds r16, state_in_data ; load in the current led state

		;Compare to see which state to set things to and branch accordingly
		cpi track_state, BOTH_ROWS
		BREQ turn_on_both

		cpi track_state, TOP_ONLY
		BREQ turn_on_top
		
		cpi track_state, BOT_ONLY
		BREQ turn_on_bottom

		turn_on_both:
			;add both strings to the screen
			call add_str_1
			call add_str_2

			ldi r20, 0b00000001 ; increase state trackr to match that of next desired state
			;sts state_in_data, r16 ; store back in SRAM
			rjmp end_display_routine ; jump to end of screen update

		turn_on_top:
			call add_str_1 ;add top line string
			ldi r20, 0b00000010 ; increase state trackr to match that of next desired state
			;sts (state_in_data), r16 ; store back in SRAM
			rjmp end_display_routine

		turn_on_bottom:
			call add_str_2 ;add bottom line string
			ldi r20, 0 ; reset state trackr to match that of next desired state
			;sts state_in_data, r16 ; store back in SRAM
			rjmp end_display_routine

		end_display_routine:
			pop r16 
			ret

	add_str_1:
		;---- ADDING STR 1 ----
			ldi r16, 0x00
			push r16 ;push y pos
			ldi r16, 0x00
			push r16 ;push x pos

			call lcd_gotoxy ; move cursor
	
			pop r16 ; clear x,y from stack
			pop r16

			;push str 1 onto the stack
			ldi r16, high(str1)
			push r16
			ldi r16, low(str1)
			push r16

			call lcd_puts ; Display the str

			;clear str L & H from stack
			pop r16
			pop r16
			ret

	add_str_2:
		;---- ADDING STR 2 ----
			;Push values that will move the cursor to the second line

			ldi r16, 0x01
			push r16
			ldi r16, 0x00
			push r16

			call lcd_gotoxy ;move cursor

			;clear location for x,y from stack
			pop r16 
			pop r16

			;push message 2 onto the stack
			ldi r16, high(str2)
			push r16
			ldi r16, low(str2)
			push r16

			call lcd_puts ; Display the message

			;clear message L & H from stack
			pop r16
			pop r16

			ret

			.include "lcd.asm"
; Defining the two strings
str1: .db "Felix Safieh", 0, 0
str2: .db "CSC 230: Spring 2025", 0, 0


.dseg
	;Allocating Space for the two strings
	str1_in_data:	.byte 14
	str2_in_data:	.byte 22