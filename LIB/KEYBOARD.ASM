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
	jae printable_char_pressed
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
	mov bx, MsgBuf_Pointer
	cmp bx, offset Message_Buffer
	je exit_ooooo

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
	mov Update_History_Buffer_Flag, 1	
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
		je can_move_command_1

		mov ax, cx
		
		call Get_Board_Value_By_AX_to_AL
		cmp al, 2
		jne not_can_command_1

		call Can_Enemy_Do_Pawn_Command_Cx_dx
		cmp ax, 1
		jne not_can_command_1

		push cx dx

		mov di, offset Message_Buffer
		mov si, MsgBuf_Pointer
		sub si, 3
		add di, 4
		cmp si, di
		je can_pawn_command_1
		all_moves_loop_1:				
			mov cx, dx
			mov dh, byte ptr[di]
			mov dl, byte ptr[di+1]
			sub dx, 3030h
				call Can_Enemy_Do_Pawn_Command_Cx_dx
				cmp ax, 1
				jne __not_can_command_1_tvou_mat
			add di, 2
			cmp di, si
			jne all_moves_loop_1
		pop dx cx

		can_pawn_command_1:
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
			all_cuts_loop_1:				
				mov cx, dx
				mov dh, byte ptr[di]
				mov dl, byte ptr[di+1]
				sub dx, 3030h
				push si
				call Execute_Enemy_Pawn_Command
				pop si
				add di, 2
				cmp di, si
				jne all_cuts_loop_1
			
			jmp entered_move_back

		__not_can_command_1_tvou_mat:
			pop dx cx	
		not_can_command_1:
			mov di, MsgBuf_Pointer
			mov byte ptr [di], '-'
			inc MsgBuf_Pointer
			jmp entered_move_back

		can_move_command_1:
			mov di, MsgBuf_Pointer
			mov byte ptr [di], '+'
			inc MsgBuf_Pointer
			call Execute_Enemy_Command_Cx_Dx
			jmp entered_move_back	


	exit_ooooo:
		ret	

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
Can_Enemy_Do_Move_Command_Cx_Dx endp
;===============================================================
Enemy_Command_Length dw 0
;===============================================================
Can_Enemy_Do_Pawn_Command_Cx_dx proc
	push cx dx

	cmp cl, dl
	jl enemy_cant_pawn
	
	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0 
	jne enemy_cant_pawn
	
	mov ax, cx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 2
	jne enemy_cant_pawn
	
	; middle color
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
Can_Enemy_Do_Pawn_Command_Cx_dx_With_King proc
	push cx dx
	
	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0 
	jne enemy_cant_pawn_1
	
	mov ax, cx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 4
	jne enemy_cant_pawn_1
	
	call Enemy_Can_Cut_King_Position_To_Bx
	cmp ax, 1
	jne enemy_cant_pawn_1
	
	enemy_can_pawn_1:
		mov ax, 1
		pop dx cx
		ret 
	enemy_cant_pawn_1:
		mov ax, 0
		pop dx cx	
		ret
Can_Enemy_Do_Pawn_Command_Cx_dx_With_King endp
;===============================================================
Execute_Enemy_Pawn_Command proc
	push cx dx			
	
	call Repaint_Cell	
	call Repaint_Pawned_Cell
	
	call Remove_Pawn_From_Board
	call Remove_Pawned_Pawn_From_Board
	
	cmp dl, 1
	je enemy_became_king
	
	mov bl, 2
	call Set_New_Pawn_On_Board
	mov bl, PAWN_BLACK
	call Draw_New_Pawn_On_Screen	
	pop dx cx
	ret
	
	enemy_became_king:
		mov bl, 4
		call Set_New_Pawn_On_Board
		mov bl, PAWN_BLACK
		call Draw_New_King_On_Screen
		pop dx cx
		ret
