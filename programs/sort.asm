org 100h

jmp start
array: dw 5,15,10,1
counter: dw 3
flagswap: dw 0


start:
XOR ax,ax
XOR bx,bx
mov word[flagswap],0
mov cx,0

iterate: 
mov ax,[array+bx]
mov dx,[array+bx+2]
cmp ax,dx
jbe nochange

mov [array+bx],dx
mov [array+bx+2],ax
mov word[flagswap],1

nochange:
add bx,2
add cx,1
cmp cx,[counter]
jne iterate

dec word[counter]
cmp word[counter],0
je end
cmp word[flagswap],0
jne start

end:
mov ax,4c00h
int 21h

