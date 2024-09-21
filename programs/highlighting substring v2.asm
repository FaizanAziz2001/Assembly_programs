[org 0x0100]
jmp start


string1: db 'string' , 0
length1: dw 0

string2: db 'This is a string comparison in a string on a string of a string check',0
length2: dw 0
index: dw 0
count: dw 0


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
	xor ax,ax

	mov cx,[cs:length2]
	mov ah,0x07
	here_string:
		mov al,[cs:si]
		mov word[es:di],ax
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

	mov si,string1
	mov bx,[cs:length1]

	shl word[cs:length2],1

	xor cx,cx
	xor ax,ax
	xor dx,dx
	xor di,di

	here:
		
		mov al,[es:di]
		mov dl,[cs:si]
		cmp al,dl
		jne skip						; skip if starting character is not same

		mov [cs:index],cx
		push dx
		push cx
		push si
		push di
		
		mov cx,bx
		xor dx,dx

		comp:
			mov dl,[cs:si]
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
			cmp cx,[cs:length2]
			jne here


		shr word[cs:length2],1
		xor ax,ax
		mov es,ax
		cli
		mov word[es:8*4],isr08
		mov [es:8*4+2],cs
		sti

	popa
	pop bp

	ret 						


highlight:
	pusha

	mov si,string1
	mov cx,[cs:length1]
	mov ah,11000111b
	mov di,[cs:index]

	loop_h:
		mov al,[cs:si]
		mov [es:di],ax
		add si,1
		add di,2
		loop loop_h

	popa
	ret

isr08:
	cmp word[count],182
	je exit

	pusha
	inc word[cs:count]
	mov ax,[cs:count]
	push ax
	call printnum

	mov al,0x20
	out 0x20 ,al
	popa
	
	iret

exit:
	call print_string
	mov al,0x20
	out 0x20 ,al
	iret

start:
	
	
	mov ax,string1
	push ax 
	call strlen
	mov [cs:length1],ax

	mov ax,string2
	push ax
	call strlen
	mov [cs:length2],ax

	call print_string
	call comparestring


	jmp $
	mov ax,4c00h
	int 0x21



printnum: 
	push bp
	mov bp, sp
	push es
	push ax
	push bx
	push cx
	push dx
	mov ax, 0xb800
	mov es, ax ; point es to video base
	mov ax, [bp+4] ; load number in ax
	mov bx, 10 ; use base 10 for division
	mov cx, 0 ; initialize count of digits
	mov di,280


nextdigit: 
	mov dx, 0 ; zero upper half of dividend
	div bx ; divide by 10
	add dl, 0x30 ; convert digit into ascii value
	push dx ; save ascii value on stack
	inc cx ; increment count of values
	cmp ax, 0 ; is the quotient zero
	jnz nextdigit ; if no divide it again

nextpos: 
	pop dx ; remove a digit from the stack
	mov dh, 0x07 ; use normal attribute
	mov [es:di], dx ; print char on screen
	add di, 2 ; move to next screen location
	loop nextpos ; repeat for all digits on stack
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop bp
	ret 2