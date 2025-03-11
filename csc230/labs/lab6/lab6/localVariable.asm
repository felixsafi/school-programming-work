;
; localVariable.asm
; - passing parameter by r20 (n)
; - result is stored in r25:r24 (resultH:resultL)
; 
; An example to illustrate storing local variables on
; the stack.
;
.def tempL=r16
.def tempH=r17
.def n=r20 ;parameter for subroutine factorial(n)
.def resultL=r24 ;store low byte of the 16-bit returned value
.def resultH=r25 ;store high byte of the 16-bit returned value

.include "m2560def.inc"
;in file "m2560def.inc", SPL/H defined as following
; ****    .equ	SPL	= 0x3d
; ****    .equ	SPH	= 0x3e
; therefore, must use IN/OUT for read and store

		; initialize the stack pointer to 0x21FF

		ldi tempL, low(RAMEND)
		out SPL, tempL
		ldi tempL, high(RAMEND)
		out SPH, tempL

		;call factorial(4), n=4
		ldi n, 5
		push n
		call factorial
		pop n

done: rjmp done

;stack frame
; | n    |  parameter a (Y + 11)
; | ret  |  return address
; | ret  |  return address
; | ret  |  return address
; | YH   |  saved register
; | YL   |  saved register <- Y is going to store SP
; | n    |  saved register
; | tempH|  saved register
; | tempL|  saved register
; | locH | reserved byte to store high byte of a number (Y + 2)
; | locL | reserved byte to store low byte of a number  (Y + 1)
; |      | <- Y and SP
;
factorial:
		push YH
		push YL
		push n
		push tempH
		push tempL

		in YL, SPL
		in YH, SPH

		; Reserve 2 bytes to store a 16-bit local variable
		sbiw YH:YL, 2

		; Should turn interrupts off to make the follwing 
		; executions atomic (not interrupted, why?)
		; More later when we learn interrupts
		in tempL, SREG

		;disable interrupt so that SP is saved in Y as an atomic action, Why? If interrupt occurs after saving SPL to YL, the
		;SP maybe changed, when the program resumes after the interrupt, the SPH is no longer the SPH before
		;the interrupt, then the return address stored in Y is not right.
		cli 
		out SPL, YL ;establish new top of stack
		out SPH, YH
		out SREG, tempL ;restore previous status register

		; Should turn interrupts on here, learn more later
		sei

		; get n
		ldd n, Y+11

		; check n for the base case here, branch to factorial_base_case if n<2
		cpi n, 2
		brlo factorial_base_case ; if n<2, return 1
		
		; call factorial(n-1)
		;Write your code here:
		

		;since n has the value of n-1, but we need to do n * factorial(n-1), so increment n to restore its value
		inc n
		; 
		; get factorial(n-1), the returned value is stored in r25:r24 (resultH:resultL)
		; but we need to make r25:r24 available to store n * factorial(n-1)
		; therefore, store the returned value from factorial(n-1) on the stack, local variable area: locH:locL
		std y+1, resultL
		std y+2, resultH

		; the 16-bit local variable contains the returned value of factorial(n-1)
		; now load local variable to tempH:tempL, do n * factorial(n-1) 
		; store the result to resultH:resultL
		; note n is 8-bit, but factorial(n-1) might be 16-bit, therefore, cannot use MUL (multiply Unsigned)
		;Write your code here:
;multiply_loop: ; n * factorial(n-1)= add factorial(n-1) n times 
		;Write your code here:
		;rjmp multiply_loop

factorial_base_case:
		clr resultH
		ldi resultL, 1
		
factorial_epilogue:
		in tempL, SREG
		adiw YH:YL, 2
		; turn interrupt off, more later.
		cli
		out SPL, YL
		out SPH, YH
		out SREG, tempL
		sei
		pop tempL
		pop tempH
		pop n
		pop YL
		pop YH
		ret
