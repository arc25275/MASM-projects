TITLE Project 5    (Proj5_clarka8.asm)

; Author: Alex Clark
; Last Modified: 05/24/2024
; OSU email address: clarka8@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5   Due Date: 05/26/2024
; Description: A program that creates and manipulates an array using procedures and different addressing modes.

INCLUDE Irvine32.inc
INCLUDE Irvine32.lib

; Macros

; ----------------------------------
; Name: mPrintStrO
;
; Print a string that is inputted as OFFSET
;
; Receives:
; stringVar = Offset of String
; ----------------------------------
mPrintStrO MACRO stringOffset:REQ
	PUSH	EDX
    MOV		EDX, stringOffset
    CALL	WriteString
	POP		EDX
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
	PUSH	EAX
	MOV		EAX, decVar
	CALL	WriteDec
	POP		EAX
ENDM

; Constants

LO = 15
HI = 50
ARRAYSIZE = 200

.data

introTitle		BYTE	"Array Operations - Generating, Sorting, Counting - Alex Clark",0
introDesc1		BYTE	"This program will generate ",0
introDesc2		BYTE	" random numbers in the range of ",0
introDesc3		BYTE	" to ",0
introDesc4		BYTE	", which it will print out afterwards.",0
introDesc5		BYTE	"It will then be sorted in ascending order, ",0
introDesc6		BYTE	"which is printed after calculating the median of the numbers.",0 
introDesc7		BYTE	"Last, it generates a new array containing a count of how many times each number appeared in the array.",0
theArray		DWORD	ARRAYSIZE DUP(0)
medianTitle		BYTE	"The median of the array is ",0
unsortedTitle	BYTE	"Unsorted, random array: ",0
sortedTitle		BYTE	"Sorted array: ",0
countTitle		BYTE	"Count of occurences of each number in array: ",0
goodbye			BYTE	"Thank you for using my program!",0

.code
main PROC
	CALL	Randomize
	; Intro to Program
	PUSH	OFFSET	introTitle
	PUSH	OFFSET	introDesc1
	PUSH	OFFSET	introDesc2
	PUSH	OFFSET	introDesc3
	PUSH	OFFSET	introDesc4
	PUSH	OFFSET	introDesc5
	PUSH	OFFSET	introDesc6
	PUSH	OFFSET	introDesc7
	CALL	introduction
	PUSH	OFFSET	theArray
	CALL	fillArray	
	; Display Starting Array
	PUSH	OFFSET	unsortedTitle
	PUSH	ARRAYSIZE
	PUSH	OFFSET	theArray
	CALL	displayList
	; Sort Array
	PUSH	OFFSET	theArray
	CALL	sortList
	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Gives a short introduction
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: 
;		[EBP+36] = intro1 (Reference) - Title and my Name
;		[EBP+32] = intro2 (Reference) - Description of Program (Pt 1)
;		[EBP+28] = intro3 (Reference) - Description of Program (Pt 2)
;		[EBP+24] = intro4 (Reference) - Description of Program (Pt 3)
;		[EBP+20] = intro5 (Reference) - Description of Program (Pt 4)
;		[EBP+16] = intro5 (Reference) - Description of Program (Pt 5)
;		[EBP+12]  = intro7 (Reference) - Description of Program (Pt 6)
;		[EBP+8]	 = intro8 (Reference) - Description of Program (Pt 7)
;
; Returns: None
; ---------------------------------------------------------------------------------
introduction PROC
	PUSH		EBP
	MOV			EBP, ESP
	mPrintStrO	[EBP+36]
	CALL		CrLf
	CALL		CrLf
	mPrintStrO	[EBP+32]
	mPrintDec	ARRAYSIZE
	mPrintStrO	[EBP+28]
	mPrintDec	LO
	mPrintStrO	[EBP+24]
	mPrintDec	HI
	mPrintStrO	[EBP+20]
	CALL		CrLf
	mPrintStrO	[EBP+16]
	mPrintStrO	[EBP+12]
	CALL		CrLf
	mPrintStrO	[EBP+8]
	CALL		CrLf 
	POP			EBP
	RET			36		
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: fillArray
;
; Fills the array passed with randomly generated numbers depending on the global
; constant ARRAYSIZE. The numbers will be between constants LO and HI
;
; Preconditions: 
;		- Constants are defined, and Randomize has been Called once. 
;		- Array passed will be size of ARRAYSIZE.
;		- Uses ECX,EDI, and EAX. They are saved in the PROC
;
; Postconditions: None
;
; Receives: None
;
; Returns: 
;		[EBP+20] = someArray (Reference) - Array filled with random numbers
; ---------------------------------------------------------------------------------
fillArray PROC USES ECX EDI EAX
	PUSH		EBP
	MOV			EBP, ESP	
	MOV			ECX, ARRAYSIZE
	MOV			EDI, [EBP+20]	; Array
