;
; lab6.asm
;
.include "m2560def.inc" ; imports definitions to be used
;SPH, SPL etc are defined in "m2560def.inc"

	
.cseg
	
	; initialize the stack pointer 
	; to the address 0x21FF - the top of SRAM
	; The stack will grow downward from here
	ldi r16, 0xFF 
	out SPL, r16
	ldi r16, 0x21
	out SPH, r16
	
	;example of passing parameter by reference	
	;call subroutine void strcpy(src, dest)
	;push 1st parameter - src address
	ldi r16, high(src << 1) ; since src is in program memory, use <<1 (word-addressed)
	push r16 ;push the value to the stack
	ldi r16, low(src <<1)
	push r16

	;push 2nd parameter - dest address
	ldi r16, high(dest) ; RAM address is byte addressed so no (<<1) needed
	push r16
	ldi r16, low(dest)
	push r16

	call strcpy ; call auto pushes 3 bytes for the return address to the stack
	pop ZL ; Pop the destination address
	pop ZH 
	pop r16 ; R16 used as scratch to clear ret address from stack
	pop r16

	;Write your code here: call subroutine int strlen(string dest)
	;string dest is stored in SRAM, not flash memory
	;return value is in r24
	;push parameter dest, note it is in register Z already (line 31, 32)
	
	
	;Write your code here: call the method strLength
	
	;clear the stack and write the result to length in SRAM
	;Write your code here:
	

done: jmp done

strcpy:
	push r30
	push r31
	push r29
	push r28
	push r26
	push r27
	push r23 ; hold each character read from program memory
	IN YH, SPH ;SP in Y
	IN YL, SPL
	ldd ZH, Y + 14 ; Z <- src address
	ldd ZL, Y + 13
	ldd XH, Y + 12 ; Y <- dest address
	ldd XL, Y + 11

next_char:
	lpm r23, Z+
	st X+, r23
	tst r23
	brne next_char
	pop r23
	pop r27
	pop r26
	pop r28
	pop r29
	pop r31
	pop r30
	ret
	
;One parameter - the address of the string, could be in 
;flash or SRAM (chose one). The length of the string is
;going to be stored in r24
strlength:
	;write your code here
	
	
	ret

src: .db "Hello, world!", 0 ; c-string format

.dseg
.org 0x200
dest: .byte 14
length: .byte 1
