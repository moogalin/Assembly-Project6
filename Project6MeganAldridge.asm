
TITLE Program 6A    (program5MeganAldridge.asm)

; Author: Megan Aldridge
; OSU Email : aldridme@oregonstate.edu
; Class & Section: CS271 - 400
; Assignment Number : 5
; Due Date : 3 / 13 / 2016
; Description:
INCLUDE Irvine32.inc

getString MACRO 

ENDM

displayString MACRO

ENDM




; constants


.data

introString				BYTE		"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0dh, 0ah
						BYTE		"Written by: Megan Aldridge", 0dh, 0ah, 0dh, 0ah
						BYTE		"Please provide 10 unsigned decimal integers." , 0dh, 0ah
						BYTE		"Each number needs to be small enough to fit inside a 32 bit register.", 0dh, 0ah
						BYTE		"After you have finished inputting the raw numbers I will display a list", 0dh, 0ah
						BYTE		"of the integers, their sum, and their average value. ", 0dh, 0ah, 0dh, 0ah, 0
instructString			BYTE		"Please enter an unsigned number: ", 0
errorString				BYTE		"ERROR: You did not enter an unsigned number or your number was too big. ", 0dh, 0ah
						BYTE		"Please try again: ", 0dh, 0ah, 0
numsEnteredString		BYTE		"You entered the following numbers:", 0dh, 0ah, 0
sumString				BYTE		"The sum of these numbers is: ", 0dh, 0ah, 0
averageString			BYTE		"The average is: ", 0dh, 0ah, 0
goodbyeString			BYTE		"Thanks for playing!", 0dh, 0ah, 0
userInputString			DWORD		?
userInputInteger		DWORD		?
intArray				DWORD		10 DUP(?)


.code
main PROC	
		push	OFFSET introString
		call	intro

		push	OFFSET instructString
		push	OFFSET userInputString
		call	getStringPROC

		exit									; exit to operating system
main ENDP
		
intro PROC
		push		ebp
		mov			ebp, esp
		push		edx

		mov			edx, [ebp+8]					; introString
		call		WriteString

		pop			edx
		pop			ebp
		ret 4
intro ENDP


getString PROC
		push		ebp
		mov			ebp, esp
		push		edx
		push		eax

		mov			edx, [ebp+12]					; instructString
		mov			eax, [ebp+8]					; userInputInteger

		getString	edx, eax

		pop			eax
		pop			edx
		pop			ebp
		ret
getString ENDP


END main
