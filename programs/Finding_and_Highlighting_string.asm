org 100h

jmp start

string1: db 'string' , 0
length1: dw 0

string2: db 'This is a string comparison in a string on a string of a string check',0
length2: dw 0
index: db 0

strlen:
	push bp
	mov bp,sp
	
	push es
	push di
	push cx


	mov ax,ds
	mov es,ax

	mov di,[bp+4]
	mov al,0
	mov cx,0xFFFF

	repne scasb

	mov ax,0xFFFF
	sub ax,cx
	dec ax

	pop cx
	pop di
	pop es
	pop bp
	ret 2

clrcls:
	pusha
	mov ax,0xb800
	mov es,ax
	xor di,di
	mov cx,2000

	mov ax,0x0720
	rep stosw

	popa
	ret


print_string:
	pusha
	mov ax,0xb800
	mov es,ax
	mov si,string2
	xor di,di

	mov cx,[length2]
	mov ah,0x07
	here_string:
		mov al,[si]
		mov [es:di],ax
		add di,2
		add si,1
		loop here_string

	popa
	ret


comparestring:
	push bp
	mov bp,sp
	pusha

	mov ax,0xb800
	mov es,ax

	mov si,[bp+4]
	mov bx,[length1]

	shl word[length2],1

	xor cx,cx
	xor ax,ax
	xor dx,dx
	xor di,di

	here:
		
		mov al,[es:di]
		mov dl,[si]
		cmp al,dl
		jne skip						; skip if starting character is not same

		mov [index],cx
		push dx
		push cx
		push si
		push di
		
		mov cx,bx
		xor dx,dx

		comp:
			mov dl,[si]
			cmp [es:di],dl
			jne break
			add di,2
			add si,1
			loop comp

		break:
			jcxz set						; if cx(length1) is 0,jump to set
			jmp move
		
		set:
			call highlight

		move:
			pop di
			pop si							; return original length1 if strings are not equal
			pop cx							; return original count
			pop dx

		skip:
			add di,2
			add cx,2
			cmp cx,[length2]
			jne here

	shr word[length2],1
	popa
	pop bp
	ret 							


highlight:
	pusha

	mov si,string1
	mov cx,[length1]
	mov ah,0x04
	mov di,[index]

	loop_h:
		mov al,[si]
		mov [es:di],ax
		add si,1
		add di,2
		loop loop_h


	popa
	ret

start: 
	mov ax,string1
	push ax
	call strlen
	mov [length1],ax

	mov ax,string2
	push ax
	call strlen
	mov [length2],ax

	call clrcls
	call print_string

	mov ax,string1
	push ax
	call comparestring

mov ax,4c00h
int 21h

