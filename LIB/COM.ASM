;===============================================================
Send_Sync_Impulse proc
	mov al, 01h
	call Serial_AL_To_Buf
	call Serial_Send_All	
	ret
Send_Sync_Impulse endp
;===============================================================

Check_Com_Port proc
	call Serial_Check_Sth_Come	
	je nothing_comes
	
	
	
	call Serial_Get_Symbol_To_AL
	
		
		cmp message_buffer_1_flag, 1
		jne check_username_buffer
		cmp message_length, 0ffh
		jne not_first_symbol_in_message
		mov message_length, al
		mov bp, offset message_buffer_1
		mov byte ptr [bp], '$'
		inc message_buffer_1_pointer
		inc bp
		mov byte ptr [bp], ' '
		inc message_buffer_1_pointer
		ret
		not_first_symbol_in_message:
			mov sync_exit, 0
			mov bp, message_buffer_1_pointer
			mov [bp], al
			inc message_buffer_1_pointer
			dec message_length
			cmp message_length, 0
			je $+3
			ret 
			mov message_buffer_1_flag, 0
			mov message_length, 0ffh
			mov cx, message_buffer_1_pointer
			sub cx, offset message_buffer_1
			cmp cx, 54
			jl $+3			
			ret
			call Write_Arrived_Message
			ret
		
		
		
	check_username_buffer:	
		cmp username_buffer_flag, 1
		jne check_cmd_buffer
		cmp username_length, 0ffh
		jne not_first_symbol_in_username
		mov username_length, al
		ret
		not_first_symbol_in_username:
			mov sync_exit, 0
			mov bp, username_pointer
			mov [bp], al
			inc username_pointer
			dec username_length
			cmp username_length, 0
			je $+3
			ret
			mov username_buffer_flag, 0
			mov username_length, 0ffh
			
			mov cx, username_pointer
			sub cx, offset username_buffer
			
			cmp cx, 20
			jl $+3
			ret
			mov Enemy_Name_Set, cl
			mov si, offset username_buffer
			mov di, offset Enemy_Name
			
			rep movsb
			
			call Update_Name_Box
			ret
			
	
	check_cmd_buffer:
		cmp command_buffer_flag, 1
		jne ____01h
		cmp al, 'E'
		je Execute_Commmand_From_Serial
		mov bp, cmbuffer_pointer
		mov [bp], al
		inc cmbuffer_pointer

	____01h:
		cmp al, 01h
		jne not_01h
		call Sync_Comes
		jmp nothing_comes

	not_01h:
		cmp al, 'B'
		jne not_B
		mov STATE, 2
		mov Opponent_Choise, 0ffh
		jmp nothing_comes

	not_B:
		cmp al, 'C'
		jne not_C
		cmp STATE, 2
		jne nothing_comes
		mov STATE, 3		
		jmp nothing_comes

	not_C:
		cmp al, 'D'
		jne not_D
		cmp State, 3
		jne not_D
		
		mov di, offset BufferString
		mov si, offset ready_msg
		mov cx, 27
		rep movsb
		call Add_BufferString_To_History
		mov STATE, 4

	not_D:
		cmp al, 'S'
		jne not_S
		mov command_buffer_flag, 1
		mov bp, offset command_buffer
		mov cmbuffer_pointer, bp
		ret
		
	not_S:
		cmp al, 'F'
		jne not_F
		call ENEMY_SURRENDER

	not_F:
		cmp al, 'G'
		jne not_G
		mov di, offset BufferString
		mov si, offset drawn_msg
		mov cx, 27
		rep movsb
		call Add_BufferString_To_History	
		mov was_Drawn, 1		

	not_G:
		cmp al, 'M'
		jne not_M
		mov message_buffer_1_flag, 1
		mov bp, offset message_buffer_1
		mov message_buffer_1_pointer, bp
		ret

	not_M:
		cmp al, 'U'
		jne not_U
		mov username_buffer_flag, 1
		mov bp, offset username_buffer
		mov username_pointer, bp
		mov di, offset BufferString
		mov si, offset send_name_msg_2
		mov cx, 27
		rep movsb
		call Add_BufferString_To_History
		
		ret
		
	not_U:
		cmp al, 'Y'
		jne not_Y
		cmp Your_Drawn, 1
		je $+3
		ret
		call EXECUTE_DRAWN_AGREE
		ret

	not_Y:
		cmp al, 'N'
		jne not_N
		cmp Your_Drawn, 1
		je $+3
		ret
		mov your_drawn, 0
		mov was_Drawn,0
		ret

	not_N:
		cmp al, 'R'
		jne not_R

	not_R:
		cmp al, 'W'
		jne not_W

	not_W:
		cmp al, 'H'
		jne not_H
		cmp STATE, 6
		jne nothing_comes
		mov Enemy_agree_new, 1
		call Check_Agree_For_New	
		
	not_H:
		cmp al, '1'
		jne not_1
		cmp State, 3		
		jne not_1
		mov Opponent_Choise, '1'
		call Check_Opponent_Choise
		ret

	not_1:
		cmp al, '2'
		jne not_2
		cmp State, 3 
		jne not_2
		mov Opponent_Choise, '2'
		call Check_Opponent_Choise
		ret
		

	not_2:
		cmp al, '3'
		jne not_3
		cmp State, 3 
		jne not_3
		mov Opponent_Choise, '3'
		call Check_Opponent_Choise
		ret

	not_3:

	nothing_comes:
	ret

	Execute_Commmand_From_Serial:
		mov command_buffer_flag, 0
		mov cx, cmbuffer_pointer
		sub cx, offset command_buffer
		mov di, offset command_buffer
		call ExecuteCommand_In_Di_Size_CX
		call Send_Move_Accept
		ret


	command_buffer_flag db 0
	command_buffer db 40 dup(' ')
	cmbuffer_pointer dw 0
	
	username_buffer_flag db 0
	username_buffer db 40 dup(' ')
	username_pointer dw 0
	username_length db 0ffh
	
	message_buffer_1_flag db 0
	message_buffer_1 db 54 dup(' ')
	message_buffer_1_pointer dw 0
	message_length db 0ffh
	
	
	ready_msg db 'Противник готов к игре     '	
	drawn_msg db 'Соперник предложил ничью   ' 
	send_name_msg_2 db 'Соперник представился      '
