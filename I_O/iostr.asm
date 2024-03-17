%include 'mio.inc'

global ReadStr, WriteStr, ReadLnStr, WriteLnStr, NewLine

section .text
ReadStr: ; Input is in esi, ecx has the max number of characters.
	pusha
	mov 	ebx, ecx
	mov		ecx, 0
	.in:
	call	mio_readchar
	cmp 	al, 8
	je		.backspace
	cmp		al, 13
	je		.end
	call	mio_writechar
	mov		[esi + ecx], al
	inc		ecx
	jmp 	.in
	.backspace:
	cmp 	ecx, 0
	je		.in
	mov		eax, 8
	call	mio_writechar
	mov		eax, 32
	call 	mio_writechar
	mov		eax, 8
	call 	mio_writechar
	dec		ecx
	jmp		.in
	.end:
	cmp 	ecx, ebx
	jg		.greater
	mov		[esi + ecx], byte 0
	popa
	clc
	ret
	.greater:
	mov		[esi + ebx], byte 0
	popa
	clc
	ret
	
WriteStr: ; Receives string in esi
	pusha
	mov		ecx, 0
	.out:
	cmp		[esi + ecx], byte 0
	je		.end
	mov		eax, [esi + ecx]
	call	mio_writechar
	inc 	ecx
	jmp 	.out
	.end:
	popa
	ret
	
ReadLnStr: ; Input is in esi
	pusha
	mov		ecx, 0
	.in:
	call	mio_readchar
	cmp 	al, 8
	je		.backspace
	cmp		al, 13
	je		.end
	call	mio_writechar
	mov		[esi + ecx], al
	inc		ecx
	jmp 	.in
	.backspace:
	cmp 	ecx, 0
	je		.in
	mov		eax, 8
	call	mio_writechar
	mov		eax, 32
	call 	mio_writechar
	mov		eax, 8
	call 	mio_writechar
	dec		ecx
	jmp		.in
	.end:
	cmp 	ecx, ebx
	jg		.greater
	mov		[esi + ecx], byte 0
	popa
	call 	NewLine
	clc
	ret
	.greater:
	mov		[esi + ebx], byte 0
	popa
	call 	NewLine
	clc
	ret
	
WriteLnStr: ; Receives string in esi
	pusha
	mov		ecx, 0
	.out:
	cmp		[esi + ecx], byte 0
	je		.end
	mov		eax, [esi + ecx]
	call	mio_writechar
	inc 	ecx
	jmp 	.out
	.end:
	popa
	call 	NewLine
	ret
	
NewLine: ; Prints a newline character.
	push 	eax
	mov		al, 13
	call	mio_writechar
	mov		al, 10
	call	mio_writechar
	pop		eax
	ret