.model tiny
.code
org 100h

start:


	vector_old dd ?
	timer_count dw 0	
	timer_flag dw 0
	msg db 'Check ', 0dh, 0ah, 024h


	mov ax, 3
	int 10h	

	mov ax, 3508h
	int 21h
	
	mov word ptr vector_old, bx
	mov word ptr vector_old+2, es
	
	cli
	
	mov ax, 2508h
	mov dx, offset timer_tick
	push ds
	push cs
	pop ds	
	int 21h	
	pop ds
	sti
	
	_loop:
		;int 8h
		
		cmp timer_flag, 1		
		je timer_flag_active		
		timer_flag_return:
		
		mov ah, 01h
		int 16h		
		jnz	char_available
		jmp _loop_exit
		
	char_available_return:
		
	jmp _loop
_loop_exit:
	
	
	mov dx, offset vector_old
	mov ax, 2508h	
	push ds
	push vector_old+2
	pop ds
	int 21h
	pop ds
	
	mov ax, 4c00h
	int 21h
	
	char_available:
		int 20h
		jmp _loop_exit
	
		
	jmp char_available_return
	
	timer_flag_active:
		mov timer_flag, 0
		mov ah, 9 
		mov dx, offset msg
		int 21h
		jmp timer_flag_return
		
	timer_tick proc	
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
		iret
		
	timer_tick endp
	
end start
	
	
