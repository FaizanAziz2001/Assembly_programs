org 100h

jmp start

num:dw 5

fact:
	xor ax,ax
	xor bx,bx
	mov ax,[num]
	mov bx,[num]
	mov cx,0xffff
here:

	dec bx
	cmp bx,0
	je break
	mul bx
	loop here

break:
	mov [num],ax
	ret

start: 
	call fact

mov ax,4c00h
int 21h

