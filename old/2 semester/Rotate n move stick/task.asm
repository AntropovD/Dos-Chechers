.model tiny
.386
.code
org 100h
start:
	mov ax, 3
	int 10h	
;==============================================================
	mov ax, 03509h
	int 21h
	mov word ptr vector_09h, bx
	mov word ptr vector_09h+2, es		
	mov ax, 02509h
	mov dx, offset interrupt_09h
	int 21h
;==============================================================
	mov ax, 3508h
	int 21h	
	mov word ptr vector_08h, bx
	mov word ptr vector_08h+2, es
	mov ax, 02508h
	mov dx, offset interrupt_08h
	int 21h
;==============================================================
	mov _head, offset _buffer
	mov _tail, offset _buffer	
;==============================================================

__Main_loop:
	cli
			cmp timer_flag, 1
			je second_tick		
		second_tick_return:		
		
		keyboard_check:
			mov ax, _head
			mov bx, _tail
			cmp ax, bx
			jne char_available
			char_available_return:
	sti
	jmp __Main_loop	

;==============================================================
	second_tick:
		mov timer_flag, 0
		
		cmp count, 8
		je mov_count_0
		back_mov0:
		
		mov ax, 0B800h
		mov es, ax
		mov di, position	
		mov dh, 15	
		mov bl, 10
		
		mov bx, offset string
		cmp rotate_flag, 1
		jne rotate_continue
		mov bx, offset string2
		
		rotate_continue:
		mov cx, count
		add bx, cx
		
		mov dl, byte ptr cs:[bx]
		mov  es:[di], dx    		
		
		inc count		
		jmp second_tick_return
		
	mov_count_0:	
		
		call clear_position
		cmp right_flag, 1
		je _right_flag
		cmp left_flag, 1
		je _left_flag
		cmp up_flag, 1
		je _up_flag
		cmp down_flag, 1 
		je _down_flag
	
	flag_back:
		mov count, 0
		jmp back_mov0
		
	_right_flag:
		add position, 2		
		mov ax, position
		mov cl, 0a0h
		div cl		
		cmp ah, 0
		je right_border		
		jmp flag_back
		
	right_border:
		mov cx, 0a0h
		sub position, cx
		jmp flag_back
		
	_left_flag:
		mov ax, position
		mov cl, 0a0h
		div cl		
		cmp ah, 0
		je left_border				
		sub position, 2
		jmp flag_back
		
	left_border:
		mov cx, 80*2
		add position, cx
		jmp flag_back
		
	_up_flag:
		sub position, 0a0h
		cmp position, 0 
		jl up_border
		jmp flag_back
		
	up_border:
		mov cx, 80*2*25
		add position,cx
		jmp flag_back
		
	_down_flag:
		add position, 0a0h
		cmp position, 0fa0h
		jg down_border
		jmp flag_back
	
	down_border:
		mov cx, 80*25*2
		sub position, cx
		jmp flag_back
	
;==============================================================
	char_available:			
		mov bx, _head
		mov ax, ds:[bx]
		
	cmp al, 01
		je esc_pressed
		
	cmp al, 48h
		je up_arrow
	cmp al, 4bh
		je left_arrow
	cmp al,4dh
		je right_arrow
	cmp al, 50h
		je down_arrow		
		
	cmp al, 0dh
		je plus
	cmp al, 0ch
		je minus		
	
	cmp al, 1ch
		je enterKey
		
	cmp al, 39h
		je space				
		
	keyboard_back:
		add _head, 2
		cmp _head, offset _buffer_end
		jle keyboard_check
		mov _head, offset _buffer		
		jmp keyboard_check
	
		
	esc_pressed:
		jmp exit			
	
	space:
		mov up_flag, 0
		mov right_flag, 0
		mov down_flag, 0
		mov left_flag, 0
		jmp keyboard_back
		
	enterKey:
		mov dl, rotate_flag
		xor dl, 1
		mov rotate_flag, dl
		jmp keyboard_back
		
	up_arrow:		
		mov up_flag, 1
		mov right_flag, 0
		mov down_flag, 0
		mov left_flag, 0
		jmp keyboard_back
		
	left_arrow:
		mov up_flag, 0
		mov right_flag, 0
		mov down_flag, 0
		mov left_flag, 1
		jmp keyboard_back
				
	right_arrow:
		mov up_flag, 0
		mov right_flag, 1
		mov down_flag, 0
		mov left_flag, 0
		jmp keyboard_back
		
	down_arrow:
		mov up_flag, 0
		mov right_flag, 0
		mov down_flag, 1
		mov left_flag, 0
		jmp keyboard_back
		
	minus:
		inc next_timer_check
		jmp keyboard_back
	
	plus:
		dec next_timer_check
		cmp next_timer_check, 0
		jne keyboard_back
		mov next_timer_check, 1
		jmp keyboard_back		
;==============================================================
	clear_position:
		mov ax, 0B800h
		mov es, ax
		mov di, word ptr position
		mov  es:[di], word ptr 0
		ret
;==============================================================
exit:
	cli		
			push ds
			pop es		
			mov bx, 0020h
			mov ax, word ptr es:[vector_08h]
			push 0
			pop es 
			mov es:[bx], ax
			push ds
			pop es
			mov ax, word ptr es:[vector_08h+2]
			push 0
			pop es
			mov es:[bx+2], ax	
		
			push ds
			pop es		
			mov bx, 0024h
			mov ax, word ptr es:[vector_09h]
			push 0
			pop es 
			mov es:[bx], ax
			push ds
			pop es
			mov ax, word ptr es:[vector_09h+2]
			push 0
			pop es
			mov es:[bx+2], ax	
	sti	
	int 20h
	ret		
;==============================================================
write_buffer:
	mov bx, ds:[_tail]
	mov ds:[bx], ax
	add _tail, 2
	cmp _tail, offset _buffer_end
	jle __continue_write_buffer
	mov _tail, offset _buffer	
	__continue_write_buffer:
	ret
;==============================================================
interrupt_09h:
	 push      ax
     push      di
     push      es
     in        al,60h	 
	 call write_buffer	 
     pop       es
     pop       di
     in        al,61h    
     mov       ah,al
     or        al,80h    
     out       61h,al
     xchg      ah,al     
     out       61h,al	 
	 nop
	 nop	 
     mov       al,20h    
     out       20h,al    
     pop       ax
     iret
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
	jmp cs:vector_08h	
	
;==============================================================

	vector_09h dd ?
	vector_08h dd ?
	_head dw 0
	_tail dw 0
	
	string db '|/-\|/-\'
	string2 db '|\-/|\-/'
	count dw 0
	timer_flag db 0
	
	rotate_flag db 0
	
	right_flag db 0
	left_flag db 0
	up_flag db 0
	down_flag db 0
		
	timer_count dw 0
	next_timer_check dw 1
	
	position dw 07d0h
	
	_buffer dw 6 dup (0)
	_buffer_end dw 0
	
end start