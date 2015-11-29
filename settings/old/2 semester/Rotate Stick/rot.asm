.model tiny
.code
org 100h

start:
	mov ax, 3508h
	int 21h	
	mov word ptr vector, bx
	mov word ptr vector+2, es
	mov ax, 02508h
	mov dx, offset interrupt_08h
	int 21h
	
	mov ax, 3
	int 10h	
	nop
	nop
	
	mov ax, 0B800h
		mov es, ax
		mov di, 00a10h	
		mov dh, 15	
		mov bl, 10
				
		mov bx, offset string
		mov cx, count
		add bx, cx
		
		mov dl, byte ptr cs:[bx]
		mov  es:[di], dx     
		mov dl, ah  				
		
		inc count
;==============================================================
__Main_loop:
	cli
		cmp timer_flag, 1		
		je timer_flag_active		
		timer_flag_return:
		back_key:
		mov ah, 01h
		int 16h		
		jnz	char_available			
		char_available_return:
	sti	
	jmp __Main_loop	
;==============================================================	
	timer_flag_active:
		mov timer_flag, 0
				
		mov ax, 0B800h
		mov es, ax
		mov di, 00a10h	
		mov dh, 15	
		mov bl, 10
		
		cmp count, 8
		je mov_count_0
		back_mov0:
		
		mov bx, offset string
		mov cx, count
		add bx, cx
		
		mov dl, byte ptr cs:[bx]
		mov  es:[di], dx     
		mov dl, ah  				
		
		inc count
		
		jmp timer_flag_return
	mov_count_0:
		mov count, 0
		jmp back_mov0
;==============================================================
;==============================================================
	char_available:	
		mov ah, 0
		int 16h
		cmp ax, 0011bh
		je esc_pressed
		
		cmp ax, 00231h
		je faster
		cmp ax, 00332h
		je slower
		jmp char_available_return
	
	esc_pressed:
		jmp exit			

	faster:
		inc next_timer_check
		jmp back_key
	slower :
		dec next_timer_check
		jmp back_key
;==============================================================
	exit:
	cli		
			push ds
			pop es		
			mov bx, 0020h
			mov ax, word ptr es:[vector]
			push 0
			pop es 
			mov es:[bx], ax
			push ds
			pop es
			mov ax, word ptr es:[vector+2]
			push 0
			pop es
			mov es:[bx+2], ax	
		sti	
	int 20h
	ret		
;==============================================================
	interrupt_08h:	
	mov dx, timer_count	
	inc dx
	
	cmp dx, next_timer_check
	jl not_second_tick
	mov timer_flag, 1
	mov dx, 0
	
	not_second_tick:		
		mov timer_count, dx
		mov al, 20h
		out 20h, al		
		iret
	 
vector dd ?
timer_flag dw 0
minutes dw 0
timer_count dw 0
next_timer_check dw 14

string db '|/-\|/-\'
count dw 0

end start