[org 0x0100]
jmp start


count: dw 0
old: dw 0,0

timer:
	inc word[cs:count]
	call print_num

	mov al, 0x20
	out 0x20, al
	iret



start:
		xor ax,ax
		mov es,ax
		cli
		mov ax,[es:8*4]
		mov [old],ax
		mov ax,[es:8*4+2]
		mov [old+2],ax


		mov word[es:8*4],timer
		mov [es:8*4+2],cs
		sti

		here:
			mov cx,100
			cmp word[count],100
			je exit
			loop here



exit:
xor ax,ax
mov es,ax
cli
mov ax,[old]
mov word[es:8*4],ax
mov ax,[old+2]
mov [es:8*4+2],ax
sti

mov ax,4c00h
int 21h































;;;;;;;;;;;;;;;;;;;;;
clrcls:
	pusha
	mov ax,0xb800
	mov es,ax
	xor di,di
	mov cx,2000

	loop_here:
		mov word[es:di],0x0720
		add di,2
		loop loop_here

	popa
	ret


print_num:
	pusha
	mov ax,[count]
	mov bx,10
	mov cx,3

	num_loop:
		mov dx,0
		div bx
		add dl,0x30
		push dx
		loop num_loop

	mov ax,0xb800
	mov es,ax
	xor di,di
	mov cx,3

	
	print_loop:
		pop dx
		mov dh,0x07
		mov [es:di],dx
		add di,2
		loop print_loop

	popa
	ret


