org 100h

mov cx,2
XOR bx,bx
CLC

iterate:
rcr word[num+bx],1
inc bx
inc bx
loop iterate

mov ax,4c00h
int 21h

num: dw 65535,65530


