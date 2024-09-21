org 100h

jmp start
hex_string:db "0000",0
array: dw 5,15,10,1,20,-15,-2,-5,-64,-24
code: db 0x7C,0x7F
max: dw 0
type: db 1



set:
	mov bx,0
	mov bl,[type]
	mov al,[code+bx]
	mov [cs:condition],al
	ret

max_find:
	push bp
	mov bp,sp
	mov bx,[bp+6]
	mov cx,[bp+4]
	
	xor ax,ax
	xor si,si

		here:
			mov ax,[bx]
			cmp ax,[max]
		condition:	
			jle	skip
			mov [max],ax

		skip:
			add bx,2
			loop here

	pop bp
	ret 4

start:
	call set
	mov ax,array
	mov cx,10
	push ax
	push cx
	call max_find

	mov ax,max
	push ax
	call print_string
	pop ax

end:
mov ax,4c00h
int 21h


print_string:

	push bp
	mov bp,sp
	mov di,[bp+4]
	mov si,0

	push di
	call hex_convert
	call print
	pop di
	
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

