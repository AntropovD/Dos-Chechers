.model tiny
.code
org 100h

start:	
	mov ah, 9
	mov dx, offset msg
	int 21h
		
	int 20h	
	
	ret
msg db 'Check program.', 0dh, 0ah, 024h
end start
	