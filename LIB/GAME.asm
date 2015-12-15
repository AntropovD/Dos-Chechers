;===============================================================
Can_Make_Move proc
	push cx dx

	mov ax, cx
	;╤В╨▓╨╛╨╣ ╤Ж╨▓╨╡╤В?
	call Get_Board_Value_By_AX_to_AL
	cmp al, 1
	jne fail_make_move
	; ╨┐╤Г╤Б╤В╨░╤П ╨║╨╗╨╡╤В╨║╨░
	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne fail_make_move

	call Can_Pawn_Move_like_This_Cx_Dx
	cmp ax, 0
	je fail_make_move		
	
	success_make_move:
		mov ax, 1
		pop dx cx
		ret
		
	fail_make_move:
		mov ax, 0
		pop dx cx
		ret
Can_Make_Move endp
;===============================================================
Remove_Pawn_From_Board proc
	push cx dx
	mov ax, cx
	mov dl, 0
	call Set_Board_Value_To_AX_From_DL
	pop dx cx
	ret
Remove_Pawn_From_Board endp
;===============================================================
Remove_Pawned_Pawn_From_Board proc
	push cx dx
	call Find_Middle_Cell	
	mov dl, 0
	call Set_Board_Value_To_AX_From_DL
	pop dx cx
	ret
Remove_Pawned_Pawn_From_Board endp
;===============================================================
;set BOARD[ah*8+al]
Set_Board_Value_To_AX_From_DL proc
	dec ah
	dec al
	mov bx, ax
	mov ax, 7
	sub al, bl
	shl ax, 3
	mov bl, 0
	xchg bl, bh	
	add ax, bx
	mov bp, ax
	mov byte ptr BOARD[bp], dl	
	ret	
Set_Board_Value_To_AX_From_DL endp
;===============================================================
;bl-colour
Set_New_Pawn_On_Board proc
	push cx dx
	mov ax, dx
	mov dl, bl
	call Set_Board_Value_To_AX_From_DL
	pop dx cx
	ret
Set_New_Pawn_On_Board endp
;===============================================================
;bl-colour
Draw_New_Pawn_On_Screen proc
	push cx dx
	push bx
	mov cx, dx
	dec ch 
	dec cl
	xchg cl, ch
	mov bl, 48
	xor dx, dx
	mov dl, ch
	mov ch, 0
	mov ax, cx
	mul bl
	mov cx, ax
	mov ax, 7
	sub ax, dx
	mul bl
	mov dx, ax
	
	mov ax, 2
	int 33h
	pop bx
	mov al, bl
	call Change_Colour
 	call Draw_Pawn
 	mov ax, 1 
 	int 33h

	pop dx cx
	ret
Draw_New_Pawn_On_Screen endp
;===============================================================
Try_Make_Move proc
	push cx dx
	call Repaint_Cell	
	call Remove_Pawn_From_Board
	mov bl, 1
	call Set_New_Pawn_On_Board
	mov bl, PAWN_WHITE
	call Draw_New_Pawn_On_Screen
	pop dx cx
	SEND_COMMAND:
		call Reverse_Cx_Dx
		mov al, 'S'
		call Serial_AL_To_Buf
		mov al, ch
		add al, '0'
		call Serial_AL_To_Buf
		mov al, cl
		add al, '0'
		call Serial_AL_To_Buf
		mov al, dh
		add al, '0'
		call Serial_AL_To_Buf
		mov al, dl
		add al, '0'
		call Serial_AL_To_Buf
		mov al, 'E'
		call Serial_AL_To_Buf				
		call Serial_Send_All	
	
	ret
Try_Make_Move endp
;===============================================================
Can_Pawn_Move_like_This_Cx_Dx proc
	push cx dx
	add dx, 3030h	
	sub dh, ch
	sub dl, cl
	cmp dl, 30h
	jl pawn_cant
	cmp dl, 31h
	jg pawn_cant
	cmp dh, 2fh
	jl pawn_cant
	cmp dh, 31h
	jg pawn_cant


		mov ax, 1
		pop dx cx
		ret
	pawn_cant:
		mov ax,0
		pop dx cx
		ret	
