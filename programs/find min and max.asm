org 100h

jmp start

array: dw 1 ,5 ,2 ,8 ,10 ,15 ,3
max: dw 0
min: dw 0


find:
	push bp
	mov bp,sp
	pusha

	mov bx,[bp+6]
	mov cx,[bp+4]

	mov dx,[bx]
	mov word[max],dx
	mov word[min],dx

	add bx,2
	dec cx
	here:
		mov dx,[bx]
		cmp word[max],dx
		ja checkmin
		mov word[max],dx


	checkmin:
		cmp word[min],dx
		jb skip
		mov word[min],dx

	skip:
		add bx,2
		loop here

	popa
	pop bp
	ret 4

start: 
	mov ax, array
	push ax
	mov cx, 7
	push cx
	call find

mov ax,4c00h
int 21h

