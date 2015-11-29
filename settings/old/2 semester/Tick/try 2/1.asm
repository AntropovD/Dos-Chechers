.model tiny
.code
org 100h

start:
	mov ax, 3
	int 10h	

	mov ax, 351ch
	int 21h
	
	mov word ptr vector_old, bx
	mov word ptr vector_old+2, es
	
	mov ax, 251ch
	mov dx, offset timer_tick
	int 21h				
	
	mov ax, 4c00h
	int 21h
	
	
	timer_tick proc	
		push cs
		mov cx, timer_count
		inc cx				
		cmp cx, 18
		jl not_second_tick
		mov timer_flag, 1
		mov cx, 0		
	not_second_tick:		
		mov timer_count, cx		
		mov al, 20h
		out 20h, al
		c
		iret		
	timer_tick endp	
	
	vector_old dd ?
	timer_count dw 0	
	timer_flag dw 0
	msg db 'Check ', 0dh, 0ah, 024h
	exit db 'Exit program', 0dh, 0ah, 024h

end start
	
	
