%include 'mio.inc'
%include 'iostr.inc'

global ReadInt, WriteInt, ReadBin, WriteBin, ReadHex, WriteHex, ReadInt64, WriteInt64, ReadBin64, WriteBin64, ReadHex64, WriteHex64

section .text
ReadInt: ; Reads an integer into eax.
	push 	ecx
	push 	edx
	push	ebx	
	push	esi
	xor 	edx, edx
	xor 	ebx, ebx
	xor 	eax, eax
	mov		esi, input
	mov 	ecx, 20
	call	ReadStr
	xor		ecx, ecx
	dec 	ecx
	.in:
	inc 	ecx
	cmp		[esi + ecx], byte 0
	je		.exit
	mov		al, [esi + ecx]
	cmp		eax, '-'
	je		.negative_in
	sub		eax, '0'
	call	is_dec
	jc		.error
	imul	ebx, 10
	jo		.error
	add		ebx, eax
	jo 		.error
	jmp		.in
	.negative_in:
	mov		edx, 1
	jmp		.in
	.error:
	stc
	jmp 	.ret
	.exit:
	cmp		edx, 1
	je		.negative
	mov		eax, ebx
	clc
	jmp 	.ret
	.negative:
	neg		ebx
	mov		eax, ebx
	clc
	.ret:
	pop		esi
	pop 	ebx
	pop 	edx
	pop 	ecx
	ret
	
is_dec:
	cmp		eax, 0
	jl		.not
	cmp		eax, 9
	jg		.not
	clc
	ret
	.not:
	stc
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
	
ReadBin: ; Reads a binary number into eax.
	push 	ecx
	push	ebx	
	push	esi
	xor		ebx, ebx
	xor 	eax, eax
	mov 	ecx, 40
	mov 	esi, input
	call	ReadStr
	xor		ecx, ecx
	dec 	ecx
	.in:
	inc 	ecx
	cmp		[esi + ecx], byte 0
	je		.exit
	mov		al, [esi + ecx]
	sub		eax, '0'
	call	is_bin
	jc		.error
	clc
	shl		ebx, 1
	jc		.error
	add		ebx, eax
	jmp		.in
	.error:
	stc
	jmp 	.ret
	.exit:
	mov		eax, ebx
	clc
	jmp 	.ret
	.ret:
	pop		esi
	pop 	ebx
	pop 	ecx
	ret
	
is_bin:
	cmp 	eax, 0
	jl		.not
	cmp		eax, 1
	jg		.not
	clc
	ret
	.not:
	stc
	ret
	
WriteBin: ; Outputs the binary number received in eax.
	pusha
	mov		ecx, 31
	mov 	esi, 4
	mov		ebx, eax
	.write:
	shl		ebx, 1
	mov 	eax, 0
	adc		eax, 0
	add		eax, '0'
	call	mio_writechar
	mov		eax, ecx
	cdq
	div		esi
	cmp		edx, 0
	jne		.no_space
	mov 	eax, ' '
	call	mio_writechar
	.no_space:
	dec		ecx
	cmp		ecx, 0
	jge 	.write
	popa
	ret
	
ReadHex: ; Reads a hexadecimal number into eax.
	push	ecx
	push	ebx
	push	esi
	xor 	ebx, ebx
	mov 	ecx, 15
	mov		esi, input
	call	ReadStr
	xor		ecx, ecx
	dec 	ecx
	.in:
	inc 	ecx
	cmp		[esi + ecx], byte 0
	je		.exit
	xor		eax, eax
	mov		al, [esi + ecx]
	call	is_hex
	jc		.error
	clc
	rol		ebx, 4
	jc		.error
	add		ebx, eax
	jmp		.in
	.error:
	stc
	jmp 	.ret
	.exit:
	clc
	mov		eax, ebx
	.ret:
	pop		esi
	pop		ebx
	pop		ecx
	ret
	
is_hex:
	cmp		eax, '0'
	jl		.not
	cmp		eax, '9'
	jg		.between_A_F
	sub		eax, '0'
	clc
	ret
	.between_A_F:
	cmp		eax, 'A'
	jl		.not
	cmp		eax, 'F'
	jg		.between_a_f
	sub		eax, 'A'
	add		eax, 10
	clc
	ret
	.between_a_f:
	cmp		eax, 'a'
	jl		.not
	cmp		eax, 'f'
	jg		.not
	sub		eax, 'a'
	add		eax, 10
	clc
	ret
	.not:
	stc
	ret
	
WriteHex: ; Outputs the hexadecimal number received in eax.
	pusha
	mov 	ecx, 8
	.out:
	mov		ebx, eax
	and		ebx, 0xF
	push	ebx
	shr		eax, 4
	dec		ecx
	cmp 	ecx, 0
	je		.write
	jmp		.out
	.write:
	pop		eax
	cmp		eax, 9
	jg		.letter
	add		al, '0'
	call	mio_writechar
	inc		ecx
	cmp		ecx, 8
	jl		.write
	popa
	ret
	.letter:
	add		eax, 'A'
	sub		eax, 10
	call	mio_writechar
	inc		ecx
	cmp		ecx, 8
	jl		.write
	popa
	ret
	
