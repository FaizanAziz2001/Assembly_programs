org 100h

jmp start

delay:
	push ecx
	mov ecx,1000000000
	loop_here1:
		loop loop_here1

	mov ecx,1000000000
	loop_here2:
		loop loop_here2

	mov ecx,1000000000
	loop_here3:
		loop loop_here3

	pop ecx
	ret
	
printstar:
		mov word[es:di],0x072a					;character
		mov word[es:si],0x072a
		call delay
		
		mov word[es:si],0x0720
		mov word[es:di],0x0720
		ret


print:
	pusha
	mov ax,0xb800
	mov es,ax

	mov si,2080								;coordinates
	mov di,1920	

	print_loop_forward:
		call printstar
		add di,2
		sub si,2
		cmp di ,2000
		jne print_loop_forward

	print_loop_backward:
		call printstar
		sub di,2
		add si,2
		cmp di ,1920
		jne print_loop_backward

	popa
	ret


infinite_loop:
	push cx
	mov cx,2					;number of iterations

	infinite_here:
			call print
			loop infinite_here
	pop cx
	ret

start:
	call infinite_loop

end:
	mov ah,0x1			;wait for keypress
	int 0x21

	mov ax,0x4c00
	int 0x21

		



