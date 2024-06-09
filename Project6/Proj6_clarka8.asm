TITLE Project 6    (Proj6_clarka8.asm)

; Author: Alex Clark
; Last Modified: 06/06/2024
; OSU email address: clarka8@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6   Due Date: 06/09/2024
; Description: Working with strings and macros.

INCLUDE Irvine32.inc

; Macros

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Display a prompt, and then get the users input and put it into a memory location.
;
; Preconditions: None
;
; Receives:
;	prompt (Reference) = Prompt to display before reading input 
;	inCount (Value) = Max length string that can be read to the string 
;
; Returns:
;	output (Reference) = String that is read from console 
;	outCount (Reference) = Length of string outputted 
; ---------------------------------------------------------------------------------
mGetString MACRO prompt:REQ, output:REQ, inCount:REQ, outCount:REQ
	PUSH			EDX
	PUSH			ECX
	PUSH			EAX
	mDisplayString	prompt
	MOV				EDX, output
	MOV				ECX, inCount
	CALL			ReadString
	MOV				[outCount], EAX
	POP				EAX
	POP				ECX
	POP				EDX
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Display a string from a memory location.
;
; Preconditions: None
;
; Receives:
;	string (Reference) = String to display
; ---------------------------------------------------------------------------------
mDisplayString MACRO string:REQ
	PUSH	EDX
    MOV		EDX, string
    CALL	WriteString
	POP		EDX
ENDM

; Constants

INPUT_LEN = 10
FINAL_LEN = 11
NUMS = 10

MAX_ASCII = 57
MIN_ASCII = 48
NEGATIVE = 45
POSITIVE = 43

.data

intro		BYTE	"Strings and Macros - Alex Clark",0
desc1		BYTE	"Input 3 signed integers that can fit within a 32 bit register.",0
desc2		BYTE	"After inputting them, they will be displayed, along with their sum and average.",0

numArray	SDWORD	NUMS DUP(0)

inputPrompt	BYTE	"Enter a negative or positive number with 8 or less digits: ",0
negError	BYTE	"Negative symbol must be the first character in your input.",0
posError	BYTE	"Positive symbol must be the first character in your input.",0
asciiError	BYTE	"Invalid character used when typing Signed Int.",0
emptyError	BYTE	"Input was empty, please try again.",0

showNums	BYTE	"The following numbers were entered: ",0
space		BYTE	" ",0

sum			SDWORD	0
showSum		BYTE	"The sum of the numbers entered is: ",0

showAvg		BYTE	"The average of the numbers entered is: ",0

.code
main PROC
; Intro
	mDisplayString	OFFSET intro
	CALL			CrLf
	CALL			CrLf
	mDisplayString	OFFSET desc1
	CALL			CrLf
	mDisplayString	OFFSET desc2
	CALL			CrLf
	CALL			CrLf
; Get Array of user inputted numbers
	MOV				EDI, OFFSET numArray
	MOV				ECX, NUMS
_inputLoop:
	PUSH			EDI
	PUSH			OFFSET emptyError
	PUSH			OFFSET asciiError
	PUSH			OFFSET posError
	PUSH			OFFSET negError
	PUSH			OFFSET inputPrompt
	CALL			ReadVal
	ADD				EDI,4
	LOOP			_inputLoop

; Display numbers
	mDisplayString	OFFSET showNums
	MOV				ECX, NUMS
	MOV				EDI, OFFSET numArray
_displayLoop:
	PUSH			[EDI]
	CALL			WriteVal
	mDisplayString	OFFSET space
	ADD				EDI, 4
	LOOP			_displayLoop
	CALL			CrLf
	CALL			CrLf
; Calculate and display sum
	mDisplayString	OFFSET showSum
	MOV				ECX, NUMS
	MOV				EDI, OFFSET numArray
_sumLoop:
	MOV				EAX, sum
	ADD				EAX, [EDI]
	MOV				sum, EAX
	ADD				EDI, 4
	LOOP			_sumLoop

	PUSH			sum
	CALL			WriteVal
	CALL			CrLf

; Calculate and display average
	mDisplayString	OFFSET showAvg
	MOV				EAX, sum
	CDQ
	MOV				EBX, NUMS
	IDIV			EBX
	PUSH			EAX
	CALL			WriteVal
	CALL			CrLf



	Invoke ExitProcess,0	; exit to operating system
main ENDP

