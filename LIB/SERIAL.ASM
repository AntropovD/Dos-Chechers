;===============================================================
	COM equ 02F8h
	IRQ equ 0Bh

	E_BITMASK equ 11110111b
	D_BITMASK equ 00001000b

	SBuffer_Beg dw 0
	SBuffer_End dw 0
	NO_need_to db 0
	Send_Buffer db 2000 dup (' ')

	RBuffer_Beg dw 0
	RBuffer_End dw 0
	Recv_Buffer db 2000 dup (' ')

	old_irq dd ?
;===============================================================
Serial_Interrupt proc far
	pusha

	mov dx, COM+2
	in al, dx

	repeat_handler:
		and ax, 00000110b

		try_recv:
			cmp ax, 4
			jnz check_for_repeat
			call recv_h

		check_for_repeat:
			mov dx, COM + 2
			in al, dx
			test al, 1
			jz repeat_handler
	
	headler_end:
		mov al, 20h
		out 20h, al
		popa
	iret

	recv_h proc near
		mov dx, COM
		in al, dx
		
		recv_in_buff:
			mov di, RBuffer_End
			mov Recv_Buffer[di], al
			inc RBuffer_End

			cmp RBuffer_End, 2000
			jnz recv_h_ret
			mov RBuffer_End, 0
		
		recv_h_ret:
			ret
	recv_h endp
Serial_Interrupt endp
;===============================================================
Serial_Install proc near
	push es

	mov ax, 3500h + IRQ
	int 21h
	mov word ptr old_irq, bx
	mov word ptr old_irq + 2, es
	mov ax, 2500h + IRQ
	lea dx, Serial_Interrupt
	int 21h

	pop es

	mov al, 0
	disable_irqs:
		mov dx, COM + 1
		out dx, al

	modem_lines_to_0:
		mov dx, COM + 4
		out dx, al

	read_from_LSR_RBR_MSR:
		mov dx, COM + 5
		in al, dx

		mov dx, COM + 0
		in al, dx

		mov dx, COM + 6
		in al, dx

	disable_FIFO:
		mov dx, COM + 2
		mov al, 0
		out dx, al

	set_speed:
		mov dx, COM + 3
		mov al, 80h
		out dx, al

		mov dx, COM + 0
		mov al, 2
		out dx, al

		mov dx, COM + 1
		mov al, 0
		out dx, al

	line_init:
		mov dx, COM + 3
		mov al, 0011b
		out dx, al

	modem_init:
		mov dx, COM + 4
		mov al, 1011b
		out dx, al

	; здесь следует выполнить проверку на наличие модема на этом порту (читать
	; регистр MSR, пока не будут установлены линии CTS и DSR или не кончится время),
	; а затем послать в модем (то есть поместить в буфер передачи) инициализирующую
	; строку, например "ATZ",0Dh

	allow_irqs:
		mov dx, COM + 1
		mov al, 0001b
		out dx, al

		in al, 21h
		and al, E_BITMASK
		out 21h, al

	ret
Serial_Install endp
;===============================================================
Serial_Uninstall proc near
	push ds
		
	disable_all_irqs:
		in al, 21h
		or al, D_BITMASK
		out 21h, al

		mov dx, COM + 1
		mov al, 0
		out dx, al

		mov dx, COM + 4
		mov al, 0
		out dx, al

		mov ax, 2500h + IRQ
		lds dx, old_irq
		int 21h
	
	pop ds
	ret
Serial_Uninstall endp
;===============================================================
Serial_AL_To_Buf proc near
	mov di, SBuffer_End
	mov Send_Buffer[di], al

	inc SBuffer_End
	cmp SBuffer_End, 2000
	jnz Serial_Al_to_Buf_ret
	mov SBuffer_End, 0

	Serial_Al_to_Buf_ret:
		ret
Serial_AL_To_Buf endp
;===============================================================
Serial_Send_Str_In_SI_To_Buffer proc near
	cmp cx, 0
	jz send_str_ret

	mov di, SBuffer_End
	send_one_char:
		mov dh, [si]
		mov Send_Buffer[di], dh

		inc si
		inc di
		cmp di, 2000
		jnz continue_send_loop
		mov di, 0

		continue_send_loop:
			loop send_one_char

	mov SBuffer_End, di

	send_str_ret:
	ret
Serial_Send_Str_In_SI_To_Buffer endp
;===============================================================
Serial_Send_All proc near
	mov bx, SBuffer_End

	send_one:
		cmp bx, SBuffer_Beg
		jz send_one_ext

		mov si, SBuffer_Beg
		mov al, Send_Buffer[si]

		inc SBuffer_Beg
		cmp SBuffer_Beg, 2000
		jnz send_atLeast
		mov SBuffer_Beg, 0

		send_atLeast:
			push ax
			serial_send_waitLine:
				mov dx, COM + 5
				in al, dx
				test al, 20h
	        	jnz serial_send_output

	            jmp short $+2
	            jmp short $+2
	            jmp serial_send_waitLine

            serial_send_output:
            	pop ax
				mov dx, COM
				out dx, al
		jmp send_one

	send_one_ext:

		ret
Serial_Send_All endp
;===============================================================
Serial_Get_Symbol_To_AL proc near
	mov ax, RBuffer_End
	cmp ax, RBuffer_Beg
	jnz pop_symb
	xor ax, ax
	jmp get_symbols_to_al_ret

	pop_symb:
		mov si, RBuffer_Beg
		mov al, Recv_Buffer[si]

		inc RBuffer_Beg
		cmp RBuffer_Beg, 2000
		jnz get_symbols_to_al_ret
		mov RBuffer_Beg, 0

	get_symbols_to_al_ret:
		ret
Serial_Get_Symbol_To_AL endp
;===============================================================
Serial_Get_Str_To_DI proc near
	xor cx, cx

	mov si, RBuffer_Beg
	cmp si, RBuffer_End
	jz get_str_ret

	get_str_loop:
		mov al, Recv_Buffer[si]
		mov [di], al

		inc di
		inc cx

		inc si
		cmp si, 2000
		jnz get_str_loop_continue
		mov si, 0

		get_str_loop_continue:
			cmp cx, bx
			jz get_str_ext_loop

			cmp si, RBuffer_End
			jnz get_str_loop
			
	get_str_ext_loop:
		mov RBuffer_Beg, si

	get_str_ret:
		ret
Serial_Get_Str_To_DI endp
;===============================================================
Serial_Check_Sth_Come proc
	mov ax, RBuffer_End
	cmp ax, RBuffer_Beg
	ret
Serial_Check_Sth_Come endp
;===============================================================