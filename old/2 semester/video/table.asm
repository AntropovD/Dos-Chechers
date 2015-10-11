.model tiny
.386
.code
org 100h
start:	

mov bx,(_sp-start+100h)/16
inc bx
mov ah,4ah
int 21h

pusha
push es
push ds
mov _ss,ss
mov _sp,sp 
 
mov word ptr [epb+4],cs
mov word ptr [epb+2], 080h
 
mov ax,4b00h
mov dx,offset nfile
mov bx,offset epb
int 21h

mov ss,_ss
mov sp,_sp 
pop ds
pop es
popa
 
ret

nfile db 'video\video.com',0
epb dw 7 dup (0)
_ss dw ?
_sp dw ?

end start
