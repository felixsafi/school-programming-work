; lab5.asm

.cseg

	;srcH:srcL=r1:r0 stores address of the source string
	;note the registers are used to pass the parameter to the subroutine
	.def srcH=r1
	.def srcL=r0 

	;stores the length of the string - return value of subroutine str_length
	;note register is used to store the returned value
	.def n=r17 

	.def temp=r18

	ldi temp, high(msg1<<1) ;get the high byte of the byte address of msg1 into register temp
	mov srcH, temp  ;store the high byte of the byte address of msg1 to register srcH
	ldi temp, low(msg1<<1) ;get the low byte of the byte address of msg1 into register temp
	mov srcL, temp ;store the low byte of the byte address of msg1 to register srcL

	call str_length

	mov r22,n  ; copy the counted value for checking

	sts LENGTH1, n ;returned value is stored at data memory LENGTH1	

	;Repeating for length of message 2
	ldi temp, high(msg2<<1) 
	mov srcH, temp 
	ldi temp, low(msg2<<1)
	mov srcL, temp

	call str_length

	mov r23,n   ; copy the counted value for checking

	sts LENGTH2, n

	;Repeating for message 3
	ldi temp, high(msg3<<1) 
	mov srcH, temp 
	ldi temp, low(msg3<<1) 
	mov srcL, temp

	call str_length

	mov r24,n   ; copy the counted value for checking

	sts LENGTH3, n

	done: rjmp done ; end program after message 3 checked


;-------------- subroutine ---------------------------------
	;**************Write your code here*****************
	;** implement subroutine str_length 
	;** calculate the number of characters in source string (pass-by-reference)
	;** parameter - srcH:srcL contains the memory address of the
	;** source string in flash memory 
	;** return - register n is used to store the returned value
	;** c-string format - last byte contains 0
str_length:
	mov r30, srcL ; store low byte in ZL(r30)
	mov r31, srcH ; store high byte in ZH(r31)
	clr r18 ; reset r18 to be used for counting

str_loop_find_length:
	lpm r19, Z+ ; get the next character and move Z forward 1
	tst r19 ; check to see if 0 reached (sets zero flag)
	breq str_end ; return if reached a 0
	inc r18 ; add one to count if havent yet reached 0
	rjmp str_loop_find_length ; repeat the loop fxn

str_end:
	mov r17, r18
	ret

;-------------- strings stored in program memory ------------------------
msg1: .db "Hello, world!", 0 ; c-string format 13 characters
;when you build this program, you will see a warning message:
;Warning		.cseg .db misalignment - padding zero byte
;to fix it, comment out the line below, and uncomment the line after that line.
;msg2: .db "", 0  ; c-string format 0 characters.
msg2: .db "", 0,0  ; c-string format 0 characters. Note '0' is added to pad the empty string as one word (two bytes)
                   ; because the program memory is word addressible.
msg3: .db "CSC 230 is fun!", 0 ; c-string format 15 charac$ters

;-------------- length of each string is stored in data memory ------------
.dseg
.org 0x200

LENGTH1: .byte 1$
LENGTH2: .byte 1
LENGTH3: .byte 1