Execute_Enemy_Pawn_Command endp
;===============================================================
Execute_Enemy_Pawn_Command_With_King proc
	push cx dx			
	
	call Repaint_Cell	
	call Remove_Pawn_From_Board
	
	mov cx, bx
	call Repaint_Cell	
	call Remove_Pawn_From_Board
	
	mov bl, 4
	call Set_New_Pawn_On_Board
	mov bl, PAWN_BLACK
	call Draw_New_King_On_Screen
	pop dx cx
	ret
Execute_Enemy_Pawn_Command_With_King endp
;===============================================================
Update_Everything proc
		mov ax, 12h
		int 10h
		call Draw_Chessboard
		call Draw_Pawns
		call Draw_Frame		
		call Draw_Message_Box
		call Update_Hist_Buf
		mov ax, 1
		int 33h
	
		mov LAST_CHOSEN_BOX, 0ffffh
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
		mov cx, 4
		lea si, rock_cmd
		lea di, Message_Buffer
		repe cmpsb
		jne not_match_3
		call Execute_Rock_Cmd
		mov ax, 1
		ret

	not_match_3:
		mov cx, 5
		lea si, paper_cmd
		lea di, Message_Buffer
		repe cmpsb
		jne not_match_4
		call Execute_Paper_Cmd
		mov ax, 1
		ret

	not_match_4:
		mov cx, 8
		lea si, scissors_cmd
		lea di, Message_Buffer
		repe cmpsb
		jne not_match_5
		call Execute_Scissors_Cmd
		mov ax, 1
		ret

	not_match_5:
		mov cx, 5
		lea si, send_cmd
		lea di, Message_Buffer
		repe cmpsb
		jne not_match_6
		call Execute_Send_Cmd
		mov ax, 1
		ret

	not_match_6:
		mov cx, 7
		lea si, surrent_cmd
		lea di, Message_Buffer
		repe cmpsb
		jne not_match_7
		call Execute_Surrend_Cmd
		mov ax, 1
		ret

	not_match_7:
		mov cx, 5
		lea si, drawn_cmd
		lea di, Message_Buffer
		repe cmpsb
		jne not_match_8
		call Execute_Drawn_Cmd
		mov ax, 1
		ret

	not_match_8:
		mov cx, 4
		lea si, yeah_cmd
		lea di, Message_Buffer
		repe cmpsb
		jne not_match_9
		call Execute_Yeah_Cmd
		mov ax, 1
		ret

	not_match_9:
		mov cx, 4
		lea si,  nope_cmd
		lea di, Message_Buffer
		repe cmpsb
		jne not_match_10
		call Execute_Nope_Cmd
		mov ax, 1
		ret

	not_match_10:
		mov cx, 9
		lea si, username_cmd
		lea di, Message_Buffer
		repe cmpsb
		jne not_match_11
		call Execute_Username_Cmd
		mov ax, 1
		ret

	not_match_11:
		mov ax, 0 
		ret

	update_cmd db 'Update'
	help_cmd db 'Help'
	rock_cmd db 'Rock'
	paper_cmd db 'Paper'
	scissors_cmd db 'Scissors'
	send_cmd db 'Send '
	surrent_cmd db 'Surrend'
	drawn_cmd db 'Drawn'
	yeah_cmd db 'Yeah'
	nope_cmd db 'Nope'
	username_cmd db 'Username '
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
	
	call Update_Hist_Buf
	ret

	count_strings db 28
	
	Help_Text 	  db '                           '
			  db '      Армянские шашки      '
			  db '                           '			  
			  db 'Для определения порядка    '
			  db 'хода используется игра     '
			  db 'камень ножницы бумага      '
			  db 'Вводите команды в консоль  '
			  db '                           '
			  db 'Список команд:             '
			  db 'Update - обновить интерфейс'
			  db 'Help - показать справку    '
			  db 'Rock - выбрать камень      '
			  db 'Paper - выбрать бумагу     '
			  db 'Scissors - выбрать ножницы '
			  db 'Send - послать сообщение   '
			  db 'Surrend - сдаться          '
			  db 'Drawn - предложить ничью   '
			  db 'Yeah - принять ничью       '
			  db 'Nope - отказать ничью      '			  
			  db 'Username - послать своё имя'
			  db '                           '
			  db '                           '
			  db '                           '
			  db '                           '
			  db '                           '	  
			  db '                           '	  
			  db '                           '	  
			  db '                           '	  

	ret			  
