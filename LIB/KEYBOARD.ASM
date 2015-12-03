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
	mov di, offset Message_Buffer
	mov cx, 54	
	clear_loop:
		mov byte ptr [di], ' '
		inc di
		dec cx
		cmp cx, 0
		jne clear_loop
	call Update_Msg_Buf
	mov MsgBuf_Pointer, offset Message_Buffer	
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
	mov si, offset Message_Buffer
	mov di, HB_Pointer	
	mov cx, 27
	repne movsb

	add HB_Pointer, 27
	mov bx, HB_Pointer
	cmp bx, offset HB_End
	jne not_null_hb_pointer_cmth1
	mov HB_Pointer, offset History_Buffer

	not_null_hb_pointer_cmth1:
	mov cx, 27
	repne movsb

	add HB_Pointer, 27
	mov bx, HB_Pointer
	cmp bx, offset HB_End
	jne not_null_hb_pointer_cmth2
	mov HB_Pointer, offset History_Buffer
	not_null_hb_pointer_cmth2:
		mov Update_History_Buffer_Flag, 1
		ret
Copy_Msg_To_Hist endp
;===============================================================