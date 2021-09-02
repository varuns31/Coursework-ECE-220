;
; The code given to you here implements the histogram calculation that 
; we developed in class.  In programming lab, we will add code that
; prints a number in hexadecimal to the monitor.(check)
;
; Your assignment for this program is to combine these two pieces of 
; code to print the histogram to the monitor.
;
; If you finish your program, 
;    ** commit a working version to your repository  **
;    ** (and make a note of the repository version)! **


	.ORIG	x3000		; starting address is x3000


;
; Count the occurrences of each letter (A to Z) in an ASCII string 
; terminated by a NUL character.  Lower case and upper case should 
; be counted together, and a count also kept of all non-alphabetic 
; characters (not counting the terminal NUL).
;
; The string starts at x4000.
;
; The resulting histogram (which will NOT be initialized in advance) 
; should be stored starting at x3F00, with the non-alphabetic count 
; at x3F00, and the count for each letter in x3F01 (A) through x3F1A (Z).
;
; table of register use in this part of the code
;    R0 holds a pointer to the histogram (x3F00)
;    R1 holds a pointer to the current position in the string
;       and as the loop count during histogram initialization
;    R2 holds the current character being counted
;       and is also used to point to the histogram entry
;    R3 holds the additive inverse of ASCII '@' (xFFC0)
;    R4 holds the difference between ASCII '@' and 'Z' (xFFE6)
;    R5 holds the difference between ASCII '@' and '`' (xFFE0)
;    R6 is used as a temporary register
;

	LD R0,HIST_ADDR      	; point R0 to the start of the histogram
	
	; fill the histogram with zeroes 
	AND R6,R6,#0		; put a zero into R6
	LD R1,NUM_BINS		; initialize loop count to 27
	ADD R2,R0,#0		; copy start of histogram into R2

	; loop to fill histogram starts here
HFLOOP	STR R6,R2,#0		; write a zero into histogram
	ADD R2,R2,#1		; point to next histogram entry
	ADD R1,R1,#-1		; decrement loop count
	BRp HFLOOP		; continue until loop count reaches zero

	; initialize R1, R3, R4, and R5 from memory
	LD R3,NEG_AT		; set R3 to additive inverse of ASCII '@'
	LD R4,AT_MIN_Z		; set R4 to difference between ASCII '@' and 'Z'
	LD R5,AT_MIN_BQ		; set R5 to difference between ASCII '@' and '`'
	LD R1,STR_START		; point R1 to start of string

	; the counting loop starts here
COUNTLOOP
	LDR R2,R1,#0		; read the next character from the string
	BRz PRINT_HIST		; found the end of the string

	ADD R2,R2,R3		; subtract '@' from the character
	BRp AT_LEAST_A		; branch if > '@', i.e., >= 'A'
NON_ALPHA
	LDR R6,R0,#0		; load the non-alpha count
	ADD R6,R6,#1		; add one to it
	STR R6,R0,#0		; store the new non-alpha count
	BRnzp GET_NEXT		; branch to end of conditional structure
AT_LEAST_A
	ADD R6,R2,R4		; compare with 'Z'
	BRp MORE_THAN_Z         ; branch if > 'Z'

; note that we no longer need the current character
; so we can reuse R2 for the pointer to the correct
; histogram entry for incrementing
ALPHA	ADD R2,R2,R0		; point to correct histogram entry
	LDR R6,R2,#0		; load the count
	ADD R6,R6,#1		; add one to it
	STR R6,R2,#0		; store the new count
	BRnzp GET_NEXT		; branch to end of conditional structure

; subtracting as below yields the original character minus '`'
MORE_THAN_Z
	ADD R2,R2,R5		; subtract '`' - '@' from the character
	BRnz NON_ALPHA		; if <= '`', i.e., < 'a', go increment non-alpha
	ADD R6,R2,R4		; compare with 'z'
	BRnz ALPHA		; if <= 'z', go increment alpha count
	BRnzp NON_ALPHA		; otherwise, go increment non-alpha

GET_NEXT
	ADD R1,R1,#1		; point to next character in string
	BRnzp COUNTLOOP		; go to start of counting loop
	



PRINT_HIST

