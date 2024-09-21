org 100h

jmp start

string1: db 'string' , 0
length1: dw 6

string2: db 'This is a string comparison',0
length2: dw 27

flag: db 0


comparestring:
	push bp
	mov bp,sp
	pusha

	mov si,[bp+12]						; load string1 in ds:si
	mov ds,[bp+14]

	mov di,[bp+6]						; load string2 in es:di
	mov es,[bp+8]

	mov bx,[bp+10]						; load length1 in bx
	mov cx,[bp+4]						; load length2 in cx

	xor ax,ax
	xor dx,dx

	here:
		
		mov al,[es:di]
		mov dl,[ds:si]
		cmp al,dl
		jne skip						; skip if starting character is not same

		push cx
		push si
		mov cx,bx
		repe cmpsb						; compare rest of the substring
		jcxz set						; if cx(length1) is 0,move to exit

		pop si							; return original length1 if strings are not equal
		pop cx							; return original count

		skip:
			add di,1
			loop here

		jmp exit

	set:
		pop si
		pop cx
		mov byte[flag],1

	exit:
		popa
		pop bp
		ret 12							; 6 parameters in subroutine


start: 
	push ds								
	mov ax,string1
	mov bx,[length1]
	push ax
	push bx

	push ds								
	mov ax,string2
	mov bx,[length2]
	push ax
	push bx

	call comparestring

mov ax,4c00h
int 21h

