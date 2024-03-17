%include 'mio.inc'

global StrLen, StrCat, StrUpper, StrLower, StrCompact

section .text 
StrLen: ; String input in esi, length out in eax.
	push	esi
	xor		eax, eax
	.loop:
	inc		eax
	cmp		[esi + eax], byte 0
	jne		.loop
	pop		esi
	ret
	
StrCat: ; Returns edi + esi in edi.
	push	eax
	push 	ebx
	push	ecx
	push	esi
	mov 	ebx, esi
	mov 	esi, edi
	call	StrLen
	mov 	esi, ebx
	mov		ecx, eax
	xor 	ebx, ebx
	dec 	ebx
	.loop:
	inc 	ebx
	cmp		[esi + ebx], byte 0
	je		.exit
	mov		al, [esi + ebx]
	mov		[edi + ecx], al
	inc		ecx
	jmp 	.loop
	.exit:
	mov 	[edi + ecx], byte 0
	pop 	esi
	pop 	ecx
	pop 	ebx
	pop 	eax
	ret

StrUpper: ; Input in esi.
	push 	ecx
	push 	eax
	xor 	ecx, ecx
	xor 	eax, eax
	.loop:
	cmp		[esi + ecx], byte 0
	je 		.exit
	mov 	al, [esi + ecx]
	call	to_upper
	mov		[esi + ecx], al
	inc 	ecx
	jmp 	.loop
	.exit:
	pop 	eax
	pop 	ecx
	ret
	
to_upper:
	cmp		eax, 'a'
	jl 		.ret
	cmp 	eax, 'z'
	jg 		.ret
	sub		eax, 32
	.ret:
	ret
	
StrLower: ; Input in esi.
	push 	ecx
	push 	eax
	xor 	ecx, ecx
	xor 	eax, eax
	.loop:
	cmp		[esi + ecx], byte 0
	je 		.exit
	mov 	al, [esi + ecx]
	call	to_lower
	mov		[esi + ecx], al
	inc 	ecx
	jmp 	.loop
	.exit:
	pop 	eax
	pop 	ecx
	ret
	
to_lower:
	cmp		eax, 'A'
	jl 		.ret
	cmp 	eax, 'Z'
	jg 		.ret
	add		eax, 32
	.ret:
	ret
	
StrCompact: ; Input in esi, output in edi.
	push 	ecx
	push 	eax
	push 	edx
	xor 	ecx, ecx
	xor 	eax, eax
	xor 	edx, edx
	dec 	ecx
	.loop:
	inc 	ecx
	cmp		[esi + ecx], byte 0
	je 		.exit
	mov 	al, [esi + ecx]
	call	is_valid
	jc 		.loop
	mov		[edi + edx], al
	inc 	edx
	jmp 	.loop
	.exit:
	mov 	[edi + edx], byte 0
	pop 	edx
	pop 	eax
	pop 	ecx
	ret
	
is_valid:
	cmp 	eax, 9
	je		.not
	cmp		eax, 10
	je		.not
	cmp 	eax, 13
	je 		.not
	cmp 	eax, 32
	je 		.not
	clc
	ret
	.not:
	stc
	ret