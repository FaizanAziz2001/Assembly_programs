org 100h

jmp start
message:db '12345'
length:dw 5


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


print_string:
	pusha
	mov ax,0xb800
	mov es,ax
	mov di,message
	xor si,si

	mov cx,[length]
	mov ah,0x07
	here:
		mov al,[di]
		mov [es:si],ax
		add di,1
		add si,2
		loop here

	popa
	ret


print_num:
	pusha
	mov ax,123
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


start:
	call clrcls
	call print_num

mov ah,0x1			;wait for keypress
int 0x21

mov ax,0x4c00
int 0x21

		

