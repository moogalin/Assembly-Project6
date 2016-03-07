TITLE Program 6A  (Project6MeganAldridge.asm)

; Author: Megan Aldridge
; OSU Email : aldridme@oregonstate.edu
; Class & Section: CS271 - 400
; Assignment Number : 5
; Due Date : 3 / 14 / 2016
; Description: This program will allow the user to enter 10 strings of numbers
;		and will validate that all characters are numeric and the number fits
;		in a 32-bit register. Then, the program will calculate the subtotal 
;		after each number added, convert the subtotal to a string, and then 
;		display it. Finally, the program will calculate the average of all numbers, 
;		convert it to a string, and display the average. 
INCLUDE Irvine32.inc

MAXSIZE = 20
NUM_OF_INTS = 10
X_local EQU BYTE PTR [ebp-4]
Y_local EQU BYTE PTR [ebp-8]

getString MACRO bytes1, userNum, prompt1, elementNum
		pushad
		mov		edx, prompt1
		call	WriteString
		mov		eax, elementNum
		call	WriteDec
		mov		al, ':'
		call	WriteChar
		mov		edx, userNum
		mov		ecx, MAXSIZE
		mov		edi, bytes1
		call	ReadString
		mov		[edi], eax
		popad
ENDM

displayString MACRO string
		push	edx
		xor		edx, edx	
		lea		edx, string
		call	WriteString
		pop		edx
ENDM



.data

introString				BYTE			"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures" , 0dh, 0ah
						BYTE			"Written by: Megan Aldridge", 0dh, 0ah, 0dh, 0ah
						BYTE			"Please provide 10 unsigned decimal integers. ", 0dh, 0ah
						BYTE			"After you have finished inputting the raw numbers I will display a list" , 0dh, 0ah
						BYTE			"of the integers, their sum, and their average value.", 0dh, 0ah, 0
getStringPrompt			BYTE			"Please enter unsigned integer number #", 0
errorString				BYTE			"ERROR: You did not enter an unsigned number or your number was too big.", 0dh, 0ah, 0
userNumberString		BYTE			MAXSIZE DUP(?)	
numberArray				DWORD			NUM_OF_INTS DUP(?)
subTotString			BYTE			"  The subtotal: ", 0	
avgString				BYTE			"  The average of all numbers: ", 0
numsString				BYTE			"You entered the following numbers: ", 0dh, 0ah, 0
byteCount				DWORD			0
userNumberInteger		DWORD			0	
arrayIndex				DWORD			0
numElements				DWORD			0
avgValue				DWORD			0
sumValue				DWORD			0
endString				BYTE			"Made it to the end of main." , 0dh, 0ah, 0

.code
main PROC

		displayString	introString
		call			Crlf

		mov		ecx, NUM_OF_INTS
	fillArrayLoop:								; call readVal and add value to array NUM_OF_INT times

		inc			numElements
		push		numElements
		push		OFFSET	errorString
		push		OFFSET	userNumberInteger
		push		OFFSET	getStringPrompt
		push		OFFSET  userNumberString
		push		OFFSET	byteCount
		call		readVal
		
		push		userNumberInteger
		push		arrayIndex
		push		OFFSET numberArray
		call		fillArray

		displayString	subTotString			; display subtotal with each integer added to array

		push		numElements
		push		OFFSET numberArray
		push		OFFSET sumValue
		call		computeSum

		add		arrayIndex, 4

	endFillArrayLoop:							; all numbers have been added to integer array
		loop	fillArrayLoop
		call	Crlf

		displayString	numsString

		push		OFFSET numberArray
		call		displayArray				; display numbers in the array
		call		Crlf

		displayString	avgString

		push		sumValue					
		push		OFFSET	avgValue
		call		computeAvg					; compute and display average value

		displayString	endString
		call		Crlf
		call		Crlf
		exit									; exit to operating system
main ENDP

readVal PROC
		push		ebp
		mov			ebp, esp
		sub			esp, 8						; reserve space for 2 local variables
		pushad			

	getValueMacro:
		getString [ebp+8],[ebp+12],[ebp+16], [ebp+28]

		mov			esi, [ebp+12]				; OFFSET of numberString (source)
		mov			eax, [ebp+8]				; OFFSET of number of bytes in string
		mov			ecx, [eax]					; move number of bytes to counter

		cld										; directon = forward
		mov			X_local, 0					; local BYTE variable
		mov			Y_local, 0					; local BYTE variable
		xor			eax, eax
		xor			ebx, ebx

	convertString:
		lodsb									; load [esi] into al
		
		cmp			al, 48
		jl			errorNotInt					
		cmp			al, 57
		jg			errorNotInt

		sub			al, 48						; convert to integer
		mov			Y_local, al					; store converted digit
		mov			eax, ebx			
		mov			ebx, 10
		mul			ebx
		mov			ebx, 0
		mov			bl, Y_local					; restore integer in ebx
		add			eax, ebx
		mov			ebx, eax					; save converted digit in ebx 

		jc			errorNotInt					; if carry flag set, source > destination
	
	endConverStringLoop:
		loop		convertString
		jmp			endErrorInt

	errorNotInt:
		mov			edx, [ebp+24]				; OFFSET of errorString
		call		WriteString
		jmp			getValueMacro				; get new value

	endErrorInt:
		mov			ecx, [ebp+20]				
		mov			[ecx], ebx					; save integer in userNumberInteger variable

		popad
		mov			esp, ebp
		pop			ebp
		ret			24