Execute_Help_Command endp
;===============================================================
Execute_Rock_Cmd proc
	cmp STATE, 2
	jge $+3
	ret
	cmp STATE, 3
	jle $+3
	ret
	mov MY_CHOISE, '1'
	mov al, 'C'
	call Serial_AL_To_Buf
	mov al, '1'
	call Serial_AL_To_Buf
	call Serial_Send_All
	call Check_Opponent_Choise		
	ret
Execute_Rock_Cmd endp
;===============================================================
Execute_Paper_Cmd proc
	cmp STATE, 2
	jge $+3
	ret
	cmp STATE, 3
	jle $+3
	ret
	mov MY_CHOISE, '3'
	mov al, 'C'
	call Serial_AL_To_Buf
	mov al, '3'
	call Serial_AL_To_Buf
	call Serial_Send_All
	call Check_Opponent_Choise
	ret
Execute_Paper_Cmd endp
;===============================================================
Execute_Scissors_Cmd proc
	cmp STATE, 2
	jge $+3
	ret
	cmp STATE, 3
	jle $+3
	ret
	mov MY_CHOISE, '2'
	mov al, 'C'
	call Serial_AL_To_Buf
	mov al, '2'
	call Serial_AL_To_Buf
	call Serial_Send_All
	call Check_Opponent_Choise

	ret
Execute_Scissors_Cmd endp
;===============================================================
Execute_Send_Cmd proc
	mov cx, MsgBuf_Pointer
	sub cx, offset Message_Buffer
	cmp cx, 5
	jg $+3	
	ret	
	
	sub cx, 5
	mov si, offset Message_Buffer
	add si, 5	
	
	mov al, 'M'
	call Serial_AL_To_Buf
	mov al, cl
	call Serial_AL_To_Buf
	
	mov di, offset send_msg
	mov al, '#'
	stosb
	mov al, ' '
	stosb
	
	next_symbol:
		lodsb
		push di
		call Serial_AL_To_Buf
		pop di
		stosb	
		loop next_symbol
	
	call Serial_Send_All
	
	mov di, offset BufferString
	lea si, send_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History
	
	mov di, offset BufferString
	lea si, send_msg[27]
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History
	
	lea si, empty_send_msg
	lea di, send_msg
	mov cx, 54
	rep movsb
	ret
	
	send_msg db 54 dup (' ')
	empty_send_msg db 54 dup(' ')
Execute_Send_Cmd endp
;===============================================================
Execute_Surrend_Cmd proc
	cmp STATE, 4
	je $+3
	ret
	mov STATE, 6
	mov di, offset BufferString
	mov si, offset surrend_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
	
	mov di, offset BufferString
	mov si, offset again_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
	
	mov al, 'F'
	call Serial_AL_To_Buf
	call Serial_Send_All
	
	ret
	surrend_msg db 'Вы сдались.                '
Execute_Surrend_Cmd endp
;===============================================================
Execute_Drawn_Cmd proc
	cmp STATE, 4
	je $+3
	ret
	mov di, offset BufferString
	mov si, offset drdr_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History
	mov al, 'G'
	call Serial_AL_To_Buf
	call Serial_Send_All
	mov your_drawn, 1
	ret	
	drdr_msg db 'Вы предложили ничью        '
	your_drawn db 0
