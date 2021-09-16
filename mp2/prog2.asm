;This is a postfix calculator
;that takes a postfix expression as given by the user and then calculates
;the corresponding result and displays it onto the screen in hexadecimal.
;If the expression is ivalid a message saying "invalid expression"
;is displayed on the screen. 
;When an operand is encountered, it is pushed onto the stack and when
;an operator is encountered, two values are popped from the stack and the equation is evaluated
;The result is then pushed onto the stack
;If an "=" sign is encountered and there is only one value in stack then, the equation is valid and result is displayed
;onto the screen.
.ORIG x3000

MAIN_LOOP	GETC				 
			OUT					; echos the input to screen
			JSR EVALUATE		
			BRnzp MAIN_LOOP		


CHECK 		LD R1, STACK_TOP	; We are checking if the stack is of size 1
			LD R2, STACK_START	; by subtracting STACK_START from STACK_TOP
			ADD R2, R2, #-1		; if STACK_TOP IS ONE ABOVE STACK_START then it is valid, if not then it is invalid
			NOT R1, R1			
			ADD R1, R1, #1
			ADD R1, R2, R1
			BRnp ISINVALID
			LDI R5, STACK_START	; loades R5 with the value in STACK_TOP which is same as STACK_START
			JSR PRINT_HEX		; print the answer stored in R5 in hex
			BRnzp DONE

ISINVALID 	LEA R0, INVALID 	; prints that the expression is invalid
			PUTS

DONE		HALT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R5-> Stores 4 count for 4 digits to be transferred
;R3-> Stores 4 count for 4 sets of 4 digit numbers in each hexadecimal number
;R2-> Stores first four digits of value and gets converted to the ascii value of the digit

PRINT_HEX	ST R7, HEX_SAVER7	; callee save R7
			AND R2,R2,#0
			AND R1,R1,#0
			ADD R1,R1,#4		;Load R1 with 4 as each 4 digits represent 1 number
			AND R3,R3,#0
			ADD R3,R3,#4		;Load R3 with 4 as there are 4 sets of 4 digit number
LOOP        ADD R5,R5,#0		;Check first digit of R1 by the logic that if the leading bit is one the number stored is negative
			BRzp #1
			ADD R2,R2,#1		;ADD 1 to R2 if R5 has leading bit as 1
			ADD R5,R5,R5		;Left Shift R5
			ADD R1,R1,#-1
			BRnz #2
			ADD R2,R2,R2		;LEFT SHIFT R2
			BRnzp LOOP
			ADD R1,R2,#-9		;Check if R2 is less than 9
			BRnz #3
			LD R4,AASCII		;ADD 'A' AND SUBTRACT 10 TO FIND ASCII CODE IF R2>9
			ADD R2,R2,#-10
			ADD R2,R2,R4
			ADD R1,R1,#0
			BRp #2
			LD R4,ZERO			;ADD '0' IF R2 IS LESS THAN 9 TO GET THE ASCII CODE
			ADD R2,R2,R4
			ADD R0,R2,#0
			OUT					;PRINT ASCII CODE
			AND R2,R2,#0
			AND R1,R1,#4
			ADD R3,R3,#-1
			BRp LOOP			;LOOP IF ALL 4 SETS OF DIGITS ARE NOT PRINTED YET
			RET                 ; Return to main user program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R0 - character input from keyboard
;R6 - current numerical output

