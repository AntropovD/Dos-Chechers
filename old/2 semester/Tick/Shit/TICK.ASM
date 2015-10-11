.model tiny
.code
org 100h

start:
	jmp Main
	
	int8_proc proc					
		
		mov cx, count
		inc cx
		cmp cx, 12h
		je not_10th_tick
		mov count, 0
		stc
		
	not_10th_tick:
	mov count, cs
	ret
	
	vector dd ?	
	count dw ?
	int8_proc endp
	msg db 'Check ', 0dh, 0ah, 024h
	
		
  Main:	
	; mov ah, 35h
	; mov al, 8h
	; int 21h
	
	; mov word ptr vector, bx
	; mov word ptr vector+2, es
	
	mov ah, 25h
	mov al, 8h
	mov dx, offset int8_proc	
	int 21h
	
	clc
	_loop:	
	
	jc print	
	return_print:
		
	jmp _loop
	
	exit:	
		int 20h	
		
	print:
		mov ah, 9
		mov dx, offset msg
		int 21h
		jmp return_print
		
end start


; p:
		; mov ax, 0003h
		; int 10h		
		; mov ah, 01h
		; int 21h				
		
		; cmp ax, 011bh
		; je exit		
		
		; mov dx, 0B800h
		; push dx
		; pop es
		
		; mov dx, 09b0h
		; mov word ptr es:[1d60h],  32h
		; inc cx
	