Execute_Drawn_Cmd endp
;===============================================================
Execute_Yeah_Cmd proc
	cmp STATE, 6
	jne yeah_exit
		mov al, 'H'
		call Serial_AL_To_Buf
		call Serial_Send_All
		mov you_agree_new, 1
		call Check_Agree_For_New			
	yeah_exit:
	
		cmp STATE, 4
		je $+3
		ret
		cmp was_Drawn, 1
		je $+3
		ret
		
		mov di, offset BufferString
		mov si, offset accept_draw_msg
		mov cx, 27
		rep movsb
		call Add_BufferString_To_History
		mov al, 'Y'
		call Serial_AL_To_Buf
		call Serial_Send_All
		call EXECUTE_DRAWN_AGREE
		mov was_Drawn, 0		
		
		ret
		accept_draw_msg db 'Принимаете ничью           '
Execute_Yeah_Cmd endp
;===============================================================
Execute_Nope_Cmd proc
	cmp STATE, 6
	jne nope_exit
		call Exit_Procedure
	nope_exit:
		cmp STATE, 4
		je $+3
		ret
		cmp was_Drawn, 1
		je $+3
		ret
		
		mov di, offset BufferString
		mov si, offset not_accept_draw_msg
		mov cx, 27
		rep movsb
		call Add_BufferString_To_History
		mov al, 'N'
		call Serial_AL_To_Buf
		call Serial_Send_All				
		mov was_Drawn, 0
		
		ret
		not_accept_draw_msg db 'Вы не согласны на ничью    '
Execute_Nope_Cmd endp
;===============================================================
Execute_Username_Cmd proc
	mov cx, MsgBuf_Pointer
	sub cx, offset Message_Buffer
	sub cx, 9
	cmp cx, 20
	jb $+3
	ret
	cmp cx, 0
	ja $+3
	ret
	
	push cx
	mov di, offset BufferString
	mov si, offset send_name_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History
	
	pop cx
	mov al, 'U'
	call Serial_AL_To_Buf
	mov al, cl
	call Serial_AL_To_Buf
	
	mov si, offset Message_Buffer
	add si, 9
	mov di, offset Your_Name
	mov Your_Name_Set, cl
	add_username_loop:
		lodsb
		push di
		call Serial_AL_To_Buf
		pop di
		stosb
		loop add_username_loop
	
	call Serial_Send_All
	call Update_Name_Box
	ret
	send_name_msg db 'Вы представились сопернику '
Execute_Username_Cmd endp
;===============================================================
Your_Name db 20 dup(' ')
Your_Name_Set db 0
Your_Name_Default db 'You'
Enemy_Name db 20 dup(' ')
Enemy_Name_Set db 0
Enemy_Name_Default db 'Foe'
;===============================================================
Update_Name_Box proc
	xor cx, cx
	cmp Your_Name_Set, 0
	mov cx, 3
	mov si, offset Your_Name_Default
	je name_here_1
	mov cl, Your_Name_Set
	mov si, offset Your_Name
	name_here_1:
	
	mov rs_length, cx
	
	mov di, offset result_string
	
	rep movsb
	mov al, ' '
	stosb
	mov al, ':'
	stosb
	mov al, ' '
	stosb
	add rs_length, 3
	
	cmp Enemy_Name_Set, 0
	mov cx, 3
	mov si, offset Enemy_Name_Default
	je name_here_2
	mov cl, Enemy_Name_Set
	mov si, offset Enemy_Name
	name_here_2:
	add rs_length, cx
	
	rep movsb
	
	mov ax, 1300h
	mov bx, 0fh
	mov cx, 45
	mov dx, 1903h
	mov bp, offset empty_string_1
	int 10h	
	
	mov ax, 1300h
	mov bx, 0fh
	mov cx, rs_length
	mov dx, 1903h
	mov bp, offset result_string
	int 10h	
	
	ret
	result_string db 50 dup (' ')
	empty_string_1 db 50 dup(' ')
	rs_length dw 0
Update_Name_Box endp
;===============================================================
;===============================================================