Can_Pawn_Move_like_This_Cx_Dx endp
;===============================================================
Can_Pawn_Cut_like_This_Cx_Dx proc
	push cx dx
	add dx, 3030h
	sub dx, cx
	mov ax, dx
	mov bx, cx
	cmp ax, 3032h
	je _good_cut_1
	cmp ax, 2e30h
	je _good_cut_2
	cmp ax, 3230h
	je _good_cut_3

	
	bad_cut:
		mov ax, 0
		pop dx cx
		ret
	_good_cut_1:
		mov ax, 1
		add bl, 01h
		pop dx cx	
		ret
	_good_cut_2:
		mov ax, 1
		sub bh, 01
		pop dx cx	
		ret
	_good_cut_3:
		mov ax, 1
		add bh, 01
		pop dx cx	
		ret
Can_Pawn_Cut_like_This_Cx_Dx endp
;===============================================================
Can_Cut_Pawn proc
	push cx dx

	mov ax, cx
	;your color
	call Get_Board_Value_By_AX_to_AL
	cmp al, 1
	jne fail_cut
	; enemy pawn
	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne fail_cut

	call Can_Pawn_Cut_like_This_Cx_Dx
	cmp ax, 1
	jne fail_cut

	mov ax, bx
	mov Last_Pawned_Cell, bx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 2
	jne fail_cut

	good_cut:		
		mov ax, 1
		pop dx cx
		ret
	fail_cut:		
		mov ax, 0
		pop dx cx
		ret	
Can_Cut_Pawn endp
;===============================================================
Try_Cut_Pawn proc
	push dx
	call Repaint_Cell	
	call Repaint_Pawned_Cell
	call Remove_Pawn_From_Board
	call Remove_Pawned_Pawn_From_Board
	mov bl, 1
	call Set_New_Pawn_On_Board
	mov bl, PAWN_WHITE
	call Draw_New_Pawn_On_Screen
	pop dx
	ret
Try_Cut_Pawn endp
;===============================================================
Last_Pawned_Cell dw 0
;===============================================================
; cx, dx
; return ax
Find_Middle_Cell proc
	push cx dx
	add dx, 3030h
	sub dx, cx
	mov ax, cx

	cmp dx, 3032h
	je find_1
	cmp dx, 2e30h
	je find_2
	cmp dx, 3230h
	je find_3
	cmp dx, 302eh
	je find_4
	mov ax, 0ffffh
	pop dx cx
	ret


	find_1:
		inc al
		jmp find_mid_cell_ret
	find_4:
		dec al
		jmp find_mid_cell_ret
	find_2:
		dec ah
		jmp find_mid_cell_ret
	find_3:
		inc ah
		jmp find_mid_cell_ret

	find_mid_cell_ret:
	pop dx cx
	ret
Find_Middle_Cell endp
;===============================================================	
Check_Another_Possible_Cut proc
	push cx dx

	mov cx, dx
	add dl, 2
	call Check_For_Cut
	cmp ax, 1
	je possible_cut
	sub dl, 2

	add dh, 2
	call Check_For_Cut
	cmp ax, 1
	je possible_cut

	sub dh, 4
	call Check_For_Cut
	cmp ax, 1
	je possible_cut


	not_possible_cut:
		mov ax, 0
		pop dx cx
		ret
		
	possible_cut:
		mov ax, 1
		pop dx cx
		ret
Check_Another_Possible_Cut endp
;===============================================================
Check_For_Cut proc
	push cx dx
	
	call Find_Middle_Cell
	call Get_Board_Value_By_AX_to_AL
	cmp al, 2
	jne cant_cut

	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne cant_cut	

	can_cut:
		mov ax, 1
		pop dx cx
		ret
	cant_cut:
		mov ax, 0
		pop dx cx
		ret
Check_For_Cut endp
;===============================================================
AddMessage_Equal proc
	mov di, offset BufferString
	mov si, offset choose_msg2
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History
	call AddMessage_Input_Paper_Rock_Scissors


	ret	 	
	choose_msg2	   db 'Результаты совпали.        '
	
