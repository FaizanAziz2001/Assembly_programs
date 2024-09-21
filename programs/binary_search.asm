org 100h

jmp start

array: dw 1 ,5 ,2 ,8 ,10 ,15 ,3
s: dw 0
end: dw 12
flag: db 0
target: dw 11

find:
	push bp
	mov bp,sp
	pusha

	mov si,[bp+6]
	mov cx,[bp+4]

	here:
		mov bx,[s]
		cmp bx,[end]
		ja break

		add bx,[end]
		shr bx,1

		mov dx,[si+bx]
		cmp dx,[target]
		je true
		ja high
		jb low



	low:
		mov word[s],bx
		add word[s],2
		jmp here

	high:
		mov word[end],bx
		sub word[end],2
		jmp here


		
	true:
		mov byte[flag],1
	break:
		popa
		pop bp

		mov ax,0
		mov ax,[flag]

	ret 4

start: 
	mov ax, array
	push ax
	mov cx, 7
	push cx
	call find

mov ax,4c00h
int 21h

