TITLE Program 6A  (template.asm)

; Author: Megan Aldridge
; OSU Email: aldridme@oregonstate.edu
; Class & Section: CS271- 400
; Assignment Number:         
; Due Date: 
; Description: 

INCLUDE Irvine32.inc
MAXSIZE = 20
NUM_OF_INTS = 10
X_local EQU BYTE PTR [ebp-4]
Y_local EQU BYTE PTR [ebp-8]

getString MACRO bytes1, userNum, prompt1
		mov		edx, prompt1
		call	WriteString
		mov		edx, userNum
		mov		ecx, MAXSIZE
		mov		edi, bytes1
		call	ReadString
		mov		[edi], eax

ENDM

.data

introString				BYTE			"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures" , 0dh, 0ah
						BYTE			"Written by: Megan Aldridge", 0dh, 0ah, 0dh, 0ah
						BYTE			"Please provide 10 unsigned decimal integers. ", 0dh, 0ah
						BYTE			"After you have finished inputting the raw numbers I will display a list" , 0dh, 0ah
						BYTE			"of the integers, their sum, and their average value.", 0dh, 0ah, 0
getStringPrompt			BYTE			"Please enter an unsigned number: ", 0
errorString				BYTE			"ERROR: You did not enter an unsigned number or your number was too big.", 0dh, 0ah, 0
userNumberString		BYTE			MAXSIZE DUP(?)	
sumString				BYTE			"  The sum of these numbers so far is: ", 0	
byteCount				DWORD			?
userNumberInteger		DWORD			?	
numberArray				DWORD			NUM_OF_INTS DUP(?)
arrayIndex				DWORD			-4
numElements				DWORD			0
averageValue			DWORD			?
sumValue				DWORD			?
;testString				BYTE			"Meow", 0dh, 0ah, 0
endString				BYTE			"Made it to the end of main." , 0dh, 0ah, 0

.code
main PROC

		push	OFFSET	introString
		call	intro

		mov		ecx, NUM_OF_INTS

	fillArrayLoop:
		add		arrayIndex, 4
		inc		numElements
		push	OFFSET	errorString
		push	OFFSET	userNumberInteger
		push	OFFSET	getStringPrompt
		push	OFFSET  userNumberString
		push	OFFSET	byteCount
		call	readVal

		push	userNumberInteger
		push	arrayIndex
		push	OFFSET numberArray
		call	fillArray

		;add	arrayIndex, 4
		push	OFFSET	sumString
		push	numElements
		push	OFFSET numberArray
		push	OFFSET sumValue
		call	computeSum
		loop	fillArrayLoop

		push	OFFSET numberArray
		call	displayArray


		mov		edx, OFFSET endString
		call	WriteString

		exit	; exit to operating system
main ENDP

intro PROC
		push	ebp
		mov		ebp, esp
		push	edx

		mov		edx, [ebp+8]
		call	WriteString
		call	Crlf

		pop		edx
		pop		ebp
		ret		4	
intro ENDP

readVal PROC
		push	ebp
		mov		ebp, esp
		sub		esp, 8						; reserve space for 2 local variables
		pushad

	getValueMac:
		getString [ebp+8],[ebp+12],[ebp+16]
		xor		esi, esi
		xor		edi, edi
		mov		esi, [ebp+12]				; OFFSET of numberString (source)
		mov		edi, esi					; destination
		;mov		edi, [ebp+20]				; OFFSET of numberInteger (destination)

	
		mov		eax, [ebp+8]				; OFFSET of number of bytes in string
		mov		ecx, [eax]					; move number of bytes to counter
		cmp		ecx, 10						; maximum number of characters allowed
		jg		errorNotInt					

		cld									; directon = forward;
		;dec		ecx							; counter = string length - 1
		mov		X_local, 0					; Integer converted from numberString, BYTE
		mov		Y_local, 0					; BYTE
		xor		eax, eax
		mov		ebx, 0
	convertString:
		lodsb								; load [esi] into al
		
		cmp		al, 48
		jl		errorNotInt					
		cmp		al, 57
		jg		errorNotInt

		sub		al, 48
		mov		Y_local, al
		mov		eax, ebx
		mov		ebx, 10
		mul		ebx
		mov		ebx, 0
		mov		bl, Y_local
		add		eax, ebx
		mov		ebx, eax
		jc		errorNotInt					; if carry flag set, source > destination

		stosb								; store al into [edi]
		loop	convertString
		jmp		endErrorInt
	errorNotInt:
		mov		edx, [ebp+24]				; OFFSET of errorString
		call	WriteString
		jmp		getValueMac					; get new value
	endErrorInt:
		mov		ecx, [ebp+20]
		mov		[ecx], ebx	

		popad
		mov		esp, ebp
		pop		ebp
		ret		20
readVal ENDP


fillArray PROC
		push	ebp
		mov		ebp, esp
		pushad

		mov		edi, [ebp+8]				; OFFSET of integer array
		mov		ecx, [ebp+12]				; array element #
		mov		eax, [ebp+16]				; integer to be added to array 			
		
		mov		[edi+ecx], eax	
		;call	WriteDec
		;call	Crlf

		popad
		mov		esp, ebp
		pop		ebp
		ret		12
fillArray ENDP


displayArray PROC
		push	ebp
		mov		ebp, esp
		pushad

		mov		esi, [ebp+8]				; OFFSET of integer array
		mov		ecx, NUM_OF_INTS 

	loopDisplay:
		mov		eax, [esi]
		call	WriteDec
		mov		al, ' '
		call	WriteChar
		add		esi, 4
		loop	loopDisplay

		popad
		mov		esp, ebp
		pop		ebp
		ret		4
displayArray ENDP


computeSum PROC
		push	ebp
		mov		ebp, esp
		pushad

		mov		edi, [ebp+12]				; OFFSET of integer array
		mov		eax, [ebp+16]				; number of elements
		mov		edx, [ebp+20]				; OFFSET of sumString
		mov		ecx, eax

		mov		ebx, 0

	calcSum:
		mov		eax, [edi]
		add		ebx, eax
		add		edi, 4
		loop	calcSum

		call	WriteString
		mov		eax, ebx
		mov		ebx, [ebp+8]				; OFFSET of sumValue
		mov		[ebx], eax					; save sum in sumValue 
		call	WriteDec
		call	Crlf

		popad
		mov		esp, ebp
		pop		ebp
		ret		20
computeSum ENDP

END main
