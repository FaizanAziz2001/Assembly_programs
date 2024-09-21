org 100h

jmp start

check: dw 65535,65530
num: dw 0xFFFF,0x0238, 0xADE9, 0x67EE, 0x7675, 0xF1E2, 0x1D11, 0x161C, 0xB65C, 0x201A, 0x6519, 0x7237, 0x3790, 0x6502, 0x2013, 0x10BA, 0x1938, 0x1202, 0x8362, 0xAC72, 0x8390, 0xCD92, 0x2213, 0x6675, 0x8778, 0x4AB9, 0xF765, 0xD738, 0x26AB, 0x0, 0x0, 0x0
num2: dw 0x9120, 0x7210, 0x1521, 0xEDD6, 0x625E, 0x6621, 0xF723, 0xFFFF, 0x31FF, 0x3726, 0x4DE2, 0x6125, 0x3623, 0xBC82, 0x8273, 0x8273, 0x9374, 0xBBCC, 0x8162, 0x9127, 0x2830, 0x2EF2, 0x2517, 0xAD71, 0x8754, 0x5712, 0x9ABC, 0x2362, 0xEDA7, 0x8162, 0xBCD2, 0xA128
temp: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
res: dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

copy: 	push cx
	push bx
	mov cx,32
	xor bx,bx


loopcopy:
	mov ax,[num+bx]
	mov [temp+bx],ax
	add bx,2
	loop loopcopy

	pop bx
	pop cx
	ret			



Exshr:
	push cx
	push bx
	mov cx,32
	mov bx,62
	CLC

loopeshr:
	rcr word[num2+bx],1
	dec bx
	dec bx
	loop loopeshr
	pop bx
	pop cx
	ret



Exadd:
	push cx
	push bx
	mov cx,64
	xor bx,bx
	CLC

loopadd:
	mov ax,[res+bx]
	adc ax,[temp+bx]
	mov [res+bx],ax
	inc bx
	inc bx
	loop loopadd
	pop bx
	pop cx
	ret



Exshl:
	push cx
	push bx
	mov cx,64
	xor bx,bx
	CLC

loopeshl:
	rcl word[temp+bx],1
	inc bx
	inc bx
	loop loopeshl
	pop bx
	pop cx
	ret



start:
	mov cx,512
	mov bx,0

	call copy

here:
	call Exshr
	jnc skipadd
	call Exadd
skipadd:
	call Exshl
	loop here

end:
mov ax,4c00h
int 21h



