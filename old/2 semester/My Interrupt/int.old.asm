.model tiny
.code
org 100h

start:
	jmp Resident
	
	int21_proc proc
	
	cmp ah, 09h	
	je Ok
	jmp dword ptr cs:[vector]
	
	Ok:	
	push ds; сохраняем регистры
	push dx;
	push cs; Адрес строки должен быть в ds:dx
	pop ds
	
	
	mov dx, offset my_msg
	pushf
	call dword ptr cs:[vector]
	pop dx
	pop ds
	iret
	
	
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

	mov ah, 31h	
	mov dx, offset Resident
	int 21h	
		

end start
	