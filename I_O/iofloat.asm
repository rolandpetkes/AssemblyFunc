%include 'mio.inc'

global main

section .text
ReadFloat: ; Reads a floating point number into xmm0.
	push 	ecx
	push 	edx
	push	ebx	
	push	esi
	push 	eax
	push 	edi
	xorps	xmm0, xmm0
	xorps 	xmm1, xmm1
	xor 	edx, edx
	xor 	ebx, ebx
	xor 	eax, eax
	mov		esi, input
	mov 	ecx, 50
	call	ReadStr
	xor		ecx, ecx
	dec 	ecx
	.in:
	inc 	ecx
	cmp		[esi + ecx], byte 0
	je		.exit
	mov		al, [esi + ecx]
	cmp		eax, '-' ; sign check
	je		.negative_in
	cmp 	eax, '.'
	je		.floating_point
	sub		eax, '0'
	mulss	xmm0, [ten]
cvtsi2ss	xmm1, eax
	addss	xmm0, xmm1
	jmp		.in
	.floating_point: ; reading the fraction
	movss	xmm7, [ten]
	.in_float:
	inc 	ecx
	cmp		[esi + ecx], byte 0
	je		.exit
	mov		al, [esi + ecx]
	sub		eax, '0'
cvtsi2ss	xmm1, eax
	divss	xmm1, xmm7
	mulss	xmm7, [ten]
	addss	xmm0, xmm1
	jmp		.in_float
	.negative_in:
	mov		edx, 1
	jmp		.in
	.exit:
	cmp		edx, 1
	je		.negative
	clc
	jmp 	.ret
	.negative:
	mulss	xmm0, [negone]
	clc
	.ret:
	pop 	edi
	pop		eax
	pop		esi
	pop 	ebx
	pop 	edx
	pop 	ecx
	ret
	
WriteFloat: ; Outputs the floating point number received in xmm0.
	pusha
	comiss	xmm0, [zero]
	jb		.negative
	.whole_part:
cvttss2si	eax, xmm0
	call	WriteInt ; output the whole part of the number
cvtsi2ss 	xmm1, eax
	subss 	xmm0, xmm1
	push 	eax
	mov 	eax, '.'
	call	mio_writechar
	pop 	eax
	jmp 	.fraction
	.negative:
	mov 	eax, '-'
	call	mio_writechar
	mulss	xmm0, [negone]
	jmp		.whole_part
	.fraction:
	mov 	ecx, 6 ; output fraction with fixed precision of 6
	.loop:
	mulss 	xmm0, [ten]
	cvttss2si	eax, xmm0
	call	WriteInt
cvtsi2ss 	xmm1, eax
	subss 	xmm0, xmm1
	loop 	.loop
	popa
	ret
	
ReadExponentFloat: ; Reads an exponential number into xmm0.
	push 	ecx
	push 	edx
	push	ebx	
	push	esi
	push 	eax
	push 	edi
	xorps	xmm0, xmm0
	xorps 	xmm1, xmm1
	xor 	edi, edi
	xor 	edx, edx
	xor 	ebx, ebx
	xor 	eax, eax
	mov		esi, input
	mov 	ecx, 50
	call	ReadStr
	xor		ecx, ecx
	jmp		.is_neg
	.in: ; input the whole part
	mov		al, [esi + ecx]
	sub		eax, '0'
	mulss	xmm0, [ten]
cvtsi2ss	xmm1, eax
	addss	xmm0, xmm1
	inc		ecx
	.floating_point: ; input the fraction
	movss	xmm7, [ten]
	.in_float:
	inc 	ecx
	mov		al, [esi + ecx]
	cmp		al, 'e'
	je		.sign
	cmp		al, 'E'
	je		.sign
	mov		al, [esi + ecx]
	sub		eax, '0'
cvtsi2ss	xmm1, eax
	divss	xmm1, xmm7
	mulss	xmm7, [ten]
	addss	xmm0, xmm1
	jmp		.in_float
	.is_neg: ; check wether the number is negative or not
	mov		al, [esi + ecx]
	cmp		al, '-'
	je 		.neg
	jmp 	.in
	.neg:
	mov		edx, 1
	inc 	ecx
	jmp		.in
	.sign: ; check whether exponent is negative or not
	inc 	ecx
	mov 	al, [esi + ecx]
	call 	is_dec
	jnc		.end
	cmp		al, '+'
	je 		.incr
	mov 	edi, 1
	.incr:
	inc 	ecx
	.end:
	cmp		[esi + ecx], byte 0
	je		.multiply
	mov		al, [esi + ecx]
	sub		eax, '0'
	imul	ebx, 10
	add		ebx, eax ; ebx contains the number after the exponent
	inc 	ecx
	jmp		.end
	.multiply: ; moving the floating point
	mov		ecx, ebx
	cmp 	ecx, 0
	je		.exit
	cmp 	edi, 1
	je		.loop_neg
	.loop_pos:
	mulss	xmm0, [ten]
	loop	.loop_pos
	jmp 	.exit
	.loop_neg:
	divss 	xmm0, [ten]
	loop	.loop_neg
	.exit:
	cmp		edx, 0
	jne 	.negative
	je		.ret
	.negative:
	mulss	xmm0, [negone]
	.ret:
	pop 	edi
	pop		eax
	pop		esi
	pop 	ebx
	pop 	edx
	pop 	ecx
	ret
	
is_dec:
	sub		eax, '0'
	cmp		eax, 0
	jl		.not
	cmp		eax, 9
	jg		.not
	add 	eax, '0'
	clc
	ret
	.not:
	add 	eax, '0'
	stc
	ret
	
WriteExponentFloat: ; Outputs the floating point number received in xmm0.
	pusha
	xor 	ebx, ebx
	comiss	xmm0, [zero]
	jb		.negative
	.whole_part:
cvttss2si	eax, xmm0
	cmp		eax, 9
	jg		.divide
	cmp 	eax, 0
	jle		.multiply
	jmp 	.output
	.divide:
	divss	xmm0, [ten]
	inc		ebx
	jmp		.whole_part
	.multiply:
	mulss	xmm0, [ten]
	dec		ebx
	jmp 	.whole_part
	.negative:
	mov 	eax, '-'
	call	mio_writechar
	mulss	xmm0, [negone]
	jmp		.whole_part
	.output:
	call	WriteFloat
	mov 	eax, 'e'
	call	mio_writechar
	mov 	eax, ebx
	call	WriteInt
	popa
	ret

.single_dig:
	cmp		eax, 0
	jl		.not
	cmp		eax, 9
	jg		.not
	clc
	ret
	.not:
	stc
	ret
	
ReadStr: ;Input is in esi, ecx has the max number of characters.
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
	
WriteInt: ; Outputs the integer received in eax.
	pusha
	xor 	ecx, ecx
	cmp		eax, 0
	jl		.negative
	.next:
	mov		ebx, 10
	mov		edx, 0
	idiv	ebx
	push	edx
	inc		ecx
	cmp		eax, 0
	je		.write
	jmp		.next
	.write:
	pop		eax
	add		eax, '0'
	call	mio_writechar
	dec		ecx
	cmp		ecx, 0
	jg		.write
	popa
	ret
	.negative:
	mov		ebx, eax
	mov		eax, '-'
	call	mio_writechar
	mov		eax, ebx
	neg		eax
	jmp		.next
	
section .bss
	input 	resb 256
	
section .data
	ten 	dd	10.0
	negone	dd	-1.0
	zero	dd 	0.0
	two 	dd 	2.0