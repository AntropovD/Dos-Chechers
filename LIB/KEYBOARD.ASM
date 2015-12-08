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
	CLI

	call Check_Entered_Commands
	cmp ax, 1
	je clear_buf_and_exit
	
	call Check_If_Command_Move
	cmp ax, 1
	je entered_move_command

	jmp entered_move_back

	entered_move_back_1:
		pop dx cx
	entered_move_back:
		call Copy_Msg_To_Hist		
	clear_buf_and_exit:		
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
		STI
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
		mov dh, byte ptr[di+2]
		mov dl, byte ptr[di+3]
		sub ch, '0'
		sub cl, '0'
		sub dh, '0'
		sub dl, '0'

		call Can_Enemy_Do_Move_Command_Cx_Dx
		cmp ax, 1
		je can_move_command

		mov ax, cx
		;твой цвет?
		call Get_Board_Value_By_AX_to_AL
		cmp al, 2
		jne not_can_command

		call Can_Enemy_Do_Pawn_Command_Cx_dx
		cmp ax, 1
		jne not_can_command

		push cx dx

		mov di, offset Message_Buffer
		mov si, MsgBuf_Pointer
		sub si, 3
		add di, 4
		cmp si, di
		je can_pawn_command
		all_moves_loop:				
			mov cx, dx
			mov dh, byte ptr[di]
			mov dl, byte ptr[di+1]
			sub dx, 3030h
				call Can_Enemy_Do_Pawn_Command_Cx_dx
				cmp ax, 1
				jne __not_can_command_tvou_mat
			add di, 2
			cmp di, si
			jne all_moves_loop
		pop dx cx

		can_pawn_command:
			mov di, MsgBuf_Pointer
			mov byte ptr [di], '!'
			inc MsgBuf_Pointer
			call Execute_Enemy_Pawn_Command

			mov di, offset Message_Buffer
			mov si, MsgBuf_Pointer
			sub si, 4
			add di, 4
			cmp si, di
			je entered_move_back_1
			all_cuts_loop:				
				mov cx, dx
				mov dh, byte ptr[di]
				mov dl, byte ptr[di+1]
				sub dx, 3030h
				push si
				call Execute_Enemy_Pawn_Command
				pop si
				add di, 2
				cmp di, si
				jne all_cuts_loop
			
			jmp entered_move_back

		__not_can_command_tvou_mat:
			pop dx cx	
		not_can_command:
			mov di, MsgBuf_Pointer
			mov byte ptr [di], '-'
			inc MsgBuf_Pointer
			jmp entered_move_back

		can_move_command:
			mov di, MsgBuf_Pointer
			mov byte ptr [di], '+'
			inc MsgBuf_Pointer
			call Execute_Enemy_Command_Cx_Dx
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
	rep movsb

	add HB_Pointer, 27
	mov bx, HB_Pointer
	cmp bx, offset HB_End
	jne not_null_hb_pointer_cmth1
	mov HB_Pointer, offset History_Buffer

	not_null_hb_pointer_cmth1:
	mov cx, 27
	rep movsb

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
	mov Enemy_Command_Length, bx
	push bx
	and bx, 01b
	cmp bx, 1
	pop cx
	je not_move_command
	mov di, offset Message_buffer

	check_command_move_loop:
		mov al, [di]
		call Is_Digit_Al
		cmp al, 1
		jne not_move_command
		inc di
		loop check_command_move_loop

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
Can_Enemy_Do_Move_Command_Cx_Dx proc
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
	call Can_Enemy_Move_Like_This_Cx_Dx
	cmp ax, 1
	jne not_can_enemy_do_command
	
	can_enemy_do_command:
		mov ax, 1	
		ret
	not_can_enemy_do_command:
		mov ax, 0
		ret
Can_Enemy_Do_Move_Command_Cx_Dx endp
;===============================================================
Can_Enemy_Move_Like_This_Cx_Dx proc
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
Can_Enemy_Move_Like_This_Cx_Dx endp
;===============================================================
Enemy_Command_Length dw 0
;===============================================================
Can_Enemy_Do_Pawn_Command_Cx_dx proc
	push cx dx

	cmp cl, dl
	jl enemy_cant_pawn
	
	; пустая клетка
	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne enemy_cant_pawn

	; цвет посередмне
	call Find_Middle_Cell
	cmp ax, 0ffffh
	je enemy_cant_pawn
	call Get_Board_Value_By_AX_to_AL
	cmp al, 1
	jne enemy_cant_pawn
	
	enemy_can_pawn:
		mov ax, 1
		pop dx cx
		ret 
	enemy_cant_pawn:
		mov ax, 0
		pop dx cx	
		ret
Can_Enemy_Do_Pawn_Command_Cx_dx endp
;===============================================================
Execute_Enemy_Pawn_Command proc
	push cx dx	

	call Repaint_Cell	
	call Repaint_Pawned_Cell
	
	call Remove_Pawn_From_Board
	call Remove_Pawned_Pawn_From_Board
	mov bl, 2
	call Set_New_Pawn_On_Board
	mov bl, PAWN_BLACK
	call Draw_New_Pawn_On_Screen
	
	pop dx cx
	ret
Execute_Enemy_Pawn_Command endp
;===============================================================
Update_Everything proc
	cli
		call Draw_Chessboard
		call Draw_Frame
		call Draw_Message_Box
		mov Update_History_Buffer_Flag, 1
		mov LAST_CHOSEN_BOX, 0ffffh
	sti
	ret
Update_Everything endp
;===============================================================
Check_Entered_Commands proc
	mov cx, 6
	mov si, offset update_cmd
	mov di, offset Message_Buffer
	repe cmpsb
	jne not_match_1
	match_1:
		call Update_Everything
		mov ax, 1
		ret

	not_match_1:
		mov cx, 4
		mov si, offset help_cmd
		mov di, offset Message_Buffer
		repe cmpsb
		jne not_match_2
		call Execute_Help_Command
		mov ax, 1
		ret

	not_match_2:
		mov ax, 0
		ret

	update_cmd db 'update'
	help_cmd db 'help'
Check_Entered_Commands endp
;===============================================================
Execute_Help_Command proc
	mov dl, count_strings	
	mov si, offset Help_Text
	 
	help_loop:
		mov di, word ptr HB_Pointer
		mov cx, 27
		rep movsb
		add HB_Pointer, 27
		mov bx, HB_Pointer
		cmp bx, offset HB_End
		jne not_null_hb
		mov HB_Pointer, offset History_Buffer
		not_null_hb:
		dec dl
		cmp dl, 0
		jne help_loop
	
	mov Update_History_Buffer_Flag, 1
	ret

	count_strings db 4

	Help_Text db 'Armyan chechers            '
		  db 'Enter commands in console  '
		  db 'update - update window     '
		  db 'help - show help message   '

Execute_Help_Command endp
;===============================================================
;===============================================================