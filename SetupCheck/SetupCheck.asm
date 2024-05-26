TITLE VS Setup Check     (SetupCheck.asm)

; Author: 	Alex Clark
; Last Modified:	04/03/24
; Course number/section:   CS271 Section 400
; Description: This file is provided to enable you to verify your
;              VS Install is running properly.

INCLUDE Irvine32.inc

.data



.code
main PROC
	push 1
	push 2
	push -1
	push -2
	pop eax
	pop eax
	pop eax
	pop eax

	Invoke ExitProcess,0	; exit to operating system
main ENDP


END main
