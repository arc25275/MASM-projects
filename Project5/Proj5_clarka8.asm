TITLE Project 5    (Proj5_clarka8.asm)

; Author: Alex Clark
; Last Modified: 05/26/2024
; OSU email address: clarka8@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5   Due Date: 05/26/2024
; Description: A program that creates and manipulates an array using procedures and different addressing modes.

INCLUDE Irvine32.inc

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
; dec = Unsigned Integer
; ----------------------------------
mPrintDec MACRO dec:REQ
	PUSH	EAX
	MOV		EAX, dec
	CALL	WriteDec
	POP		EAX
ENDM

; ----------------------------------
; Name: mPrintChar
;
; Print a char that is inputted
;
; Receives:
; char = Character
; ----------------------------------
mPrintChar MACRO char:REQ
	PUSH	EAX
	MOV		AL, char
	CALL	WriteChar
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
countArray		DWORD	HI-LO+1	DUP(0)	;I struggled to figure out a way to pass this back otherwise, not sure if there is a better way
medianTitle		BYTE	"The median of the array is ",0
unsortedTitle	BYTE	"Unsorted, random array: ",0
sortedTitle		BYTE	"Sorted array: ",0
countTitle		BYTE	"Count of occurences of each number in array (Array is from index 0 to n, where 0 is LO, and n is HI): ",0
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

	; Print Starting Array
	PUSH	OFFSET	unsortedTitle
	PUSH	ARRAYSIZE
	PUSH	OFFSET	theArray
	CALL	displayList

	; Sort Array
	PUSH	OFFSET	theArray
	CALL	sortList

	; Find Median
	PUSH	OFFSET	medianTitle
	PUSH	OFFSET	theArray
	CALL	displayMedian

	; Print after sort
	PUSH	OFFSET	sortedTitle
	PUSH	ARRAYSIZE
	PUSH	OFFSET	theArray
	CALL	displayList

	; Count List
	PUSH	OFFSET	theArray
	PUSH	OFFSET	countArray
	CALL	countList
	
	; Print Count Array
	PUSH	OFFSET countTitle
	MOV		EBX, HI-LO+1
	PUSH	EBX
	PUSH	OFFSET countArray
	CALL	displayList

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
;		[EBP+12] = intro7 (Reference) - Description of Program (Pt 6)
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
	; ECX - Counter
	; EDI - Array
	; EAX - Random Number / Range
	PUSH		EBP
	MOV			EBP, ESP	
	MOV			ECX, ARRAYSIZE
	MOV			EDI, [EBP+20]	; Array

_fillLoop:
	MOV			EAX, HI-LO+1	; Generate 0 to HI-LO
	CALL		RandomRange

	ADD			EAX, LO			; Add back LO so the range is LO to HI
	MOV			[EDI],EAX

	ADD			EDI, 4
	LOOP		_fillLoop

	POP			EBP
	RET			4
fillArray ENDP

; ---------------------------------------------------------------------------------
; Name: sortList
;
; Sorts an Array in ascending order, using selection sort.
;
; Preconditions:
;		- Array passed will be size of ARRAYSIZE.
;
; Postconditions: None
;
; Receives:
;		[EBP+24] = someArray (Reference) - Unsorted array
;
; Returns: 
;		[EBP+24] = someArray (Reference) - Sorted array
; ---------------------------------------------------------------------------------
sortList PROC USES ECX EDI EAX EBX
	; ECX - Counter
	; EDI - Array
	; EAX - Index
	; EBX - Min value
	PUSH		EBP
	MOV			EBP, ESP	
	MOV			EDI, [EBP+24]
	MOV			ECX, ARRAYSIZE-1
	MOV			EAX, 0


	; For i: 0 through n
_iLoopStart:
	MOV			EBX, EDI
	PUSH		ECX
	MOV			ECX, ARRAYSIZE-1
	SUB			ECX,EAX				;Set j loop count to size n-i
	PUSH		EAX					;Save i
	PUSH		EDI

	; For j: i+1 through n
_jLoopStart:
	; Increment counters
	ADD			EAX, 1
	ADD			EDI, 4
	PUSH		EAX
	MOV			EAX, [EDI]
	CMP			[EBX], EAX
	POP			EAX
	JL			_notMin
	MOV			EBX, EDI			; Transfer over if smaller
_notMin:
	; End j
	JECXZ		_jEnd				;Needed to add this as it would sometimes be 0 and break
	LOOP		_jLoopStart
_jEnd:
	; Reset Counter back to previous state
	POP			EDI
	POP			EAX					
	POP			ECX

	PUSH		EDI
	PUSH		EBX
	CALL		exchangeElements	;Swap i with min, making 0 through i sorted
	; Increment counters
	ADD			EAX,1
	ADD			EDI,4
	; End i
	JECXZ		_iEnd
	LOOP		_iLoopStart