AddMessage_Equal endp
;===============================================================
Check_Opponent_Choise  proc	
	cmp MY_CHOISE, 0ffh
	je not_input_choise

	cmp Opponent_Choise, 0ffh
	je not_input_choise_2

	mov bl, Opponent_Choise
	cmp bl, MY_CHOISE
	je _equal


		cmp MY_CHOISE, '1'
		jne check_2_3
		cmp Opponent_Choise, '2'
		je you_win
		jmp you_lose

	check_2_3:

		cmp MY_CHOISE, '2'
		jne check_3
		cmp Opponent_Choise, '3'
		je you_win
		jmp you_lose


	check_3:
		cmp MY_CHOISE, '3'
		jne some_error
		cmp Opponent_Choise, '1'
		je you_win
		jmp you_lose

	some_error:
		ret
		_equal:
			mov State, 1
			mov MY_CHOISE, 0ffh
			mov Opponent_Choise, 0ffh
			call AddMessage_Equal
			ret

		you_win:
			mov MY_CHOISE, 0ffh
			mov Opponent_Choise, 0ffh
			call Win_Rock
			ret

		you_lose:	
			mov MY_CHOISE, 0ffh
			mov Opponent_Choise, 0ffh
			call Lose_Rock
			ret

		not_input_choise:
			call AddMessage_Input_Paper_Rock_Scissors
		not_input_choise_2:
			ret
Check_Opponent_Choise endp
;===============================================================
Win_Rock proc
	mov di, offset BufferString
	mov si, offset win_rock_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History


	mov di, offset BufferString
	mov si, offset win_rock_msg2
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	mov al, 'D'
	call Serial_AL_To_Buf
	call Serial_Send_All
	
	mov YOUR_COLOR, 1
	mov TURN, 1	
	mov ax, 2
	int 33h
	call Draw_Pawns
	mov ax, 1
	int 33h
	ret

	win_rock_msg db 'Розыгрыш хода выигран.     '
	win_rock_msg2 db 'Вы играете белыми          '
Win_Rock endp
;===============================================================
Lose_Rock proc
	mov di, offset BufferString
	mov si, offset lost_rock_msg 
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	mov di, offset BufferString
	mov si, offset lost_rock_msg2
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	mov al, 'D'
	call Serial_AL_To_Buf
	call Serial_Send_All

	mov YOUR_COLOR, 2	
	mov bl, PAWN_WHITE
	mov bh, PAWN_BLACK
	mov PAWN_BLACK, bl
	mov PAWN_WHITE, bh	

	mov ax, 2
	int 33h
	call Draw_Pawns
	mov ax, 1
	int 33h
	mov TURN, 2
	
	ret
	lost_rock_msg db 'Розыгрыш хода проигран.    '
	lost_rock_msg2 db 'Вы играете черными         '
Lose_Rock endp
;===============================================================
Get_Enemy_Colour proc
	cmp YOUR_COLOR, 1
	je mov_white
		mov bl, PAWN_WHITE
		ret
	mov_white:
		mov bl, PAWN_BLACK
	ret
Get_Enemy_Colour endp
;===============================================================
Make_Step_Cx_Dx proc
	
	push cx dx
	call Repaint_Cell	
	mov ax, cx
	call Get_Board_Value_By_AX_to_AL
	push ax
	call Remove_Pawn_From_Board
	pop bx
	call Set_New_Pawn_On_Board
	mov bl, PAWN_BLACK
	call Draw_New_Pawn_On_Screen
	pop dx cx
	
	ret
Make_Step_Cx_Dx endp
;===============================================================
Reverse_Cx_Dx proc
	cmp YOUR_COLOR, 1
	jne $+1
	ret
	mov bx, 0909h
	sub bh, ch
	sub bl, cl
	mov cx, bx
	mov bx, 0909h
	sub bh, dh
	sub bl, dl
	mov dx, bx
	ret
Reverse_Cx_Dx endp
;===============================================================
Reverse_DX proc
	cmp YOUR_COLOR, 1
	jne $+1
	ret
	mov bx, 0909h
	sub bh, dh
	sub bl, dl
	mov dx, bx
	ret
Reverse_DX endp
;===============================================================

