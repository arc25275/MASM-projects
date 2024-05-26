TITLE Project 1 (Proj1_clarka8.asm)

; Author: Alex Clark
; Last Modified: 04/16/2024
; OSU email address: clarka8@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number: 1 Due Date: 04/21/2024
; Description: A program that does simple math equations
; when developing assembly projects in CS271.

INCLUDE Irvine32.inc

.data
intro		    BYTE "Simple Math"," - ","Alex Clark ",0
instructions    BYTE "Enter 3 numbers, A,B,C, where each is smaller than the previous. (A > B > C). The sums and differences of the numbers will be returned.",0
promptA		    BYTE "Number A: ",0
promptB		    BYTE "Number B: ",0
promptC		    BYTE "Number C: ",0
plus			BYTE "+",0
minus			BYTE "-",0
equal			BYTE "=",0
numA			DWORD ?
numB			DWORD ?
numC			DWORD ?
sumAB			DWORD ?
diffAB			DWORD ?
sumAC			DWORD ?
diffAC			DWORD ?
sumBC			DWORD ?
diffBC			DWORD ?
sumABC			DWORD ?
goodbye		    BYTE "Thank you for using my program!",0




.code
main PROC

; Intro Text
	mov	    EDX,OFFSET intro
	call    WriteString
	call    CrLf

; Prompt
	mov		EDX,OFFSET instructions
	call	WriteString
	call	CrLf

	; Get A
	mov		EDX,OFFSET promptA
	call	WriteString
	call	ReadDec
	mov		numA,EAX

	; Get B
	mov		EDX,OFFSET promptB
	call	WriteString
	call	ReadDec
	mov		numB,EAX

	; Get C
	mov		EDX,OFFSET promptC
	call	WriteString
	call	ReadDec
	mov		numC,EAX

; Calculate Sum and Differences
	; A + B
  	mov		EAX, numA
	add		EAX, numB
	mov		sumAB, EAX

	; A - B
	mov		EAX, numA
	sub		EAX, numB
	mov		diffAB, EAX

	; A + C
	mov		EAX, numA
	add		EAX, numC
	MOV		sumAC, EAX

	; A - C
	mov		EAX, numA
	sub		EAX, numC
	mov		diffAC, EAX

	; B + C
	mov		EAX, numB
	add		EAX, numC
	mov		sumBC, EAX

	; B - C
	mov		EAX, numB
	sub		EAX, numC
	mov		diffBC, EAX

	; A + B + C
	mov		EAX, numA
	add		EAX, numB
	add		EAX, numC
	mov		sumABC, EAX


; Display Results

	; A + B
	mov	    EAX, numA
	call    WriteDec
	mov	    EDX, OFFSET plus
	call    WriteString
	mov	    EAX, numB
	call    WriteDec
	mov	    EDX, OFFSET equal
	call    WriteString
	mov	    EAX, sumAB
	call    WriteDec
	call	CrLf

	; A - B
	mov	    EAX, numA
	call    WriteDec
	mov	    EDX, OFFSET minus
	call    WriteString
	mov	    EAX, numB
	call    WriteDec
	mov	    EDX, OFFSET equal
	call    WriteString
	mov	    EAX, diffAB
	call    WriteDec
	call	CrLf

	; A + C
	mov	    EAX, numA
	call    WriteDec
	mov	    EDX, OFFSET plus
	call    WriteString
	mov	    EAX, numC
	call    WriteDec
	mov	    EDX, OFFSET equal
	call    WriteString
	mov	    EAX, sumAC
	call    WriteDec
	call	CrLf

	; A - C
	mov	    EAX, numA
	call    WriteDec
	mov	    EDX, OFFSET minus
	call    WriteString
	mov	    EAX, numC
	call    WriteDec
	mov	    EDX, OFFSET equal
	call    WriteString
	mov	    EAX, diffAC
	call    WriteDec
	call	CrLf

	; B + C
	mov	    EAX, numB
	call    WriteDec
	mov	    EDX, OFFSET plus
	call    WriteString
	mov	    EAX, numC
	call    WriteDec
	mov	    EDX, OFFSET equal
	call    WriteString
	mov	    EAX, sumBC
	call    WriteDec
	call	CrLf

	; B - C
	mov	    EAX, numB
	call    WriteDec
	mov	    EDX, OFFSET minus
	call    WriteString
	mov	    EAX, numC
	call    WriteDec
	mov	    EDX, OFFSET equal
	call    WriteString
	mov	    EAX, diffBC
	call    WriteDec
	call	CrLf

	; A + B + C
	mov	    EAX, numA
	call    WriteDec
	mov	    EDX, OFFSET plus
	call    WriteString
	mov	    EAX, numB
	call    WriteDec
	call	WriteString
	mov	    EAX, numC
	call    WriteDec
	mov	    EDX, OFFSET equal
	call    WriteString
	mov	    EAX, sumABC
	call    WriteDec
	call	CrLf
; Ending
	mov	    EDX, OFFSET goodbye
	call    WriteString
	call    CrLf

	Invoke ExitProcess,0 ; exit to operating system
main ENDP

; (insert additional procedures here)

END main