EVALUATE 
		ST R7, EV_SAVER7		;callee save R7
		LD R1, NEG_EQUALTO		;if the typed char is '=', then branch to 'CHECK'
		ADD R1, R0, R1
		BRz CHECK

		LD R1, NEG_SPACE 		;if the typed char is space, then go to DONE_EV
		ADD R1, R0, R1 
		BRz DONE_EV

		LD R1, NEG_ADD			;if the typed char is +, then go to OPERATOR 
		ADD R1, R0, R1 
		BRz OPERATOR

		LD R1, NEG_MINUS 	    ;if the typed char is -, then go to OPERATOR 
		ADD R1, R0, R1 
		BRz OPERATOR 

		LD R1, NEG_MULT 		;if the typed char is *, then go to OPERATOR 
		ADD R1, R0, R1 
		BRz OPERATOR

		LD R1, NEG_DIV 			;if the typed char is /, then go to OPERATOR 
		ADD R1, R0, R1 
		BRz OPERATOR

		LD R1, NEG_EXP			;if the typed char is ^, then go to OPERATOR 
		ADD R1, R0, R1 
		BRz OPERATOR

		LD R1, NEG_NINE			;if the typed char is over #9, then go to ISINVALID
		ADD R1, R0, R1
		BRp ISINVALID

		LD R1, NEG_ZERO 		;if the typed char is under #0, then go to ISINVALID
		ADD R1, R0, R1
		BRn ISINVALID



OPERAND		
			LD R1, NEG_ZERO		;if the char typed is a number then push the number to stack
			ADD R0, R0, R1      ;Convert from ascii to its actual value by subtracting ascii zero
			JSR PUSH	
			BRnzp DONE_EV       


OPERATOR	ADD R2, R0, #0		;save the current char into R2 as R0 is going to be changed

			JSR POP				;pop the topmost values on stack and store in R3 and R4
			ADD R4, R0, #0
			JSR POP
			ADD R3, R0, #0
			ADD R5, R5, #0      ; Check for underflow and accordingly branch to ISINVALID
			BRp ISINVALID
			

				
			LD R1, NEG_ADD ;Check for '+'and accordingly branch to PLUS Subroutine	
			ADD R1, R2, R1;
			BRnp #1       
			JSR PLUS

			
			LD R1, NEG_MINUS ;Check for '-' and accordingly branch to MIN subroutine 
			ADD R1, R2, R1;
			BRnp #1
			JSR MIN

			
			LD R1, NEG_MULT ;Check for '*'and accordingly branch to MUL subroutine
			ADD R1, R2, R1;
			BRnp #1
			JSR MUL

			
			LD R1, NEG_DIV ;Check for '/'and accordingly branch to DIV subroutine
			ADD R1, R2, R1;
			BRnp #1
			JSR DIV
	
			LD R1, NEG_EXP ;Check for '^' and accordingly branch to EXP subroutine
			ADD R1, R2, R1;
			BRnp #1
			JSR EXP

			JSR PUSH			;After the calculated value from the subrotine is stored in R0, push it on to stack

DONE_EV		LD R7, EV_SAVER7	;Load R7 back to what it was before subroutone was initiated
			RET                 ; Return to main user program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0

	PLUS	ADD R0, R3, R4
			RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0

MIN			NOT R0, R4
			ADD R0, R0, #1
			ADD R0, R0, R3
			RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
;R3 is being used as a counter of the number of times to add R4
;R0 stores the final value

MUL			ST R3, MUL_SaveR3	;callee save R3
			AND R0, R0, #0

MULTIPLY 	ADD R0, R0, R4
			ADD R3, R3, #-1
			BRp MULTIPLY
			LD R3, MUL_SaveR3	;load R3 back to pre-subroutine value
			RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0

;R4 is subtracted from R3 till R3 becomes negative
;R0 stores the quotient


DIV		 	ST R3, DIV_SaveR3	;callee save R3
			ST R4, DIV_SaveR4	;callee save R4
			AND R0, R0, #0
			NOT R4, R4
			ADD R4, R4, #1

DIV_LOOP	ADD R3, R3, R4		;When R3-R4 becomes negative, division is done
			BRn #2
			ADD R0, R0, #1
			BRnzp DIV_LOOP
			LD R3, DIV_SaveR3	;load back R3 
			LD R4, DIV_SaveR4	;load back R4 
			RET
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0

;R2 is the counter of the number of times to multiply R3
;R0 is the final answer


