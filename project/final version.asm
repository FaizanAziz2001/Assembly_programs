[org 0x0100]
jmp start



pcb: times 16*16 dw 0
mstack: times 16*256 dw 0
temp: dw 0
count: dw 0

nextpcb: dw 1 ; index of next free pcb 
current: dw 0 ; index of current pcb 
lineno: dw 0 ; line number for next thread 

old: dd 0
intvalues: dw 0,0,0

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


kernalsub:

		cmp ax,5700h
		jbe original


		mov bx,ax

		pop ax
		mov [cs:intvalues],ax						;pop the ip,cs and flag of kernalsub so it does not interfere with create thread
		pop ax
		mov [cs:intvalues+2],ax
		pop ax
		mov [cs:intvalues+4],ax


		mov ax,bx


		cmp ax,5800h								;58 is code for create
		je check1

		cmp ax,5900h								;59 is code for remove
		je check2


		cmp ax,6000h								;60 is code for suspend
		je check3

		cmp ax,6100h								;61 is code for resume
		je check4


		jmp retkernal

		check1:
			call createThread
			jmp retkernal

		check2:
			call removeThread
			jmp retkernal

		check3:
			call suspendthread
			jmp retkernal
		check4:
			call resumethread
			jmp retkernal


		retkernal:
			

			mov ax,[cs:intvalues+4]				;push the values of kernalsub back to return to original place
			push ax
			mov ax,[cs:intvalues+2]
			push ax
			mov ax,[cs:intvalues+0]
			push ax
			iret

		original:
				jmp far [cs:old]				;jump to the original int21h vector




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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getnext:
		mov bx,[cs:current]
		shl bx,5
		mov ax,0
		mov ch,1

		checksuspension:	
			mov al,[cs:pcb+bx]							;return the next in al
			mov bx,ax
			shl bx,5

			mov dx,[cs:pcb+bx+2]
			cmp ch,dh 									;1 is suspended
			je checksuspension

		ret

restorestate:
		mov bx,[cs:current]
		shl bx,5									;mul by 32
		mov cx,[cs:pcb+CXSAVE+bx]
		mov dx,[cs:pcb+DXSAVE+bx]
		mov di,[cs:pcb+DISAVE+bx]
		mov si,[cs:pcb+SISAVE+bx]
		mov bp,[cs:pcb+BPSAVE+bx]
		mov es,[cs:pcb+ESSAVE+bx]
		mov ds,[cs:pcb+DSSAVE+bx]

		pop ax
		mov [cs:temp],ax							;save return address before switching the stack
		
		cli
		mov ss,[cs:pcb+SSSAVE+bx]					;change stack ss:sp
		mov sp,[cs:pcb+SPSAVE+bx]
		sti

		
		mov ax,[cs:pcb+FLAGSSAVE+bx]				;push ip,cs,flag in new stack
		push ax
		mov ax,[cs:pcb+CSSAVE+bx]
		push ax
		mov ax,[cs:pcb+IPSAVE+bx]
		push ax

		mov ax,[cs:temp]							;push the return address to new stack
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
		mov ax,[bp-2]								; store bx in ax
		mov [cs:pcb+BXSAVE+bx],ax
		mov ax,[bp]									; store bp
		mov [cs:pcb+BPSAVE+bx],ax
		mov [cs:pcb+CXSAVE+bx],cx
		mov [cs:pcb+DXSAVE+bx],dx
		mov [cs:pcb+SISAVE+bx],si
		mov [cs:pcb+DISAVE+bx],di
		mov [cs:pcb+SSSAVE+bx],ss
		mov [cs:pcb+DSSAVE+bx],ds
		mov [cs:pcb+ESSAVE+bx],es
		
		mov ax,[bp+4]								;store ip cs flag from stack
		mov [cs:pcb+IPSAVE+bx],ax
		mov ax,[bp+6]
		mov [cs:pcb+CSSAVE+bx],ax
		mov ax,[bp+8]
		mov [cs:pcb+FLAGSSAVE+bx],ax

		mov ax,bp
		add ax,10									;store the original position of sp before calling the stack

		mov [cs:pcb+SPSAVE+bx],ax

		pop bx
		pop bp
		ret 6


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; subroutine to register a create a new thread and insert it into the link list of threads 
; takes the segment, offset, of the thread routine and a parameter 
; for the target thread subroutine 
createThread: 

		push bp
		mov bp,sp
		push ax
		push bx
		push cx
		push si

		push es
		push ds

		pop ax
		mov [cs:pcb+bx+DSSAVE],ax
		pop ax
		mov [cs:pcb+bx+ESSAVE],ax

		call getfreepcb

		cmp ax, 16 												; are all PCBs used 
 		je exit 												; yes, exit 

		mov [cs:nextpcb],ax
		mov bx,[cs:nextpcb]
		shl bx,5
		mov word[cs:pcb+bx+2],1    								;not free

		mov ax, [bp+8] 											; read segment parameter 
		mov [cs:pcb+bx+CSSAVE], ax 								; save in pcb space for cs 
		mov ax, [bp+6] 											; read offset parameter 
		mov [cs:pcb+bx+IPSAVE], ax 								; save in pcb space for ip 
		mov [cs:pcb+bx+SSSAVE], ds 								; set stack to our segment 


		mov si,[cs:nextpcb]
		shl si,9
		add si, 256*2+mstack 									; end of stack for this thread 

		mov ax, [bp+4] 											; read parameter for subroutine 
		sub si, 2 												; decrement thread stack pointer 
		mov [si], ax 											; pushing param on thread stack 
		sub si, 2 												; space for return address 
		mov [cs:pcb+bx+SPSAVE], si 								; save si in pcb space for sp 
		mov word [cs:pcb+bx+FLAGSSAVE], 0x0200 					; initialize thread flags 

		push word[cs:nextpcb]
		call insertThread


		exit: 
		pop si 
		pop cx 
		pop bx 
		pop ax 
		pop bp 
		ret 6 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;receives the pcb number to insert in link list in the BX register;;;;;;;;;;;;;;;;;;;;;;;;;