readVal ENDP


fillArray PROC
		push		ebp
		mov			ebp, esp
		pushad

		xor			eax, eax
		mov			edi, [ebp+8]				; OFFSET of integer array
		mov			ecx, [ebp+12]				; array element #
		mov			eax, [ebp+16]				; integer to be added to array 			
		
		mov			[edi+ecx], eax				; store integer at base-indexed value

		popad
		mov			esp, ebp
		pop			ebp
		ret			12
fillArray ENDP


displayArray PROC
		push		ebp
		mov			ebp, esp
		pushad

		mov			esi, [ebp+8]				; OFFSET of integer array
		mov			ecx, NUM_OF_INTS
		call		crlf
	L1:
		cld
		lodsd
		call		WriteDec
		xor			eax, eax
		cmp			ecx, 1
		je			endL1						; omit comma for last integer
		mov			al, ','
		call		WriteChar
		mov			al, ' '
		call		WriteChar
		xor			eax, eax 
	endL1:
		loop		L1

		call		Crlf
		popad
		mov			esp, ebp
		pop			ebp
		ret			4
displayArray ENDP


computeSum PROC
		push		ebp
		mov			ebp, esp
		pushad

		mov			esi, [ebp+12]				; OFFSET of integer array
		mov			ecx, [ebp+16]				; number of elements
		xor			ebx, ebx					

	calcSum:
		lodsd			
		add			ebx, eax					; add integer to current sum
		loop		calcSum

		mov			eax, ebx					
		mov			ebx, [ebp+8]				; OFFSET of sumValue
		mov			[ebx], eax					; save sum in sumValue 
		
		push		eax							
		call		WriteVal					; display sum
		call		Crlf

		popad
		mov			esp, ebp
		pop			ebp
		ret			16

computeSum ENDP

computeAvg PROC
		push		ebp
		mov			ebp, esp
		pushad

		mov			eax, [ebp+12]				; move sumValue to eax
		mov			ebx, NUM_OF_INTS			; move number of elements to ebx
		sub			edx, edx					; set edx to zero
		div			ebx

		mov			ebx, [ebp+8]
		mov			[ebx], eax					; save average in avgValue
		
		push		eax
		call		WriteVal					; display average
		call		Crlf

		popad
		mov			esp, ebp
		pop			ebp
		ret			8
computeAvg ENDP

writeVal PROC
		LOCAL inputArray[100]:DWORD
		LOCAL outputArray[99]:DWORD
		sub			esp, 8						; reserve space for 2 local variables
		pushad

		;Clear the local arrays
		xor			eax, eax
		mov			ecx, 100
		lea			edi, inputArray
		cld
		rep			stosb

		xor			eax, eax
		mov			ecx, 99
		lea			esi, outputArray
		cld
		rep			stosb

		mov			eax,[ebp+8]					; number to convert
		lea			edi, inputArray	
		mov			ebx, 10
		mov			X_local, 0					; number of integers in string 
		cld
		
	convertToInt:
		inc			X_local						
		xor			edx, edx					; zero remainder value
		mov			ebx, 10
		div			ebx							; Divide eax by 10

		mov			ebx, eax					; store integer to convert
		add			dl, 48						; convert remainder to ASCII integer value

		xor			eax, eax
		mov			al, dl						; move remainder to eax register to store in edi

		stosb	

		mov			eax, ebx					; restore integer to convert
		cmp			eax, 0						; Divide until (eax / 10) is less than 0
		jne			convertToInt
 
		mov			eax, 0
		mov			al, X_local					; save number of integers


	COMMENT	!***************************************************************************
	Because the conversion generated the reverse string by starting at the smallest digit, 
	we need to reverse the string.
	Source for reverse code: Demo6.asm 
	***********************************************************************************!
	;reverse the string							
		mov			ecx, eax
		lea			esi, inputArray
		add			esi, ecx
		dec			esi
		lea			edi, outputArray

	reverseString:
		std
		lodsb
		cld
		stosb

	endReverseString:
		loop		reverseString

	displayString outputArray

		popad
		add			esp, 8						; remove 2 local variables
		ret			4
writeVal ENDP




END main
