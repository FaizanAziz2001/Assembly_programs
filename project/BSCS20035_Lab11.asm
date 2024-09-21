[org 0x0100]
jmp start



pcb: times 16*16 dw 0
mstack: times 16*256 dw 0
temp: dw 0
count: dw 0
nextpcb: 0

nextpcb: dw 1 ; index of next free pcb 
current: dw 0 ; index of current pcb 
lineno: dw 0 ; line number for next thread 

AXSAVE equ 0x04
BXSAVE equ 0x06
CXSAVE equ 0x08
DXSAVE equ 0x0A
SISAVE equ 0x0C
DISAVE equ 0x0E
BPSAVE equ 0x10
SPSAVE equ 0x12
CSSAVE equ 0x14
DSSAVE equ 0x16
ESSAVE equ 0x18
SSSAVE equ 0x1A
IPSAVE equ 0x1C
FLAGSSAVE equ 0x1E


getnext:
		mov bx,[cs:current]
		shl bx,5

		mov ah,0
		mov al,[cs:pcb+bx]
		ret

restorestate:
		mov bx,[cs:current]
		shl bx,5
		mov cx,[cs:pcb+CXSAVE+bx]
		mov dx,[cs:pcb+DXSAVE+bx]
		mov di,[cs:pcb+DISAVE+bx]
		mov si,[cs:pcb+SISAVE+bx]
		mov bp,[cs:pcb+BPSAVE+bx]
		mov es,[cs:pcb+ESSAVE+bx]
		mov ds,[cs:pcb+DSSAVE+bx]

		cli
		mov ss,[cs:pcb+SSSAVE+bx]
		mov sp,[cs:pcb+SPSAVE+bx]
		sti

		pop ax
		mov [cs:temp],ax


		mov ax,[cs:pcb+FLAGSSAVE+bx]
		push ax
		mov ax,[cs:pcb+CSSAVE+bx]
		push ax
		mov ax,[cs:pcb+IPSAVE+bx]
		push ax

		mov ax,[cs:temp]
		push ax

		mov ax,[CS:pcb+AXSAVE+bx]
		mov bx,[CS:pcb+BXSAVE+bx]
		ret

savestate:
		push bp
		mov bp,sp
		push bx
		mov bx,[cs:current]
		shl bx,5
		mov [cs:pcb+AXSAVE+bx],ax
		mov ax,[bp-2]
		mov [cs:pcb+BXSAVE+bx],ax
		mov ax,[bp]
		mov [cs:pcb+BPSAVE+bx],ax
		mov [cs:pcb+CXSAVE+bx],cx
		mov [cs:pcb+DXSAVE+bx],dx
		mov [cs:pcb+SISAVE+bx],si
		mov [cs:pcb+DISAVE+bx],di
		mov [cs:pcb+SSSAVE+bx],ss
		mov [cs:pcb+DSSAVE+bx],ds
		mov [cs:pcb+ESSAVE+bx],es
		
		mov ax,[bp+4]
		mov [cs:pcb+IPSAVE+bx],ax
		mov ax,[bp+6]
		mov [cs:pcb+CSSAVE+bx],ax
		mov ax,[bp+8]
		mov [cs:pcb+FLAGSSAVE+bx],ax

		mov ax,bp
		add ax,10

		mov [cs:pcb+SPSAVE+bx],ax

		pop bx
		pop bp
		ret 6


isr08:
		call savestate
		call getnext

		mov [cs:current],ax

		call restorestate

		push ax
		mov al,0x20
		out 0x20,al
		pop ax
		iret

start:
		xor ax,ax
		mov es,ax

		cli
		mov word[es:8*4],isr08
		mov [es:8*4+2],cs
		sti

		mov cx, 4

nextkey:


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
nextdigit: mov dx, 0 ; zero upper half of dividend 
 div bx ; divide by 10 
 add dl, 0x30 ; convert digit into ascii value 
 cmp dl, 0x39 ; is the digit an alphabet 
 jbe skipalpha ; no, skip addition 
 add dl, 7 ; yes, make in alphabet code 
skipalpha: mov dh, 0x07 ; attach normal attribute 
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
printagain: push ax ; line number 
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
 
 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Create thread;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
create_thread:
				push bp
				mov bp,sp
				push ax
				push bx
				push dx
				push cx
				push si

				push es
				push ds
				call getfreepcb
				mov [nextpcb],ax
				mov bx,ax				
				shl bx,5
				pop ax
				mov [cs:pcb+bx+DSSAVE],ax
				pop ax
				mov [cs:pcb+bx+ESSAVE],ax
				mov word[cs:pcb+bx+FLAGSSAVE],0x200

				mov ax,[bp+8]
				mov [cs:pcb+bx+CSSAVE],ax

				mov ax,[bp+6]
				mov [cs:pcb+bx+IPSAVE],ax

				mov ax,[nextpcb]
				shl ax,9
				add ax,512*mstack

				mov si,ax
				mov ax,[bp+4]
				sub si,2
				mov [si],ax
				mov [cs:pcb+bx+SPSAVE],si

				

				mov word[cs:pcb+bx+AXSAVE],0
				mov word[cs:pcb+bx+BXSAVE],0
				mov word[cs:pcb+bx+CXSAVE],0
				mov word[cs:pcb+bx+DXSAVE],0
				mov word[cs:pcb+bx+SISAVE],0
				mov word[cs:pcb+bx+DISAVE],0
				mov word[cs:pcb+bx+BPSAVE],0

				pop si
				pop cx
				pop dx
				pop bx
				pop ax
				pop bp
				ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;receives the pcb number to insert in link list in the BX register;;;;;;;;;;;;;;;;;;;;;;;;;

insertThread:
push ax
push cx 
mov cx,bx
shl bx,5

mov ax, [pcb] ; read next of 0th thread in ax
mov [pcb+bx], ax ; set as next of new thread
; New thread index is in CX
mov [pcb], cx ; set as next of 0th thread

pop cx
pop ax
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;receives the pcb number to remove in link list in the BX register;;;;;;;;;;;;;;;;;;;;;;;;;

removeThread:

push ax
push cx 
mov si,bx
shl si,5

dec bx
shl bx,5				;go a step back to get next

mov ax,[pcb+si]				
mov [pcb+bx],ax			; break the link

mov ax,1
mov [pcb+si],ax			; set the frees

pop cx
pop ax
ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


getfreepcb:
			mov bx,1
			shl bx,5
			mov cx,16

			getfreeloop:
					mov ax,[cs:pcb+bx+2]
					cmp al,1				;;1 represents isfree
					je exitfreepcb
					add bx,32
					loop getfreeloop


			exitfreepcb:
						cmp cx,0
						ret
						jne skip

			skip:		mov ax,bx
						shr ax,5
						ret		




			










