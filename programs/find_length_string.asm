org 100h

jmp start
string:db 'Hello world',0
length: dw 0

find_length:
	push bp
	mov bp,sp
	push cx
	push di

	les di,[bp+4]
	xor ax,ax
	mov cx,0xffff

	repne scasb

	mov ax,0xffff
	sub ax,cx
	dec ax

	pop di
	pop cx
	pop bp

	ret 4

print:

	push bp
	mov bp,sp

	push ax
	push es
	push si
	push di

	mov ax,0xb800
	mov es,ax
	
	mov si,[bp+6]
	mov ah,0x07
	mov cx,[bp+4]
	xor di,di

	here:
	mov al,[si]
	mov [es:di],ax
	add di,2
	add si,1
	loop here

	pop di
	pop si
	pop es
	pop ax
	pop bp

	ret 4

cls:
	pusha
	mov ax,0xb800
	mov es,ax
	mov cx,2000
	mov ax,0x0720
	xor di,di

	cld			;increase di
	rep stosw	;source is ax,destination is es:di,inc di by 2 byts as well (sw)
				; rep cx times

	popa
	ret

start:
	push ds
	mov ax,string
	push ax
	call find_length
	mov [length],ax
	
	call cls
	mov ax,string
	push ax
	mov ax,[length]
	push ax
	call print

mov ax,4c00h
int 21h