insertThread:
		push bp
		mov bp,sp
		push ax

		mov bx,[bp+4]
		shl bx,5

		mov ax, [cs:pcb] 			; read next of 0th thread in ax
		mov [cs:pcb+bx], ax 		; set as next of new thread

		mov ax, [bp+4] 			; read new thread index 
		mov [cs:pcb], ax 			; set as next of 0th thread


		pop ax
		pop bp
		ret 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;receives the pcb number to remove in link list in the BX register;;;;;;;;;;;;;;;;;;;;;;;;;

removeThread:
		push bp
		mov bp,sp
		push ax
		push si
		mov bx,[bp+4]
		mov si,bx
		inc si


		cmp bx,0
		je skipremove						; if thread number is 0,skip
		shl bx,5
		shl si,5

		mov ax,[cs:pcb+bx]					;remove the thread after bx
		mov [cs:pcb+si],ax

		mov word[cs:pcb+bx+2],0				;set it free

		skipremove:
		pop si
		pop ax
		pop bp
		ret 2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


getfreepcb:
			push bx
			push cx
			mov bx,1
			shl bx,5
			mov cx,16

			getfreeloop:
					mov ax,[cs:pcb+bx+2]
					cmp ax,0					;0 represents isfree
					je exitfreepcb
					add bx,32
					loop getfreeloop


			exitfreepcb:
						cmp cx,0				;if no one is free return 16
						jne skip
						pop cx
						pop bx
						mov ax,16
						ret
						

			skip:		
						mov ax,bx
						shr ax,5				;divide by 16 to get index
						pop cx
						pop bx
						ret		



suspendthread:
		push bp
		mov bp,sp
		mov bx,[bp+4]

		shl bx,5


		mov ax,[cs:pcb+bx+2]
		mov ah,1							; 1 means suspended
		mov [cs:pcb+bx+2],ax

		pop bp
		ret 2


resumethread:
		push bp
		mov bp,sp
		mov bx,[bp+4]

		shl bx,5

		mov ax,[cs:pcb+bx+2]
		mov ah,0							;  means free
		mov [cs:pcb+bx+2],ax

		pop bp
		ret 2



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
		xor ax,ax
		mov es,ax

		cli

		mov edx,[es:21h*4]								;store old kernal
		mov [old],edx

		mov word[es:21h*4],kernalsub					;hook new kernel vector
		mov  [es:21h*4+2],cs

		mov word[es:8*4],isr08							;hook new timer vector
		mov [es:8*4+2],cs
		sti


mov ax,3100h
int 0x21








