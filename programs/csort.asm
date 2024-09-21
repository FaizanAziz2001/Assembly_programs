org 100h


jmp start
array: dw 5,15,10,9,1,55,18,66,2,75
code: db 0x72,0x77,0x7C,0x7F 
counter: dw 18
flagswap: dw 0
type: db 1         ;0 is uns asc,1 is uns desc,2 is sign asc,3 is sign dsc

start:
mov bx,0
mov bl,[type]
mov cl,[code+bx]
mov [CS:comp],cl

sort:
XOR ax,ax
XOR bx,bx
mov word[flagswap],0

iterate: 
mov ax,[array+bx]
mov dx,[array+bx+2]
cmp ax,dx
comp: je nochange

mov [array+bx],dx
mov [array+bx+2],ax
mov word[flagswap],1

nochange:
add bx,2
cmp bx,[counter]
jne iterate

cmp word[flagswap],0
jne sort

mov ax,4c00h
int 21h

