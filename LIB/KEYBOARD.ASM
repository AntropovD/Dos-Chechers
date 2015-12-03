;===============================================================
Keyboard_CheckBuffer proc 
	mov ah, 01
	int 16h
	jz check_buffer_exit
	mov ah, 0
	int 16h
	cmp ah, 01h
	je esc_pressed	
	cmp ah, 1ch
	je _enter_pressed
	cmp al, 20h
	jge printable_char_pressed

	check_buffer_exit:
		ret

	esc_pressed:
		call Exit_Procedure
		jmp check_buffer_exit
	_enter_pressed:
		call Enter_Pressed
		jmp check_buffer_exit
	printable_char_pressed:
		call Printable_Char
		jmp check_buffer_exit

Keyboard_CheckBuffer endp
;===============================================================	
Enter_Pressed proc
	call Copy_Msg_To_Hist
	lea bx, Message_Buffer
	mov di, MsgBuf_Pointer
	clear_loop:
		mov byte ptr [di], ' '
		dec di
	cmp di, bx
	jge clear_loop	
	mov MsgBuf_Pointer, bx
	call Msg_Buf_Clear	
	ret
Enter_Pressed endp
;===============================================================
Printable_Char proc	
	mov bx, offset Message_Buffer
	add bx, 45	
	mov di, MsgBuf_Pointer
	cmp di, bx
	jg pr_ch_ret

	mov cs:[di], al
	inc MsgBuf_Pointer
	call Update_Msg_Buf
	pr_ch_ret:
	ret
Printable_Char endp
;===============================================================
Copy_Msg_To_Hist proc	
	; mov ax, MsgBuf_Pointer
	; mov bx, offset Message_Buffer
	; sub ax, bx
	; mov bl, 27
	; div bl
	; cmp ah, 0
	; jz count_lines
	; inc al
	; xor ah, ah
	; count_lines:
	; ;mov si, offset Message_Buffer
	; ;mov di, HB_Pointer



	ret
Copy_Msg_To_Hist endp
;===============================================================
;===============================================================
;===============================================================
;===============================================================
;===============================================================
;===============================================================