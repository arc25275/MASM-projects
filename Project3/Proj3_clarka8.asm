TITLE Proj3_clarka8     (Proj3_clarka8.asm)

; Author: Alex Clark
; Last Modified: 04/28/2024
; OSU email address: clarka8@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 3   Due Date: 05/05/2024
; Description: A program that involves validating input,
; and calculates stats about sets of numbers given within a range

INCLUDE Irvine32.inc

; Constants

MIN_LOW  = -200
MAX_LOW  = -100
MIN_HIGH = -50
MAX_HIGH = -1


; I ended up trying these out after I thought I would be able to do it with EQU (Or something similar), and finding out that I could not. 
; If this is not allowed, let me know and I can remove it, but I thought it would be interesting to try out.

; ----------------------------------
; Name: mPrintStr
;
; Print a string that is inputted
;
; Receives:
; stringVar = String / Byte Array
; ----------------------------------
mPrintStr MACRO stringVar:REQ
    mov edx, OFFSET stringVar
    call WriteString
ENDM 

; ----------------------------------
; Name: mPrintInt
;
; Print a int that is inputted
;
; Receives:
; intVar = Signed Integer
; ----------------------------------
mPrintInt MACRO intVar:REQ
	mov eax, intVar
	call WriteInt
ENDM



.data

greeting		BYTE	"Integer Statistics - Alex Clark",0
summary			BYTE	"This program will take your input of numbers within the ranges provided, and when done, give statistics about the numbers, including the count, sum, maximum, minimum, and average.",0
extraCredit1	BYTE	"**EC: Numbered Input Lines",0
extraCredit2	BYTE	"**EC: Added Decimal Point to average",0

usernamePrompt	BYTE	"What is your name? ",0
username		BYTE	33 DUP(0), 0
userGreeting1   BYTE	"Hello ",0
userGreeting2	BYTE	", thank you for using my program!",0

instructions1   BYTE	"Enter numbers in the range of (",0
instructions2   BYTE	", ",0
instructions3	BYTE	") or (",0
instructions4	BYTE	").",0
howToStop		BYTE	"Enter a non-negative number when you have entered all of the numbers you want.",0

inputCount		DWORD	1			; Wanted count to start from 1
prompt			BYTE	" - Enter a number: ",0

count			DWORD	0
max				SDWORD	MIN_LOW-1	;Ensures max and min values are always accurate
min				SDWORD	MAX_HIGH+1	;When set to ? it would default to zero, which would not work for the comparisons of max, as it would always be the max
sum				SDWORD	0
avg				SDWORD	0
avgDecimal		DWORD	0

errorMsg		BYTE	"Number entered is not in the correct range. Please try again.",0

noInputMsg		BYTE	"Error: No numbers entered",0

countMsg		BYTE	"Amount of numbers entered: ",0
minMsg			BYTE	"Minimum number entered: ",0
maxMsg			BYTE	"Maximum number entered: ",0
sumMsg			BYTE	"Sum of all numbers entered: ",0
avgMsg			BYTE	"Rounded Average of all numbers entered: ",0
goodbye			BYTE	"Goodbye, and I hope you enjoyed! Thank you, ",0


.code
main PROC

	; Greeting 
	mPrintStr	greeting
	CALL		CrLf
	mPrintStr	summary
	CALL		CrLf
	mPrintStr	extraCredit1
	CALL		CrLf
	mPrintStr	extraCredit2
	CALL		CrLf
	; Getting Username
	mPrintStr	usernamePrompt

	MOV			EDX, OFFSET username
	MOV			ECX, SIZEOF username
	CALL		ReadString
	mPrintStr	userGreeting1
	mPrintStr	username
	mPrintStr	userGreeting2
	CALL		CrLf
	
	; Instructions
	mPrintStr	instructions1
	mPrintInt	MIN_LOW
	mPrintStr	instructions2
	mPrintInt	MAX_LOW
	mPrintStr	instructions3
	mPrintInt	MIN_HIGH
	mPrintStr	instructions2
	mPrintInt	MAX_HIGH
	mPrintStr	instructions4
	CALL		CrLf
	mPrintStr	howToStop
	CALL		CrLf

; ---------------------------------------------------------------------------------;
; This section will ask the user for numbers until they send something non-negative;
; If the number is not in the range, it will give an error and ask again           ;
; ---------------------------------------------------------------------------------;

	; Get inputs
_InputNums:
	MOV			EAX, inputCount
	CALL		WriteDec
	mPrintStr	prompt
	CALL		ReadInt
	CMP			EAX,-1
	JG			_NonNeg
	; Check if in low range
	CMP     EAX, MIN_LOW
	JL      _Error
	CMP     EAX, MAX_LOW
	JLE      _Math			; If the number is greater than the min, and is less than the max, 
	CMP     EAX, MIN_HIGH	; then it means that it is within the lower bounds, and the upper does not need to be checked
	JL      _Error			; Otherwise, the upper bounds is checked as well
	CMP     EAX, MAX_HIGH
	JG      _Error
	
_Math:
	; Math During input (Max, Min, Count, Sum)
	ADD			sum, EAX 
	INC			count
	; Check max and min. Something can be both max and min if it is the first number
	CMP			EAX, max
	JL			_NotMax
	MOV			max, EAX
_NotMax:
	CMP			EAX, min
	JG			_NotMin
	MOV			min, EAX
_NotMin:
	INC			inputCount
	JMP			_InputNums


_Error:
	mPrintStr	errorMsg
	CALL		CrLf
	JMP			_InputNums



	; Math After input (Avg, and its decimal)
_NonNeg:
	MOV			EAX, sum
	CMP			EAX, 0
	JNE			_NonEmpty	; If no numbers were entered, set max and min back to zero (Explanation in variable defs)
	mPrintStr	noInputMsg
	Call		CrLf
	JMP			_Goodbye
_NonEmpty:
	MOV			EBX, count
	CDQ
	IDIV		EBX
	MOV			avg, EAX	; Get avg
	CMP			EDX,0		; If there is a remainer, need to check what decimal value is
	JE			_Summary	
	MOV			EAX, EDX 
	MOV			EBX, -100	; Multiply remainer by 100, then divide by count again to get decimal value as integer 
	MUL			EBX			; (eg. 6/4 = 1 R=2, so 2*100/4 = 50, or .5)
	MOV			EBX, count
	CDQ
	IDIV		EBX
	MOV			avgDecimal, EAX


_Summary:
	; Summary
	mPrintStr	countMsg
	MOV			EAX, count
	CALL		WriteDec
	CALL		CrLf
	mPrintStr	minMsg
	mPrintInt	min
	CALL		CrLf
	mPrintStr	maxMsg
	mPrintInt	max
	CALL		CrLf
	mPrintStr	sumMsg
	mPrintInt	sum
	CALL		CrLf
	mPrintStr	avgMsg
	mPrintInt	avg
	MOV			AL, '.'
	CALL		WriteChar
	MOV			EAX, avgDecimal
	CALL		WriteDec
	CALL		CrLf

_Goodbye:
	; Goodbye
	mPrintStr	goodbye
	mPrintStr	username


	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
