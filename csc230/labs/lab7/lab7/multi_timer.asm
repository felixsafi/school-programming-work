;Provided by Dr. Mike Zastre
;.include "m2560def.inc" <- Don't need to include this file since it is implicitly included.
; To read the file, go to "Solution Explorer" on your left, click on arrow before "Dependencies"
; Click on "m2560def.inc"
.cseg
.org 0

; Purpose of this program is to blink three LEDs
; at different rates, and to implement this 
; blinking by using (a) timers and (b) toggling
; port bits.
;
; To make this a bit more tractable, we'll only
; choose LEDS which are controlled via the same
; port register. These three bits will be:
; 
; * pin 42 (Port L, bit 7) -- blink 0.5 seconds;
;   this will run on timer 3. However, we'll call
;   this LED3 below.
; * pin 44 (Port L, bit 5) -- blink 1.5 seconds
;   this will run on timer 4. However, we'll call
;   this LED4 below.
; * pin 46 (Port L, bit 3) -- blink 3.0 seconds
;   this will run on timer 5. However, we'll call
;   this LED5 below.
;
; (Note that we aren't using the names LED1 and
; LED2 -- we're trying to keep the names of delays,
; LEDs, etc. match the names of their timers.)
;
; IMPORTANT NOTE: This program polls the timers
; as part of its code. We can also implement the
; same behavior via interrupts -- which might eventually
; seem easier, but only once we understand the
; asynchronous nature of interrupts.
;


.equ S_DDRL=0x10A
.equ S_PORTL=0x10B

#define DELAY3 0.5
#define DELAY4 1.5
#define DELAY5 3.0

#define LED3 0b10000000
#define LED4 0b00100000
#define LED5 0b00001000

.def temp=r19
.def templow=r16
.def temphigh=r17
.def leds=r18

	; Set up the stack. We should *always* set up
	; the stack.
	;
	; Have I yet said that ...
	; ... we should set up the stack?
	;
	ldi templow, low(RAMEND)
	out SPL, templow
	ldi temphigh, high(RAMEND)
	out SPH, temphigh


	; Let's set the Data Direction Register for 
	; the LEDs port register, and while we're at
	; it, ensure the LEDs are *all* off.
    ;

	ldi temp, 0xff
	sts S_DDRL, temp
	out DDRB, temp  ;turn off two leds controled by portB, added by Victoria
	ldi temp, 0b00000000
	sts S_PORTL, temp ;turn off two leds controled by portB, added by Victoria
	out PORTB,temp


	; What follows is a bit of assembler arithmetic.
	; All of the quantities below are calculated at
	; assembly time.
	;
	; The PRESCALE value is set to 1024 -- that is,
	; because base system clock runs at 16MHz and it is too
    ; fast for our purposes (i.e., a 16-bit counter would
    ; overflow in no time).  The PRESCALE value permits us
    ; to use a "version" of the clock that runs slower but
    ; without needing a separate and slower clock.
	;

#define CLOCK 16.0e6
.equ PRESCALE_DIV=1024  ; implies CS[2:0] is 0b101

.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

;TO DO:
;Write similar code for TOP4 and TOP5 below:
	
.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif

.equ TOP5=int(0.5+(CLOCK/PRESCALE_DIV*DELAY5))
.if TOP4>65535
.error "TOP4 is out of range"
.endif

	; We'll now set up the three timers. For each timer we
	; must:
	;
	; (1) Set its Output Compare Register to the proper
	;     TOP value for that register. Note carefully how
	;     the high byte is output first, then the low
	;     byte. THIS IS ABSOLUTELY NECESSARY!

	; (2) Set its Timer Counter Control Registers to
	;     the correct configuration (which for us really
	;     means only setting values in the TCCR B register).
	;     But just to be safe, we'll clear all the bits in
	;     the TCCR A register as well.
	;

	; Timer 3
	;
	ldi temphigh, high(TOP3)
	ldi templow, low(TOP3)
	sts OCR3AH, temphigh
	sts OCR3AL, templow

	ldi temp, 0
	sts TCCR3A, temp ;p154 of the datasheet, all 8 bits of TCCR3A are set to 0

	; Note the syntax below. The mnemonics are defined
	; within m2560def.inc, and represent bit positions
	; in the register. e.g. on line 1226, CS32 is defined as: 
	;.equ CS32 = 2; Prescaler source of Timer/Counter 3
	;
	ldi temp, (1 << WGM32) | (1 << CS32) | (1 << CS30)
	sts TCCR3B, temp ; set register TCCR3B to 0b00001101


	; Timer 4
	;
;TO DO:
;Write similar code for TOP4 below:
	ldi temphigh, high(TOP4)
	ldi templow, low(TOP4)
	sts OCR4AH, temphigh
	sts OCR4AL, templow

	ldi temp, 0
	sts TCCR4A, temp

	ldi temp, (1 << WGM42) | (1 << CS42) | (1 << CS40)
	sts TCCR4B, temp

	; Timer 5
	;
;TO DO:
;Write similar code for TOP5 below:
	ldi temphigh, high(TOP5)
	ldi templow, low(TOP5)
	sts OCR5AH, temphigh
	sts OCR5AL, templow

	ldi temp, 0
	sts TCCR5A, temp

	ldi temp, (1 << WGM52) | (1 << CS52) | (1 << CS50)
	sts TCCR5B, temp

	clr leds


main_loop:
check_timer_3:
	in temp, TIFR3
	sbrs temp, OCF3A
	rjmp check_timer_4

	; arrive here? Timer 3 reached its count
	;
	ldi temp, 1<<OCF3A ;clear bit 1 in TIFR3 by writing logical one to its bit position, P163 of the Datasheet
	out TIFR3, temp

	ldi temp, LED3 ;toggle bit 7 of portL
	eor leds, temp


check_timer_4:
;TO DO:
;Write similar code for TOP4 below:
	in temp, TIFR4
	sbrs temp, OCF4A
	rjmp check_timer_5

	ldi temp, 1<<OCF4A
	out TIFR4, temp

	ldi temp, LED4
	eor leds, temp
	rjmp check_timer_5

check_timer_5:
	in temp, TIFR5
	sbrs temp, OCF5A
	rjmp set_leds  ;<- jump to set led lights

	ldi temp, 1<<OCF5A
	out TIFR5, temp

	ldi temp, LED5
	eor leds, temp
	; arrive here? Timer 5 reached its count
	;
;TO DO:
;Write similar code for TOP5 below:

set_leds:
	sts S_PORTL, leds

skip_overflow:
	rjmp main_loop
	

stop:
	rjmp stop

