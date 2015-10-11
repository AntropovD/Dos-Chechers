.model tiny
.code
org 100h

start:
	jmp Resident
	
	int21_proc proc	
	jmp dword ptr cs:[vector]
	ret
	
	
	
	my_msg db 'My Message', 0dh,0ah,024h
	vector dd ?	
	int21_proc endp
	
	
Resident:		
	mov ah, 35h
	mov al, 21h
	int 21h
	
	mov word ptr vector, bx
	mov word ptr vector+2, es
	
	mov ah, 25h
	mov al, 21h
	mov dx, offset int21_proc
	int 21h
	
	mov dx, bx
	
	push es
	pop bx
	
	
	xor ax, ax
	mov al, bh
	call output
	xor ax, ax
	mov  al, bl
	call output
	
	mov ah, 02h;
	mov dl, 03ah;
	int 21h;
	
	mov bx, dx
	xor ax, ax	
	mov al, bh
	call output
	xor ax, ax
	mov al, bl
	call output
	
	
	
	mov ah, 31h	
	mov dx, offset Resident
	int 21h	

		
	output proc near
	mov dl, 10h;
	div dl;
	
	cmp al, 09h;
	jg mark1;
	add al, '0';
mark3:	
	cmp ah, 09h;
	jg mark2;
	add ah, '0'	
mark4:	
	mov cx, ax;
	mov ah, 02h;
	mov dl, cl;
	int 21h;

	mov ah, 02h;
	mov dl, ch;
	int 21h;	 
	ret	

mark1:
;	sub al, 0Ah;
	add al, 37h;
	jmp mark3;
mark2:
;	sub ah, 0ah;
	add ah, 37h;
	jmp mark4;
output endp

end start
	