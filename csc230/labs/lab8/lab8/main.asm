;
; lab8.asm
;
; Created: 2025-03-21 5:21:58 PM
; Author : felix
;

.cseg
.org 0 
	jmp start

.include "lcd.asm"

.cseg
; Replace with your application code
start:
    rcall lcd_init

	ldi r16, 0
	ldi r17, 0
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	ldi r16, 'U'
	push r16
	rcall lcd_putchar
	pop r16
 
 Done: rjmp Done