Check_Com_Port endp
;===============================================================
Sync_Comes proc
	cli
	mov sync_exit, 0
	cmp STATE, 0
	jne exit_of_here
	mov STATE, 1
	call Connection_Estabilished
	mov al, 01h
	call Serial_AL_To_Buf
	mov al, 'B'
	call Serial_AL_To_Buf	
	call Serial_Send_All
	exit_of_here:
	sti
	ret
Sync_Comes endp
;===============================================================
; dl - '1' - rock '2'-┬н┬о┬ж┬н┬и├ж├л '3' - ┬б├г┬м┬а┬г┬а
Send_Rock_Scissors proc
	push ax
	mov al, 'C'
	call Serial_AL_To_Buf
	mov al, dl
	call Serial_AL_To_Buf
	call Serial_Send_All
	pop ax
	ret
Send_Rock_Scissors endp
;===============================================================
ConnectionLost_Message proc
	push cs
	pop es
	mov di, offset BufferString
	mov si, offset connection_lost_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History
	ret	
 	connection_lost_msg db 'Соединение потеряно.       '	
ConnectionLost_Message endp
;===============================================================
Connection_Estabilished proc	
	mov di, offset BufferString
	mov si, offset connection_set_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	mov di, offset BufferString
	mov si, offset choose_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	ret	
 	connection_set_msg db 'Соединение установлено     '
	choose_msg	   db 'Камень, ножницы, бумага?   '

Connection_Estabilished endp
;===============================================================
Send_Move_Accept proc
	mov al, 'R'
	call Serial_AL_To_Buf
	call Serial_Send_All	
	ret
	ret
Send_Move_Accept endp
;===============================================================
AddMessage_Your_Turn proc
	mov di, offset BufferString
	mov si, offset your_move_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	ret	
 	your_move_msg db 'Ваш ход                    '
AddMessage_Your_Turn endp
;===============================================================
AddMessage_Enemy_Turn proc
	mov di, offset BufferString
	mov si, offset enemy_move_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	ret	
 	enemy_move_msg db 'Ход противника             '
AddMessage_Enemy_Turn endp
;===============================================================
ENEMY_SURRENDER proc
	cmp STATE, 4
	je $+3
	ret
	mov STATE, 6
	mov di, offset BufferString
	mov si, offset surr_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
	
	mov di, offset BufferString
	mov si, offset again_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
	
	ret	
 	surr_msg db 'Противник сдался!          '	
ENEMY_SURRENDER endp
;===============================================================
AddMessage_YOU_WIN proc
	mov di, offset BufferString
	mov si, offset win_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
	
	mov di, offset BufferString
	mov si, offset again_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
	ret
	
	win_msg 	db 'Вы победили!               '
	again_msg   db 'Начать заново?             '
AddMessage_YOU_WIN endp
;===============================================================
was_Drawn db 0
;===============================================================
Write_Arrived_Message proc
	mov di, offset BufferString
	lea si, message_buffer_1
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
	
	mov di, offset BufferString
	lea si, message_buffer_1[27]
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
		
	mov si, offset message_buffer_1_empty
	mov di, offset message_buffer_1
	mov cx, 81
	
	rep movsb
	
	ret
	message_buffer_1_empty db 54 dup(' ')
Write_Arrived_Message endp
;===============================================================



;===============================================================