#define LCD_LIBONLY
.include "lcd.asm"

.cseg

start:
	rcall lcd_init			; call lcd_init to Initialize the LCD

	ldi r17, high(7800)
	ldi r16, low(7800)
	sts OCR1AH, r17
	sts OCR1AL, r16

	ldi r16, 0
	sts TCCR1A, r16

	ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
	sts TCCR1B, r16

	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16
	sei

	call init_strings
	call display_strings

	;add function where bottom is off

	;add function where top is off


blink_loop:
	;figure out the (row, column) of '!' and make a change
	ldi r16, 0 ; <- TODO: change the row
	ldi r17, 0 ; <- TODO: change the column
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	lds r16, CHAR_ONE
	push r16
	rcall lcd_putchar
	pop r16

	rjmp blink_loop


init_strings:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(msg1)		; this the destination
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) ; this is the source
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg2_p << 1)
	push r16
	ldi r16, low(msg2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16
	ret

display_strings:

	; This subroutine sets the position the next
	; character will be output on the lcd
	;
	; The first parameter pushed on the stack is the Y position
	; 
	; The second parameter pushed on the stack is the X position
	; 
	; This call moves the cursor to the top left (ie. 0,0)

	push r16

	call lcd_clr

	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the first line
	ldi r16, high(msg1)
	push r16
	ldi r16, low(msg1)
	push r16
	call lcd_puts
	pop r16
	pop r16

	; Now move the cursor to the second line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the second line
	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop r16
	ret

change_which_is_off_isr:
	;how many registers you are going to use?
	;preserve the values on the stack
	;also save the status register

	;read CHAR_ONE into, say, r16 and 
	;read CHAR_TWO into, say r17
	;store r16 in CHAR_TWO
	;store r17 in CHAR_ONE <- now, they are swapped

	;restore the status register and the registers that you used
	reti

msg1_p:	.db "Felix Safieh", 0	
msg2_p: .db "CSC 230: Spring 2025", 0
.dseg
;
; The program copies the strings from program memory
; into data memory.  These are the strings
; that are actually displayed on the lcd
;
msg1:	.byte 200
msg2:	.byte 200

