org 100h

jmp start

scrolldown: 
	push bp
	mov bp,sp
	pusha

	mov ax,0xb800
	mov es,ax
	mov ds,ax

	xor di,di
	mov ax,[bp+4]
	mov bx,80
	mov cx,2000


	mul bx				;calculate position and store it in ax
	sub cx,ax			;subtract to find number of iterations
	shl ax,1			;shr to multiply by 2 and convert it in number of words
	mov si,ax			;starting position of si

	cld
	rep movsw

	
	sub si,di			;find remaining iterations for spaces
	mov cx,si
	shr cx,1

	mov ax,0x0720
	rep stosw

	popa
	pop bp
	ret 2


scrollup:
	push bp
	mov bp,sp
	pusha

	mov ax,0xb800
	mov es,ax
	mov ds,ax

	mov di,3998
	mov ax,[bp+4]
	mov bx,80
	mov cx,2000

	mul bx
	sub cx,ax
	shl ax,1

	push di
	sub di,ax
	mov si,di
	pop di

	std
	rep movsw


	mov cx,di
	add cx,2
	shr cx,1

	mov ax,0x0720
	rep stosw

	popa
	pop bp
	ret 2


printc:
	mov ax,0xb800
	mov es,ax
	mov cx,25
	xor di,di
	mov ax,0x730
	here:
		push cx
		mov cx,80
		cld
		rep stosw

		add al,1
		pop cx
		loop here

	ret


cls:
	mov ax,0xb800
	mov es,ax
	mov cx,2000
	xor di,di
	label:
		mov word[es:di],0x0720
		add di,2
		loop label

	ret

start:
	call cls
	call printc
	mov ax,24
	push ax 
	;call scrollup
	;call scrolldown

mov ax,4c00h
int 21h

