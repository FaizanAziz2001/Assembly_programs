org 100h

jmp start

hex_string: db '0000 '
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

	mov ax,res+126
	mov cx,64
	push ax
	push cx
	
	call print_string

	pop cx
	pop ax


end:
mov ax,4c00h
int 21h

print_string:

	
	push bp
	mov bp,sp
	mov di,[bp+6]
	mov cx,[bp+4]
	mov si,0

loop_here:
	push di
	call hex_convert
	call print
	pop di
	
	sub di,2
	loop loop_here

	pop bp
	ret 

hex_convert:
	push si
	push cx
	push bx

	mov si,hex_string
	mov cx,0

next_character:
	inc cx
	mov bx,[di]
	and bx,0xf000
	shr bx,4
	add bh,0x30
	
	cmp bh,0x39
	jg add_7

add_character_hex:
	mov [si],bh
	inc si
	shl word[di],4
	cmp cx,4
	jnz next_character
	jmp _done

_done:
	mov di, hex_string
	pop bx
	pop cx
	pop si
	ret

print:
	push ax
	push es
	push cx
	mov ax,0xb800
	mov es,ax
	mov ah,0x07
	mov cx,5
	

next_char:
	mov al,[di]
	mov [es:si],ax
	add si,2
	add di,1
	loop next_char

	pop cx
	pop es
	pop ax
	ret
	
	
add_7:
	add bh,0x7
	jmp add_character_hex