; In this program i put a loop that prints out the first character and then
; Prints out space and finally prints the hexadecimal number which is the count for the particular character in the histogram 
;Finally I print out a newline and end the loop. The loop runs 27 times for each letter and once for special characters
;To print the hexadecimal number, I use another register to transfer the first four digits of the count by adding one to the register if the leading
;bit in the count is 1 and then left shifting both registers. I convert these digits to its ascii value and then print it out on the screen.
; R1-> Stores count of first histogram character
;R6-> Stores 27 Count for printing all characters
;R3-> Stores 4 count for 4 digits to be transferred
;R5-> Stores 4 count for 4 sets of 4 digit numbers in each hexadecimal number
;R2-> Stores first four digits of value and gets converted to the ascii value of the digit
; and provide sufficient comments
		LD R6,NUM_BINS				;Load R6 with 27
PRINT_CONT		LD R0,CHAR          ;Print out the character whose count is to be displayed
		TRAP x21
		LD R0,SPACE
		TRAP x21
		LD R0,CHAR
		ADD R0,R0,#1
		ST R0,CHAR		
		LDI R1,HIST_ADDR			;Stores Value of count of first character
		AND R2,R2,#0
		AND R3,R3,#0
		ADD R3,R3,#4				;Load R3 with 4 as each 4 digits represent 1 number
		AND R5,R5,#0
		ADD R5,R5,#4				;Load R5 with 4 as there are 4 sets of 4 digit number
LOOP            ADD R1,R1,#0		;Check first digit of R1 by the logic that if the leading bit is one the number stored is negative
		BRzp #1
		ADD R2,R2,#1				;ADD 1 to R2 if R1 has leading bit as 1
		ADD R1,R1,R1				;Left Shift R1
		ADD R3,R3,#-1
		BRnz #2
		ADD R2,R2,R2				;LEFT SHIFT R2
		BRnzp LOOP
		ADD R3,R2,#-9				;Check if R2 is less than 9
		BRnz #3
		LD R4,AASCII				;ADD 'A' AND SUBTRACT 10 TO FIND ASCII CODE IF R2>9
		ADD R2,R2,#-10
		ADD R2,R2,R4
		ADD R3,R3,#0
		BRp #2
		LD R4,ZERO					;ADD '0' IF R2 IS LESS THAN 9 TO GET THE ASCII CODE
		ADD R2,R2,R4
		ADD R0,R2,#0
		OUT							;PRINT ASCII CODE
		AND R2,R2,#0
		AND R3,R3,#0
		ADD R3,R3,#4
		ADD R5,R5,#-1
		BRp LOOP					;LOOP IF ALL 4 SETS OF DIGITS ARE NOT PRINTED YET
		LD R1,HIST_ADDR
		ADD R1,R1,#1		
		ST R1,HIST_ADDR				;Change address in hist_addr to point to count of next letter
		LD R0,NEW_LINE
		TRAP x21					;Print out new line
		ADD R6,R6,#-1				;Decrement Counter 
		BRp PRINT_CONT				;LOOP if all 27 lines are not printed yet

DONE	HALT						; done


; the data needed by the program
NUM_BINS	.FILL #27	; 27 loop iterations
NEG_AT		.FILL xFFC0	; the additive inverse of ASCII '@'
AT_MIN_Z	.FILL xFFE6	; the difference between ASCII '@' and 'Z'
AT_MIN_BQ	.FILL xFFE0	; the difference between ASCII '@' and '`'
HIST_ADDR	.FILL x3F00     ; histogram starting address
STR_START	.FILL x4000	; string starting address
AASCII  	.FILL x0041 ;Value of 'A'
CHAR        .FILL x0040 ;Value of @
SPACE       .FILL x0020 ;Value of Space
ZERO        .FILL x0030 ;Value of 0
NEW_LINE    .FILL x000A ;Value of Newline

; for testing, you can use the lines below to include the string in this
; program...
;STR_START	.FILL STRING	; string starting address
;STRING		.STRINGZ "This is a test of the counting frequency code.  AbCd...WxYz."
;STRING .STRINGZ "When I was young, I learned the sentence that people used to learn typing: \"The quick brown fox jumped over the lazy dog.\"  If you look carefully, or less than carefully at a correctly-produced histogram, you will notice that it contains all of the letters in the English language.  This aspect gives the sentence its value in teaching typing skills.  Can you type it, I wonder?"



	; the directive below tells the assembler that the program is done
	; (so do not write any code below it!)

	.END
