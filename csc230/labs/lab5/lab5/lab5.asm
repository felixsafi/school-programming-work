;
; lab5.asm
; Summer, 2022
; Author : vli
;

; Replace with your application code
;
.cseg

	;give symbolic names to registers
	
	;int str_length(String src) in Java

	;address of the source string as a parameter to subroutine str_length
	;srcH:srcL=r1:r0 stores address of the source string
	;note the registers are used to pass the parameter to the subroutine
	.def srcH=r1
	.def srcL=r0 
	 
	;stores the length of the string - return value of subroutine str_length
	;note register is used to store the returned value
	.def n=r17 

	.def temp=r18

	;------equivalent to method call in Java: int n=str_length(msg1);
	;note parameter msg1 is passed through register pair r1:r0 - srcH:srcL
	;returned value is stored in register n - r17, then saved in memory LENGTH1 - 0x0200

	;address of the source string msg1 is loaded to srcH:srcL - parameter

	;Note msg1 is stored in the flash memory (program memory)
	;why msg1<<1? Because the program memory is word addressible, but we
	;need to load one byte at a time, that is, we need to know the byte address. Recall
	;one word is 2 bytes, therefore, word_address * 2 = byte_address, recall
	;in decimal 1.2 * 10 is equivalent to shift the number leftward by one digit,
	;so, 12 is the result. for the same reason, in binary, 0b01 * 2 is equivalent
	;to shift the number leftward by one digit.
	ldi temp, high(msg1<<1) ;get the high byte of the byte address of msg1 into register temp
	mov srcH, temp  ;store the high byte of the byte address of msg1 to register srcH
	ldi temp, low(msg1<<1) ;get the low byte of the byte address of msg1 into register temp
	mov srcL, temp ;store the low byte of the byte address of msg1 to register srcL

	call str_length

	sts LENGTH1, n ;returned value is stored at data memory LENGTH1
	
	;------equivalent to method call in Java: int n=str_length(msg2);
	;note parameter msg2 is passed through register pair r1:r0 - srcH:srcL
	;returned value is stored in register n - r17, then saved in memory LENGTH2 - 0x0201

	;address of the source string msg2 is loaded to srcH:srcL - parameter

	;**************Write your code here*****************
	;** use the example above, call the subroutine str_length again
	;** to get the length of msg2
	;** parameter - address of the source string msg2 is loaded to srcH:srcL
	;** return - register n is used to store the returned value
	;** store the value in register n to data memory at LENGTH2

	;------equivalent to method call in Java: int n=str_length(msg3);
	;note parameter msg3 is passed through register pair r1:r0 - srcH:srcL
	;returned value is stored in register n - r17, then saved in memory LENGTH3 - 0x0202


	;**************Write your code here*****************
	;** use the example above, call the subroutine str_length again
	;** to get the length of msg3
	;** parameter - address of the source string msg3 is loaded to srcH:srcL
	;** return - register n is used to store the returned value
	;** store the value in register n to data memory at LENGTH3

	done: rjmp done


;-------------- subroutine ---------------------------------
	;**************Write your code here*****************
	;** implement subroutine str_length 
	;** calculate the number of characters in source string (pass-by-reference)
	;** parameter - srcH:srcL contains the memory address of the
	;** source string in flash memory 
	;** return - register n is used to store the returned value
	;** c-string format - last byte contains 0
str_length:


ret

;-------------- strings stored in program memory ------------------------
msg1: .db "Hello, world!", 0 ; c-string format 13 characters
;when you build this program, you will see a warning message:
;Warning		.cseg .db misalignment - padding zero byte
;to fix it, comment out the line below, and uncomment the line after that line.
;msg2: .db "", 0  ; c-string format 0 characters.
msg2: .db "", 0,0  ; c-string format 0 characters. Note '0' is added to pad the empty string as one word (two bytes)
                   ; because the program memory is word addressible.
msg3: .db "CSC 230 is fun!", 0 ; c-string format 15 characters

;-------------- length of each string is stored in data memory ------------
.dseg
.org 0x200

LENGTH1: .byte 1
LENGTH2: .byte 1
LENGTH3: .byte 1


