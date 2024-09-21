[org 0x0100]
jmp start


count: dw 10
old: dd 0

timer:
	push ax
	cmp ax,5700h
	jbe skip

	cmp ax,5800h
	je printA

	cmp ax,5900h
	je printB

	jmp return

	printA:
			mov ax,0x41
			push ax
			call print_num
			jmp return

	printB:
			mov ax,0x42
			push ax
			call print_num
			jmp return


	return:
		pop ax
		iret


skip:	
		pop ax
		jmp far [cs:old]

start:
		xor ax,ax
		mov es,ax
		cli
		mov edx,[es:21h*4]
		mov [old],edx
		
		mov word[es:21h*4],timer
		mov [es:21h*4+2],cs
		sti


mov ax,5800h
int 21h


mov ax,0100h
int 21h

mov ax,5900h
int 21h


xor ax,ax
mov es,ax
cli
mov edx,[old]
mov [es:21h*4],edx
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
	push bp
	mov bp,sp 
	pusha

	mov dx,[bp+4]

	mov ax,0xb800
	mov es,ax
	mov di,0


		mov dh,0x07
		mov [es:di],dx

	popa
	pop bp
	ret 2