_fillLoopFA:
	MOV			EAX, HI-LO+1 ; Generate 0 to HI-LO
	CALL		RandomRange
	ADD			EAX, LO ; Add back LO so the range is LO to HI
	MOV			[EDI],EAX
	ADD			EDI, 4
	LOOP		_fillLoopFA
	POP			EBP
	RET			20
fillArray ENDP

; ---------------------------------------------------------------------------------
; Name: sortList
;
; Sorts an Array in ascending order, using selection sort.
;
; Preconditions:
;		- Array passed will be size of ARRAYSIZE.
;		- Uses ECX,EDI, and EAX. They are saved in the PROC
;
; Postconditions: None
;
; Receives:
;		[EBP+20] = someArray (Reference) - Unsorted array
;
; Returns: 
;		[EBP+20] = someArray (Reference) - Sorted array
; ---------------------------------------------------------------------------------
sortList PROC USES ECX EDI EAX
	PUSH		EBP
	MOV			EBP, ESP	
	MOV			EDI, [EBP+20]	; Array

	MOV			ECX, ARRAYSIZE
	; For i: 0 through n
_iLoopStart:
	mPrintDec	ECX
	MOV			EAX,ECX
	PUSH		ECX
	MOV			ECX, ARRAYSIZE
	SUB			ECX,EAX
	; For j: i through n
_jLoopStart:
	mPrintDec	ECX

	; End j
	POP			ECX
	; End i
	POP			EBP
	RET			20
sortList ENDP

; ---------------------------------------------------------------------------------
; Name: exchangeElements
;
; Swap two elements of an array
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;		[EBP+12]  = someArray[i] (Reference) - FIrst element to swap
;		[EBP+8] = someArray[j] (Reference) - Second element to swap

;
; Returns: 
;		[EBP+12]  = someArray[i] (Reference) - Previously element j
;		[EBP+8] = someArray[j] (Reference) - Previously element i
; ---------------------------------------------------------------------------------
exchangeElements PROC

	RET
exchangeElements ENDP

; ---------------------------------------------------------------------------------
; Name: displayMedian
;
; Calculates and displays the median of a sorted array
;
; Preconditions: 
;		- Array must be sorted
;		- Array passed will be size of ARRAYSIZE.
;
; Postconditions: None
;
; Receives:
;		[EBP+12]  = someTitle (Reference) - Title for median
;		[EBP+8] = someArray (Reference) - Array to find median of
;
; Returns: None
; ---------------------------------------------------------------------------------
displayMedian PROC

	RET
displayMedian ENDP

; ---------------------------------------------------------------------------------
; Name: displayList
;
; Print array that is given, along with title.
;
; Preconditions:
;		- Uses ECX,EDI, and EAX. They are saved in the PROC
;
; Postconditions: None
;
; Receives:
;		[EBP+28]  = someTitle   (Reference) - Title for array
;		[EBP+24] = arrayLength (Value)
;		[EBP+20] = someArray   (Reference) - Array to find median of
;
; Returns: None
; ---------------------------------------------------------------------------------
displayList PROC USES ECX EDI EAX
	PUSH		EBP
	MOV			EBP, ESP
	mPrintStrO	[EBP+28]
	CALL		CrLf
	MOV			ECX, [EBP+24]	; Length
	MOV			EDI, [EBP+20]	; Array
	MOV			EAX, 0
_printLoopDL:
	INC			EAX
	mPrintDec	[EDI]
	PUSH		EAX
	MOV			AL," "
	CALL		WriteChar
	POP			EAX
	ADD			EDI, 4 
	CMP			EAX,20
	JE			_newLineDL
_finishLoopDL:
	LOOP		_printLoopDL
	JMP			_endDL
_newLineDL:
	CALL		CrLf
	MOV			EAX,0
	JMP			_finishLoopDL
_endDL:
	POP			EBP
	RET			28
displayList ENDP

; ---------------------------------------------------------------------------------
; Name: countList
;
; Count the number of occurences of the elements of an array
;
; Preconditions:
;		- Array passed will be size of ARRAYSIZE.
;
; Postconditions: None
;
; Receives:
;		[EBP+8] = someArray1 (Reference) - Array to count
;
; Returns: 
;		[EBP+8] = someArray2 (Reference) - Count array
; ---------------------------------------------------------------------------------
countList PROC

	RET
countList ENDP


END main
