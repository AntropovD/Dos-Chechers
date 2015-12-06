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
	cmp ah, 0eh
	je _backspace_pressed
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
	_backspace_pressed:
		call Backspace_Pressed
		jmp check_buffer_exit
	printable_char_pressed:
		call Printable_Char
		jmp check_buffer_exit
Keyboard_CheckBuffer endp
;===============================================================
Backspace_Pressed proc
	mov bx, offset Message_Buffer
	mov di, MsgBuf_Pointer
	cmp di, bx
	je backsp_ret

	dec di
	mov byte ptr [di], ' '
	dec MsgBuf_Pointer
	call Msg_Buf_Clear
	call Update_Msg_Buf
	backsp_ret:
	ret
Backspace_Pressed endp
;===============================================================	
Enter_Pressed proc
	call Check_If_Command_Move
	cmp ax, 1
	je entered_move_command
	entered_move_back:

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

	entered_move_command:
		mov di, MsgBuf_Pointer
		mov byte ptr [di], 'C'
		inc di
		mov byte ptr [di], 'm'
		inc di
		mov byte ptr [di], 'd'
		add MsgBuf_Pointer, 3

		mov di, offset Message_Buffer
		mov ch, byte ptr[di]
		mov cl, byte ptr[di+1]
		mov dh, byte ptr[di+3]
		mov dl, byte ptr[di+4]
		sub ch, '0'
		sub cl, '0'
		sub dh, '0'
		sub dl, '0'

		call Can_Enemy_Do_Command_Cx_Dx
		cmp ax, 1
		jne not_can_execute_command

		can_execute_command:
		mov di, MsgBuf_Pointer
		mov byte ptr [di], '+'
		inc MsgBuf_Pointer
		call Execute_Enemy_Command_Cx_Dx
		jmp entered_move_back

		not_can_execute_command:
		mov di, MsgBuf_Pointer
		mov byte ptr [di], '-'
		inc MsgBuf_Pointer
		jmp entered_move_back

	Command_msg db 'Cmd'
Enter_Pressed endp
;===============================================================
Execute_Enemy_Command_Cx_Dx proc
	call Repaint_Cell
	call Remove_Pawn_From_Board	
	mov bl, 2
	call Set_New_Pawn_On_Board
	mov bl, PAWN_BLACK
	call Draw_New_Pawn_On_Screen
	ret
Execute_Enemy_Command_Cx_Dx endp
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
Check_If_Command_Move proc
	mov bx, MsgBuf_Pointer
	sub bx, offset Message_Buffer
	cmp bx, 5
	jne not_move_command
	mov di, offset Message_buffer

	mov al, [di]
	call Is_Digit_Al
	cmp al, 0
	je not_move_command

	mov al, [di+1]
	call Is_Digit_Al
	cmp al, 0
	je not_move_command

	cmp byte ptr [di+2], '-'
	jne not_move_command

	mov al, [di+3]
	call Is_Digit_Al
	cmp al, 0
	je not_move_command

	mov al, [di+4]
	call Is_Digit_Al
	cmp al, 0
	je not_move_command

		mov ax, 1
		ret	
	not_move_command:
		mov ax, 0
		ret
Check_If_Command_Move endp
;===============================================================
Is_Digit_Al proc
	cmp al, '1'
	jl not_digit
	cmp al, '8'
	jg not_digit
		mov al, 1
		ret
	not_digit:
		mov al, 0
		ret
Is_Digit_Al endp
;===============================================================
; cx - from dx - to
Can_Enemy_Do_Command_Cx_Dx proc
	; Проверка board[cx] = цвет, board[dx] = пусто
	mov ax, cx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 2
	jne not_can_enemy_do_command

	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne not_can_enemy_do_command 
	; Проверка расстояний
	call Can_Enemy_Pawn_Move_Like_This_Cx_Dx
	cmp ax, 1
	jne not_can_enemy_do_command
	
	can_enemy_do_command:
		mov ax, 1	
		ret
	not_can_enemy_do_command:
		mov ax, 0
		ret
Can_Enemy_Do_Command_Cx_Dx endp
;===============================================================
Can_Enemy_Pawn_Move_Like_This_Cx_Dx proc
	push cx dx
	add dx, 3030h	
	sub dh, ch
	sub dl, cl

	cmp dl, 2fh
	jl en_pawn_cant
	cmp dl, 30h
	jg en_pawn_cant
	cmp dh, 2fh
	jl en_pawn_cant
	cmp dh, 31h
	jg en_pawn_cant

		mov ax, 1
		pop dx cx
		ret
	en_pawn_cant:
		mov ax,0
		pop dx cx
		ret	
	ret
Can_Enemy_Pawn_Move_Like_This_Cx_Dx endp
;===============================================================
;===============================================================
;===============================================================
