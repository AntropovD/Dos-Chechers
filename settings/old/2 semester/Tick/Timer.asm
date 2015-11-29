.model tiny
.code
org 100h
	
start:
	mov ax, 3
	int 10h	

	mov ax, 3508h
	int 21h	
	mov word ptr vector_ip, bx
	mov word ptr vector_cs, es
	
	mov ax, 2508h
	mov dx, offset timer_tick
	int 21h		
	
	_loop:		
		cli
		cmp timer_flag, 1		
		je timer_flag_active		
		timer_flag_return:
		
		mov ah, 01h
		int 16h		
		jnz	char_available			
		char_available_return:
		sti		
	jmp _loop
	_loop_exit:

	mov ax, 3
	int 10h	
	nop
	nop
	cli
    push ds
    mov dx, vector_ip
    mov ax, vector_cs
    mov ds,ax
    mov ax,2508h
    int 21h           
    pop ds 
    sti
    ret 	
;-------------------------------------------	
	char_available:	
		mov ah, 0
		int 16h
		cmp ax, 0011bh
		je esc_pressed
		cmp ax, 01c0dh
		je enter_pressed
		cmp ax, 03920h
		je space_pressed
		cmp ax, 00e08h
		je backspace_pressed		
		jmp char_available_return
	
	backspace_pressed:
		mov seconds, 0
		mov minutes, 0
		jmp output_0000
		jmp char_available_return
	space_pressed:
		mov is_running, 0
		jmp char_available_return
	enter_pressed:
		mov is_running, 1
		jmp char_available_return
		
	esc_pressed:
		mov ah, 9 
		mov dx, offset exit
		int 21h
		jmp _loop_exit	
;-------------------------------------------
	timer_flag_active:
		mov timer_flag, 0
		
		cmp is_running, 0
		je timer_flag_return
		
		inc seconds
		cmp seconds, 60
		je null_seconds
	null_seconds_return:
	
		mov ax, 0B800h
		mov es, ax
		mov di, 00a10h	
		mov dh, 15	
		mov bl, 10
		
		mov ax, minutes
		div bl		
		mov dl, al
		add dl, '0'
		mov  es:[di], dx     
		mov dl, ah
		add dl, '0'
		mov  es:[di+2], dx     
		mov dl, ':'
		mov  es:[di+4], dx     		
		
		mov ax, seconds
		div bl
		mov dl, al
		add dl, '0'
		mov  es:[di+6], dx     
		mov dl, ah
		add dl, '0'
		mov  es:[di+8], dx     		
		
		jmp timer_flag_return
;-------------------------------------------		
	null_seconds:
		inc minutes
		mov seconds, 0
		jmp null_seconds_return
;-------------------------------------------
	timer_tick proc	
		mov cx, timer_count
		inc cx	
				
		cmp cx, next_timer_check
		jl not_second_tick
		mov timer_flag, 1
		mov cx, 0				
		inc timer_19_count
		cmp timer_19_count, 4
		je timer_19tick
		jne timer_not_19tick
		
	timer_19tick_return:
		
	not_second_tick:		
		mov timer_count, cx		
		mov al, 20h
		out 20h, al
		iret		
		
		
	timer_19tick:
		mov next_timer_check, 19
		jmp timer_19tick_return
	
	timer_not_19tick:
		mov next_timer_check, 18
		jmp timer_19tick_return
	
	timer_tick endp
;-------------------------------------------
output_0000:
		mov ax, 0B800h
		mov es, ax
		mov di, 00a10h	
		mov dh, 15	
		mov dl, '0'
		mov  es:[di], dx     		
		mov dl, '0'
		mov  es:[di+2], dx     
		mov dl, ':'
		mov  es:[di+4], dx   
		mov dl, '0'
		mov  es:[di+6], dx     
		mov dl, '0'
		mov  es:[di+8], dx     		
		jmp char_available_return
;-------------------------------------------
	seconds dw 0
	minutes dw 0
	
	next_timer_check dw 18
	is_running dw 1
	vector_ip dw 0
	vector_cs dw 0	
	timer_count dw 0	
	timer_flag dw 0
	timer_19_count dw 0
	msg db 'Check ', 0dh, 0ah, 024h
	exit db 'Exit program', 0dh, 0ah, 024h
	string db 'Fuck Them All', 0dh, 0ah, 024h
	db 64000 dup (0)

end start
	
	
