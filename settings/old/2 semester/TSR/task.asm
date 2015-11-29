.model tiny
.code
org 100h

start:
	mov ah, 9
	mov dx, offset msg
	int 21h
	
	mov ax, cs:[2Ch]
	push ax
	pop es
	mov ah, 49h
	int 21h

	mov ah, 48h
	mov bx, 1
	int 21h
	
	mov cs:[2ch], ax
	push ax
	pop es
	
	mov cx, 14
	mov di, 0
	mov si, offset nam
	rep movsb	
	
	mov ah, 31h
	mov dx, 11h
	int 21h	
	
	ret
msg db 'Hello, TSR', 0dh, 0ah, 024h
nam db 'Name', 00h,00h,01h,'XE.com',00h
end start
	