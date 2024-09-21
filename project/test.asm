[org 0x0100]
jmp start


lineno: dw 0 ; line number for next thread 

start:
		mov cx, 16
nextkey:
		xor ah, ah
		int 0x16 ; bios keyboard services 

		push cs ; use current code segment 
		mov ax, mytask 
		push ax ; use mytask as offset 
		push word [lineno] ; thread parameter 

		mov ax,5800h
		int 21h

		inc word [lineno] ; update line number 

		loop nextkey


		xor ah, ah
		int 0x16 										; bios keyboard services 

		mov ax,5
		push ax
		mov ax,5900h									;remove thread 5
		int 0x21


		xor ah, ah
		int 0x16 										; bios keyboard services 
		mov ax,7
		push ax											;suspend thread 7
		mov ax,6000h
		int 0x21


		
		xor ah, ah
		int 0x16 										; bios keyboard services 
		mov ax,7
		push ax											;resume thread 7
		mov ax,6100h
		int 0x21


mov ax,4c00h
int 0x21

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PRINTS THE NUMBER PASSED VIA STACK AT A SPECIFIC LOCATION ON SCREEN;;;;;;
printnum: 
		push bp 
		mov bp, sp 
		push es 
		push ax 
		push bx 
		push cx
		push dx 
		push di 
		mov di, 80 ; load di with columns per row 
		mov ax, [bp+8] ; load ax with row number 
		mul di ; multiply with columns per row 
		mov di, ax ; save result in di 
		add di, [bp+6] ; add column number 
		shl di, 1 ; turn into byte count 
		add di, 8 ; to end of number location 
		mov ax, 0xb800 
		mov es, ax ; point es to video base 
		mov ax, [bp+4] ; load number in ax 
		mov bx, 16 ; use base 16 for division 
		mov cx, 4 ; initialize count of digits 
nextdigit:
		mov dx, 0 ; zero upper half of dividend 
		div bx ; divide by 10 
		add dl, 0x30 ; convert digit into ascii value 
		cmp dl, 0x39 ; is the digit an alphabet 
		jbe skipalpha ; no, skip addition 
		add dl, 7 ; yes, make in alphabet code 
skipalpha:
		mov dh, 0x07 ; attach normal attribute 
		mov [es:di], dx ; print char on screen 
		sub di, 2 ; to previous screen location 
		loop nextdigit ; if no divide it again 
		pop di 
		pop dx 
		pop cx 
		pop bx 
		pop ax 
		pop es 
		pop bp 
		ret 6 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Threads will be run for the following task;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; It increments and prints a number on a specific line for a specific task
mytask: push bp 
		mov bp, sp 
		sub sp, 2 ; thread local variable 
		push ax 
		push bx 
		mov ax, [bp+4] ; load line number parameter 
		mov bx, 70 ; use column number 70 
		mov word [bp-2], 0 ; initialize local variable 
printagain:
		push ax ; line number 
		push bx ; column number 
		push word [bp-2] ; number to be printed 
		call printnum ; print the number 
		inc word [bp-2] ; increment the local variable 
		jmp printagain ; infinitely print 
		pop bx 
		pop ax 
		mov sp, bp 
		pop bp 
		ret 
		
		