ExecuteCommand_In_Di_Size_CX proc
	mov cmd_size, cx
	push di
	sub30_loop:
		mov bl, [di]
		sub bl, 30h
		mov [di], bl
		inc di
		loop sub30_loop
	pop di

	; mov ch, [di]
	; mov cl, [di+1]
	; mov dh, [di+2]
	; mov dl, [di+3]
	; call Reverse_Cx_Dx
	; push cx dx
	; mov ax, cx
	; call Get_Board_Value_By_AX_to_AL
	; cmp al, 2
	; jne fail_execute
	; mov ax, dx
	; call Get_Board_Value_By_AX_to_AL
	; cmp al,0
	; jne fail_execute
	
	; call Make_Step_Cx_Dx
	; mov TURN, 1
	
	; fail_execute:
		; pop dx cx
		; ret
	mov ch, [di]
	mov cl, [di+1]
	mov dh, [di+2]
	mov dl, [di+3]
	call Reverse_Cx_Dx
	
	mov ax, cx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 2
	jne not_can_command
	
	call Can_Enemy_Do_Move_Command_Cx_Dx
	cmp ax, 1
	je can_move_command	

	call Can_Enemy_Do_Pawn_Command_Cx_dx
	cmp ax, 1
	jne not_can_command
	
		; cmp cmd_size, 2
		; je can_pawn_command
		; all_moves_loop:				
			; mov cx, dx
			; mov dh, byte ptr[di]
			; mov dl, byte ptr[di+1]
				; call Can_Enemy_Do_Pawn_Command_Cx_dx
				; cmp ax, 1
				; jne not_can_command
			; sub cmd_size, 2
			; cmp cmd_size, 2
			; jne all_moves_loop	

		can_pawn_command:
			call Execute_Enemy_Pawn_Command			
			mov si, di
			add si, cmd_size			
			cmp cmd_size, 4
			je can_pawn_finish
			add di, 4
			all_cuts_loop:				
				mov cx, dx
				mov dh, byte ptr[di]
				mov dl, byte ptr[di+1]
				call Reverse_DX
				push si
				call Execute_Enemy_Pawn_Command
				pop si
				add di, 2
				cmp di, si
				jne all_cuts_loop
				
			can_pawn_finish:
				mov TURN, 1
				ret

		__not_can_command_tvou_mat:
		not_can_command:
			; Send Serial can not _ do command
			mov TURN, 2
			ret

		can_move_command:
			call Make_Step_Cx_Dx
			mov TURN, 1
			ret	
	
	cmd_size dw 0
ExecuteCommand_In_Di_Size_CX endp
;===============================================================
Check_Possible_Cut_CX proc
	push cx dx

	mov dx, cx
	add dl, 2
	call Check_For_Cut
	cmp ax, 1
	je possible_cut_1
	sub dl, 2

	add dh, 2
	call Check_For_Cut
	cmp ax, 1
	je possible_cut_1

	sub dh, 4
	call Check_For_Cut
	cmp ax, 1
	je possible_cut_1

	not_possible_cut_1:
		mov ax, 0
		pop dx cx
		ret
		
	possible_cut_1:
		mov ax, 1
		pop dx cx
		ret

Check_Possible_Cut_CX	endp
;===============================================================
RESET_BOARD proc
	mov si, offset INITIALIZE_BOARD
	mov di, offset BOARD
	mov cx, 64
	rep movsb	
	ret
RESET_BOARD endp
;===============================================================
CHANGE_PAWNS_COLOUR proc
	push bx
		mov bh, PAWN_BLACK
		mov bl, PAWN_WHITE
		mov PAWN_BLACK, bl
		mov PAWN_WHITE, bh
	pop bx
	ret
CHANGE_PAWNS_COLOUR endp
;===============================================================
Check_Agree_For_New proc
	cmp Enemy_agree_new, 1
	jne agree_exit
	cmp you_agree_new, 1
	jne agree_exit
	
		call RESET_BOARD
		call CHANGE_PAWNS_COLOUR
		cmp YOUR_COLOR, 1
		je white_was
		not_white_was:
			mov YOUR_COLOR, 1
			mov TURN, 1
			jmp here
		white_was:
			mov YOUR_COLOR, 2
			mov TURN, 2
		here:
			mov sync_exit, 0
			call Draw_Chessboard
			mov sync_exit, 0
			call Draw_Pawns			
			mov STATE, 4		
		
	agree_exit:
		ret
Check_Agree_For_New endp
;===============================================================
EXECUTE_DRAWN_AGREE proc
	cmp STATE, 4
	je $+3
	ret
	mov STATE, 6
	mov di, offset BufferString
	mov si, offset drawn_agree_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
	
	mov di, offset BufferString
	mov si, offset again_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History	
	
	ret	
 	drawn_agree_msg db 'Ничья!                     '
	ret
EXECUTE_DRAWN_AGREE endp
;===============================================================
AddMessage_Input_Paper_Rock_Scissors proc
	mov di, offset BufferString
	mov si, offset choose_msg1
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	ret	 	
	choose_msg1	   db 'Камень, ножницы, бумага?   '	
AddMessage_Input_Paper_Rock_Scissors endp