_iEnd:

	POP			EBP
	RET			4
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
;		[EBP+24]  = someArray[i] (Reference) - FIrst element to swap
;		[EBP+20] = someArray[j] (Reference) - Second element to swap
;
; Returns: 
;		[EBP+24]  = someArray[i] (Reference) - Previously element j
;		[EBP+20] = someArray[j] (Reference) - Previously element i
; ---------------------------------------------------------------------------------
exchangeElements PROC USES EDI EAX EBX
	; EDI - Holding array pointer
	; Temp is needed more than once due to how you need to dereference the parameters twice to get the values
	; (Stack Pointer -> Array Pointer -> Value)
	; EAX - Array[i]
	; EBX - Array[j]
	PUSH		EBP
	MOV			EBP, ESP	
	MOV			EDI, [EBP+24]	; Move someArray[i] to temp location. This is the mem address to the value in the array
	MOV			EAX, [EDI]		; Get actual value of arr[i] into EAX

	MOV			EDI, [EBP+20]	; Move someArray[j] to temp location.
	MOV			EBX, [EDI]		; arr[j] in EBX

	MOV			[EDI], EAX		
	MOV			EDI, [EBP+24]	; Get mem addr of arr[i] back in temp
	MOV			[EDI], EBX	

	POP			EBP
	RET			8
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
;		[EBP+28]	= someTitle (Reference) - Title for median
;		[EBP+24]	= someArray (Reference) - Array to find median of
;
; Returns: None
; ---------------------------------------------------------------------------------
displayMedian PROC USES EDI EAX EBX EDX
	; EDI - Array
	; EAX - Numerator
	; EBX - Divisor
	; EDX - Division Remainder
	PUSH		EBP
	MOV			EBP,ESP

	MOV			EDI, [EBP+24]

	; Divide size by 2, and check the remainder to see if the size was even.
	MOV			EAX, ARRAYSIZE 
	MOV			EDX, 0
	MOV			EBX, 2
	DIV			EBX			;ARRAYSIZE/2. EAX=Result, EDX=Remainder
	CMP			EDX, 0		;If remainder is 0, it is even

	; These were originally separate but ended up being the same for both paths, 
	; so they have been combined here.
	MOV			EBX, 4
	MUL			EBX
	ADD			EDI, EAX	
	MOV			EAX, [EDI]
	JNZ			_end		; If it is odd, the right number is already in place, and nothing else needs to happen.
	; If Even:
	ADD			EDI, EAX 
	MOV			EAX, [EDI]	; Add Size/2 to EAX
	ADD			EDI, -4
	ADD			EAX, [EDI]	; Add Size/2 - 1 to EAX

	MOV			EDX, 0
	MOV			EBX, 2
	DIV			EBX			; Divide by 2 for average

	CMP			EDX, 1		
	JNZ			_end
	INC			EAX			; If 0.5 remainder, round up.

_end:
	CALL		CrLf

	mPrintStrO	[EBP+28]
	mPrintDec	EAX
	mPrintChar	"."

	CALL		CrLf
	CALL		CrLf

	POP			EBP
	RET			8
displayMedian ENDP

; ---------------------------------------------------------------------------------
; Name: displayList
;
; Print array that is given, along with title.
;
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;		[EBP+28] = someTitle   (Reference) - Title for array
;		[EBP+24] = arrayLength (Value)
;		[EBP+20] = someArray   (Reference) - Array to find median of
;
; Returns: None
; ---------------------------------------------------------------------------------
displayList PROC USES ECX EDI EAX
	; ECX - Counter
	; EDI - Array
	; EAX - Index for line length
	PUSH		EBP
	MOV			EBP, ESP

	mPrintStrO	[EBP+28]		; Title
	CALL		CrLf

	MOV			EAX, 0
	MOV			ECX, [EBP+24]
	MOV			EDI, [EBP+20]
	; For each value, print to console with a space in between. Max 20 elements per line.
_printLoop:
	INC			EAX
	mPrintDec	[EDI]
	mPrintChar	" "
	ADD			EDI, 4			; Increment Array 
	CMP			EAX,20			; If 20 elements in line, make a new line
	JNE			_finishLoop
	CALL		CrLf
	MOV			EAX,0
_finishLoop:
	LOOP		_printLoop

	CALL		CrLf
	POP			EBP
	RET			12
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
;		[EBP+32] = someArray1 (Reference) - Array to count
;
; Returns: 
;		[EBP+28] = someArray2 (Reference) - Count array
; ---------------------------------------------------------------------------------
countList PROC USES ECX EAX EBX EDI EDX
	; ECX - Counter
	; EBX - Counting Array
	; EDI - Array 1
	; EAX - Value in Array 1/Offset for EBX
	; EDX - Multiplying by 4
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EBX, [EBP+28]	; Put countArray into EBX
	MOV		EDI, [EBP+32]	; Put Array 1 into EDI
	MOV		ECX, ARRAYSIZE
_countNums:
	MOV		EAX, [EDI]		; Get value of current index
	; Get index in countArray
	SUB		EAX, LO
	MOV		EDX, 4
	MUL		EDX
	ADD		EBX, EAX		; Equivalent to EBX+(n-LO)*4
	
	INC		DWORD PTR [EBX]

	SUB		EBX, EAX		; Go back to start of array
	ADD		EDI, 4			; Increment Array 1
	LOOP	_countNums

	POP		EBP
	RET		8
countList ENDP


END main
