TITLE Project 4     (Proj4_clarka8.asm)

; Author: Alex Clark
; Last Modified: 05/18/2024
; OSU email address: clarka8@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 4   Due Date: 05/19/2024
; Description: A program that returns n primes depending on what the user decides

INCLUDE Irvine32.inc
; Macros

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
; Name: mPrintDec
;
; Print a int that is inputted
;
; Receives:
; decVar = Unsigned Integer
; ----------------------------------
mPrintDec MACRO decVar:REQ
	mov eax, decVar
	call WriteDec
ENDM

; Constants
MIN = 1
MAX = 200
.data

; Intro Variables
titleAndName	BYTE	"N primes - Alex Clark",0
description		BYTE	"This program will return n primes, which has to be between ",0
andStr			BYTE	" and ",0
; getUserData Variables
prompt			BYTE	"Enter a number within the bounds: ",0
userInput		DWORD	?
errorStr		BYTE	"Invalid input. Please try another number.",0
; showPrimes Variables
lineCount		DWORD	?
primeCount		DWORD	0
primesNeeded	DWORD	0
currentNum		DWORD	3
space			BYTE	" ",0
; IsPrime Variables
isPrimeNum		DWORD	?
primeIter		DWORD	?
; Farewell Variables
farewellStr		BYTE	"Thank you for using my program!", 0



.code
main PROC

	call	introduction
	call	getUserData
	call	showPrimes
	call	farewell

	Invoke	ExitProcess,0	; exit to operating system
main ENDP

; Other Procedures

; ---------------------------------------------------------------------------------------------
; Name: introduction
;
; Displays a welcome message, explaining the name of the program and what the input should be.
; ---------------------------------------------------------------------------------------------
introduction PROC
	mPrintStr	titleAndName
	call		CrLf
	mPrintStr	description
	mPrintDec	MIN
	mPrintStr	andStr
	mPrintDec	MAX
	call		CrLf
	RET
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: getUserData
;
; Get the amount of primes that the user wants printed
;
;
; Returns:
;		eax		= number of primes
; ---------------------------------------------------------------------------------
getUserData PROC
_RetryInput:
	mPrintStr	prompt
	call		ReadDec
	mov			userInput, eax
	call		validate
	cmp			eax,0
	jnz			_End
	mPrintStr	errorStr
	call		CrLf
	jmp			_RetryInput
_End:
	mov			eax, userInput
	RET
getUserData ENDP

; ------------------------------------
; Name: validate
;
; Makes sure that data input is valid
;
; Receives: 
;		eax		= Input
;
; Returns:
;		eax		= Boolean (0 or 1)
; ------------------------------------
validate PROC
	cmp			eax, MIN
	jl			_Invalid
	cmp			eax, MAX
	jg			_Invalid
	jmp			_Valid
_Invalid:
	mov			eax, 0
	jmp			_End
_Valid:
	mov			eax, 1
_End:
	RET
validate ENDP

; -------------------------------------------------------
; Name: showPrimes
;
; This recieves n, and will write that amount of primes.
;
; Preconditions: The number is between 1 and 200
;
; Receives: 
;		eax		= Number of primes
;
; -------------------------------------------------------
showPrimes PROC
	push		edx
	mov			primesNeeded, eax
_SearchPrimes:
	; Iterate through numbers and check if they are prime
	mov			eax, currentNum
	call		isPrime
	cmp			eax,1
	jz			_PrintPrime
	; If Prime, print it out according to spec
_FinishLoop:
	; Increment the current number, and check if all of the requested primes have been found yet
	inc			currentNum
	mov			edx, primeCount
	cmp			primesNeeded, edx
	jnz			_SearchPrimes
	jmp			_FoundAll
_PrintPrime:
	; Need to make sure there are 10 per line
	inc			primeCount
	cmp			lineCount, 10
	jl			_NoNewline
	call		CrLf
	mov			lineCount, 0
_NoNewline:
	inc			lineCount
	mPrintDec	currentNum
	mPrintStr	space
	jmp			_FinishLoop
_FoundAll:
	call		CrLf
	pop			edx
	RET
showPrimes ENDP

; ---------------------------------------------------------------------------------
; Name: isPrime
;
; This recieves a number, and returns 1 if it is a prime, and 0 if it is not.
;
; Preconditions: The number is unsigned
;
; Receives: 
;		eax		= Number to determine if prime
;
; Returns:
;		eax		= Boolean (0 or 1)
; ---------------------------------------------------------------------------------
isPrime PROC
	; Save registers used
	push	ecx
	push	edx
	push	ebx
	; Initialize variables, start count
	mov		isPrimeNum, eax
	mov		primeIter, 2
	mov		ecx, eax
	sub		ecx, 2
_PrimeLoop:
	; Divide n/i
	mov		eax, isPrimeNum
	mov		edx, 0
	mov		ebx, primeIter
	div		ebx
	cmp		edx, 0
	; If there is no remainer, it divided equally and is not a prime.
	je		_NoPrime
	inc		primeIter
	; Else, continue loop
	loop	_PrimeLoop
	jmp		_YesPrime
_NoPrime:
	mov		eax, 0
	jmp		_EndPrime
_YesPrime:
	mov		eax, 1
_EndPrime:
	pop		ebx
	pop		edx
	pop		ecx
	RET
isPrime ENDP

; ------------------------------
; Name: farewell
;
; Displays a goodbye message.
; ------------------------------
farewell PROC
	mPrintStr	farewellStr
	call		CrLf
	RET
farewell ENDP

END main