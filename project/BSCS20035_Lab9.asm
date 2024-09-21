[org 0x0100]
jmp start



pcb: times 16*16 dw 0
mstack: times 16*256 dw 0
temp: dw 0
count: dw 0

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
		xor ah, ah ; service 0 – get keystroke 
		int 0x16 ; bios keyboard services 
		push cs ; use current code segment 
		mov ax, mytask 
		push ax ; use mytask as offset 
		push word [lineno] ; thread parameter 
		call initpcb ; create the thread and insert 
		inc word [lineno] ; update line number 
		loop nextkey ; wait for next keypress 
		jmp $

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
 
 
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This following subroutine is the alternative for create and insert thread that we discussed yesterday;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; subroutine to register a create a new thread and insert it into the link list of threads 
; takes the segment, offset, of the thread routine and a parameter 
; for the target thread subroutine 
initpcb: 
 push bp 
 mov bp, sp 
 push ax 
 push bx 
 push cx 
 push si 
 mov bx, [nextpcb] ; read next available pcb index 
 cmp bx, 16 ; are all PCBs used 
 je exit ; yes, exit 
 mov cl, 4 
 shl bx, cl ; multiply by 16 for pcb start 
 mov ax, [bp+8] ; read segment parameter 
 mov [pcb+bx+CSSAVE], ax ; save in pcb space for cs 
 mov ax, [bp+6] ; read offset parameter 
 mov [pcb+bx+IPSAVE], ax ; save in pcb space for ip 
 mov [pcb+bx+SSSAVE], ds ; set stack to our segment 
 mov si, [nextpcb] ; read this pcb index 
 mov cl, 9 
 shl si, cl ; multiply by 512 
 add si, 256*2+mstack ; end of stack for this thread 
 mov ax, [bp+4] ; read parameter for subroutine 
 sub si, 2 ; decrement thread stack pointer 
 mov [si], ax ; pushing param on thread stack 
 sub si, 2 ; space for return address 
 mov [pcb+bx+SPSAVE], si ; save si in pcb space for sp 
 mov word [pcb+bx+FLAGSSAVE], 0x0200 ; initialize thread flags 
 mov ax, [pcb+0] ; read next of 0th thread in ax 
 mov [pcb+bx+0], ax ; set as next of new thread 
 mov ax, [nextpcb] ; read new thread index 
 mov [pcb+0], ax ; set as next of 0th thread 
 inc word [nextpcb] ; this pcb is now used 
exit: 
 pop si 
 pop cx 
 pop bx 
 pop ax 
 pop bp 
 ret 6 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;