EXP			ST R2, EXP_SaveR2	;callee save R2
			ST R3, EXP_SaveR3	;callee save R3
			ST R4, EXP_SaveR4	;callee save R3
			ST R7, EXP_SaveR7	;callee save R7
			AND R0, R0, #0		;clear R0
			ADD R2, R4, #0		;Copy the value of R4 to R2
			ADD R4, R3, #0		;Copy the value of R3 to R4
			ADD R2, R2, #-1		;if R2 is 1, then R0 = R3^1 = R3
			BRz EXP_1
			ADD R6, R2, #-1		;if R2 is 0, then R0 = 1
			BRn EXP_0			

EXP_LOOP 	JSR MUL				;go to the MUL subroutine
			ADD R4, R0, #0		;Copy Value of R0 to R4
			ADD R2, R2, #-1		;decrement counter
			BRp EXP_LOOP		
			BRnzp EXP_DONE			

EXP_1		ADD R0, R3, #0		;set R0 to R3, as R2 = 1
			BRnzp EXP_DONE

EXP_0		AND R0, R0, #0		
			ADD R0,R0,#1        ;set R0 to 1

EXP_DONE	LD R2, EXP_SaveR2	;load R2 back to pre-subroutine value
			LD R3, EXP_SaveR3	;load R3 back to pre-subroutine value
			LD R4, EXP_SaveR4	;load R4 back to pre-subroutine value
			LD R7, EXP_SaveR7	;load R7 back to pre-subroutine value
RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH	
	ST R3, PUSH_SaveR3	;save R3
	ST R4, PUSH_SaveR4	;save R4
	AND R5, R5, #0		;
	LD R3, STACK_END	;
	LD R4, STACk_TOP	;
	ADD R3, R3, #-1		;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz OVERFLOW		;stack is full
	STR R0, R4, #0		;no overflow, store value in the stack
	ADD R4, R4, #-1		;move top of the stack
	ST R4, STACK_TOP	;store top of stack pointer
	BRnzp DONE_PUSH		;
OVERFLOW
	ADD R5, R5, #1		;
DONE_PUSH
	LD R3, PUSH_SaveR3	;
	LD R4, PUSH_SaveR4	;
	RET


PUSH_SaveR3	.BLKW #1	;
PUSH_SaveR4	.BLKW #1	;


;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP	
	ST R3, POP_SaveR3	;save R3
	ST R4, POP_SaveR4	;save R3
	AND R5, R5, #0		;clear R5
	LD R3, STACK_START	;
	LD R4, STACK_TOP	;
	NOT R3, R3			;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz UNDERFLOW		;
	ADD R4, R4, #1		;
	LDR R0, R4, #0		;
	ST R4, STACK_TOP	;
	BRnzp DONE_POP		;
UNDERFLOW
	ADD R5, R5, #1		;
DONE_POP
	LD R3, POP_SaveR3	;
	LD R4, POP_SaveR4	;
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
POP_SaveR3	.BLKW #1	;
POP_SaveR4	.BLKW #1	;
EV_SAVER7	.BLKW #1
HEX_SAVER7	.BLKW #1
STACK_END	.FILL x3FF0	;
STACK_START	.FILL x4000	;
STACK_TOP	.FILL x4000	;


;Stores the additive inverse of the ascii values (easier to perform subtraction)
NEG_SPACE	.FILL xFFE0	;
NEG_EQUALTO	.FILL xFFC3	;
NEG_MULT	.FILL xFFD6	;
NEG_ADD		.FILL xFFD5	;
NEG_MINUS	.FILL xFFD3	;
NEG_DIV		.FILL xFFD1	;
NEG_EXP		.FILL xFFA2	;
NEG_ZERO	.FILL xFFD0	;
NEG_NINE	.FILL xFFC7 ;

AASCII  	.FILL x0041 ;Ascii for A
ABC     	.FILL x000C	;
ZERO        .FILL x0030 ;Ascii for 0

INVALID	.STRINGZ "Invalid Expression";

; reserve spaces in memory to store register values
MUL_SaveR3	.BLKW #1	;
DIV_SaveR3	.BLKW #1	;
DIV_SaveR4	.BLKW #1	;
EXP_SaveR2	.BLKW #1	;
EXP_SaveR3	.BLKW #1	;
EXP_SaveR4	.BLKW #1	;
EXP_SaveR7	.BLKW #1	;


.END