; Procedures

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Read an inputted number as a string, validate it, and store it as an SDWORD.
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;	[EBP+8] = prompt (Reference) - Prompt to be shown to the user
;	[EBP+12] = negError (Reference) - Error to be shown if there is a negative symbol in the wrong place.
;	[EBP+16] = posError	(Reference) - Error to be shown if there is a plus symbol in the wrong place.
;	[EBP+20] = asciiError (Reference) - Error to be shown if there are invalid characters.
;	[EBP+24] = emptyError (Reference) - Error to be shown if nothing is typed.
;		
;
; Returns:
;	[EBP+28] = validatedInput (Reference) - The user input once it has been checked and converted.
; ---------------------------------------------------------------------------------
ReadVal PROC USES EAX EDI ECX ESI EBX
	LOCAL		promptPtr:DWORD

	LOCAL		stringInput[INPUT_LEN]:BYTE
	LOCAL		inputPtr:DWORD

	LOCAL		strLen:DWORD
	LOCAL		strLenPtr:DWORD

	LOCAL		total:SDWORD
	LOCAL		makeNeg:BYTE
	

_startTI:
	; Initialize Variables
	MOV			makeNeg,0
	MOV			strLen, 0
	MOV			total, 0
	MOV			EAX, [EBP+8]		; Transfer address of prompt to promptPtr variable
	MOV			promptPtr, EAX
	
	; Local variables cannot use OFFSET, 
	; so you have to use LEA to move the memory address and then move it to a variable.
	LEA			EAX, stringInput	
	MOV			inputPtr, EAX

	LEA			EAX, strLen
	MOV			strLenPtr, EAX

	; Get user input after prompt.
	mGetString	promptPtr, inputPtr, INPUT_LEN, strLen
	
	; Convert ASCII to SDWORD

	MOV			ECX,strLen
	MOV			ESI,inputPtr

_TILoop:
	CLD
	LODSB
	; Check if char is not a number, and if + or -, handle correctly.
	CMP			AL, NEGATIVE
	JE			_TINegative
	CMP			AL, POSITIVE
	JE			_TIPositive
	CMP			AL,0
	JE			_ErrorEmpty
	CMP			AL,MAX_ASCII
	JG			_ErrorAscii
	CMP			AL,MIN_ASCII
	JL			_ErrorAscii
	; Convert from ASCII to number
	SUB			AL,48

	PUSH		EAX
	; Multiply by 10 to clear up ones place
	IMUL		EAX, total, 10
	MOV			total, EAX
	POP			EAX
	; Add new number to the right hand side
	MOVSX		EBX, AL
	ADD			total, EBX


_endTILoop:
	LOOP		_TILoop

	JMP			_endTI

_TINegative:
	; If not first char, error
	CMP			ECX,strLen
	JNZ			_ErrorNeg
	MOV			makeNeg, 1
	JMP			_endTILoop

_TIPositive:
		; If not first char, error
	CMP			ECX,strLen
	JNZ			_ErrorPos
	JMP			_endTILoop


_ErrorNeg:
	mDisplayString	[EBP+12]
	CALL			CrLf
	JMP				_endErrTI

_ErrorPos:
	mDisplayString	[EBP+16]
	CALL			CrLf
	JMP				_endErrTI

_ErrorAscii:
	mDisplayString	[EBP+20]
	CALL			CrLf
	JMP				_endErrTI

_ErrorEmpty:
	mDisplayString	[EBP+24]
	CALL			CrLf
	JMP				_startTI
	

_endTI:

	CMP			makeNeg,1
	JNE			_notNegTI
	NEG			total

_notNegTI:
	MOV		EBX,[EBP+28]
	MOV		EAX, total
	MOV		[EBX], EAX
_endErrTI:
	RET
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Convert a SDWORD into an ascii string of digits
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;	[EBP+8] = value (Value) - The SDWORD number to be converted.
;		
;
; Returns: None
; ---------------------------------------------------------------------------------
WriteVal PROC USES EAX EDX EBX ESI EDI ECX
	LOCAL		numString[FINAL_LEN]:BYTE
	LOCAL		numCopy:SDWORD
	LOCAL		isNeg:BYTE

	; Initialize Values
	MOV			isNeg, 0
	; Fill string with zeros
	MOV			ECX, FINAL_LEN
	LEA			EDI, numString
	CLD
	MOV			AL,48
	REP			STOSB		
	

	MOV			EAX,[EBP+8]
	MOV			numCopy, EAX
	STD

	; Check if negative to use later
	CMP			numCopy,0
	JGE			_TSLoop
	NEG			numCopy
	MOV			isNeg, 1
_TSLoop:
	; Until there aren't any digits left, divide by 10 and take remainder
	MOV			EAX, numCopy
	CDQ
	MOV			EBX, 10
	IDIV		EBX
	MOV			numCopy, EAX
	MOV			EAX,  EDX
	; Add 48 to digit to get ascii code
	ADD			AL, 48
	STOSB
	CMP			numCopy,0
	JNE			_TSLoop
	
	; Check if negative at the end
	CMP			isNeg, 1
	JNE			_notNegTS
	MOV			AL,NEGATIVE
	STOSB
	JMP			_endTS

_notNegTS:
	MOV			AL,POSITIVE
	STOSB

_endTS:
	ADD			EDI,1
	mDisplayString EDI
	RET
WriteVal ENDP

END main