ReadInt64: ; Reads an integer into edx:eax.
	push 	ecx
	push	ebx	
	push	esi
	push 	edi
	push 	ebp
	xor 	ebp, ebp
	xor 	edx, edx
	xor 	eax, eax
	mov		esi, input
	mov 	ecx, 30
	call	ReadStr
	xor		ecx, ecx
	mov		bl, '-'
	cmp		[esi], bl
	je		.negative
	dec 	ecx
	.in:
	inc 	ecx
	cmp		[esi + ecx], byte 0
	je		.exit
	xor		ebx, ebx
	mov		bl, [esi + ecx]
	sub		ebx, '0'
	call	is_dec_64
	jc		.error
	imul	edx, 10
	jo		.error
	mov		edi, edx
	push 	ebx
	mov 	ebx, 10
	mul		ebx
	pop 	ebx
	add		edx, edi
	jo 		.error
	clc
	add		eax, ebx
	adc		edx, 0
	jo 		.error
	jmp		.in
	.error:
	stc
	jmp 	.ret
	.exit:
	cmp		ebp, 1
	je		.neg
	clc
	jmp 	.ret
	.negative:
	mov 	ebp, 1
	jmp 	.in
	.neg:
	neg		eax
	neg		edx
	dec 	edx
	clc
	.ret:
	pop 	ebp
	pop 	edi
	pop		esi
	pop 	ebx
	pop 	ecx
	ret
	
is_dec_64:
	cmp		ebx, 0
	jl		.not
	cmp		ebx, 9
	jg		.not
	clc
	ret
	.not:
	stc
	ret
	
WriteInt64: ; Outputs the integer received in ebx:eax. 
	pusha
	xor 	ecx, ecx
	cmp		edx, 0
	jl		.negative
	.next:
	mov		ebx, 10
	mov		esi, eax
	mov		eax, edx
	xor		edx, edx
	div		ebx
	mov		edi, eax
	mov 	eax, esi
	div		ebx 
	push	edx
	mov		edx, edi
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
	not		eax
	not 	edx
	add		eax, 1
	adc 	edx, 0
	jmp		.next
	
ReadBin64: ; Reads a binary number into edx:eax.
	push 	ecx
	push	ebx	
	push	esi
	xor		edx, edx
	xor 	eax, eax
	xor 	ebx, ebx
	mov 	ecx, 70
	mov 	esi, input
	call	ReadStr
	xor		ecx, ecx
	dec 	ecx
	.in:
	inc 	ecx
	cmp		[esi + ecx], byte 0
	je		.exit
	mov		bl, [esi + ecx]
	sub		ebx, '0'
	call	is_bin_64
	jc		.error
	clc
	shl		edx, 1
	jc		.error
	shl		eax, 1
	adc 	edx, 0
	add		eax, ebx
	jmp		.in
	.error:
	stc
	jmp 	.ret
	.exit:
	clc
	jmp 	.ret
	.ret:
	pop		esi
	pop 	ebx
	pop 	ecx
	ret
	
is_bin_64:
	cmp 	ebx, 0
	jl		.not
	cmp		ebx, 1
	jg		.not
	clc
	ret
	.not:
	stc
	ret
	
WriteBin64: ; Outputs the binary number received in edx:eax.
	pusha
	mov		ebx, eax
	mov 	eax, edx
	call	WriteBin
	mov		eax, ebx
	call	WriteBin
	popa
	ret
	
ReadHex64: ; Reads a hexadecimal number into edx:eax.
	push	ecx
	push	ebx
	push	esi
	xor 	eax, eax
	xor		edx, edx
	mov 	ecx, 20
	mov		esi, input
	call	ReadStr
	xor		ecx, ecx
	dec 	ecx
	.in:
	inc 	ecx
	cmp		[esi + ecx], byte 0
	je		.exit
	xor		ebx, ebx
	mov		bl, [esi + ecx]
	call	is_hex_64
	jc		.error
	clc
	clc
	shl		edx, 1
	jc		.error
	shl		eax, 1
	adc 	edx, 0
	clc
	shl		edx, 1
	jc		.error
	shl		eax, 1
	adc 	edx, 0
	clc
	shl		edx, 1
	jc		.error
	shl		eax, 1
	adc 	edx, 0
	clc
	shl		edx, 1
	jc		.error
	shl		eax, 1
	adc 	edx, 0
	add		eax, ebx
	jmp		.in
	.error:
	stc
	jmp 	.ret
	.exit:
	clc
	.ret:
	pop		esi
	pop		ebx
	pop		ecx
	ret
	
is_hex_64:
	cmp		ebx, '0'
	jl		.not
	cmp		ebx, '9'
	jg		.between_A_F
	sub		ebx, '0'
	clc
	ret
	.between_A_F:
	cmp		ebx, 'A'
	jl		.not
	cmp		ebx, 'F'
	jg		.between_a_f
	sub		ebx, 'A'
	add		ebx, 10
	clc
	ret
	.between_a_f:
	cmp		ebx, 'a'
	jl		.not
	cmp		ebx, 'f'
	jg		.not
	sub		ebx, 'a'
	add		ebx, 10
	clc
	ret
	.not:
	stc
	ret
	
WriteHex64: ; Outputs the hexadecimal number received in edx:eax.
	pusha
	mov		ebx, eax
	mov 	eax, edx
	call	WriteHex
	mov		eax, ebx
	call	WriteHex
	popa
	ret
	
section .bss
	input 	resb 256