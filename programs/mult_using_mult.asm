org 100h


jmp start
num1:dd 12345678h,12345678h,12345678h,12345678h,56789abch,56789abch,56789abch,56789abch  ;256 bit number
num2:dd 87654321h,87654321h,87654321h,87654321h,12345678h,12345678h,12345678h,12345678h   ;256 bit number
result: times 16 dd 0h ;512 bit result

multiply:
	push bp
	mov bp,sp
	mov ebx,[bp+6]
	mov cx,[bp+4]
	xor di,di

	outerloop:
			CLC
			push di
			push cx
			mov cx,8
			xor si,si
			innerloop:
				mov eax,[num1+si]
				mov edx,[ebx]
				mul edx
				add [result+di],eax
				adc [result+di+4],edx
				add si,4
				add di,4
				loop innerloop

			pop cx
			pop di
			add di,4
			add ebx,4
			loop outerloop

	pop bp
	ret 4

start:
	mov eax,num2
	mov cx,8
	push eax
	push cx
	call multiply

end:
mov ax,4c00h
int 21h









