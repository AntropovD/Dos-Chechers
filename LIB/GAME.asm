;===============================================================
; cx - from, dx - to
;===============================================================
AddMessage_Cannot_Make_Move proc
	mov di, offset BufferString
	mov si, offset cannot_make_move_msg
	mov cx, 10
	repne movsb

	mov al, ' '
	mov cx, 17
	repne stosb

	call Add_BufferString_To_History
	ret
	cannot_make_move_msg db 'wrong move'	
AddMessage_Cannot_Make_Move endp
;===============================================================
AddMessage_Can_Make_Move proc
	mov di, offset BufferString
	mov si, offset can_make_move_msg
	mov cx, 10
	repne movsb

	mov al, ' '
	mov cx, 17
	repne stosb

	call Add_BufferString_To_History
	ret
	can_make_move_msg db 'goood move'	
AddMessage_Can_Make_Move endp
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
		;call AddMessage_Can_Make_Move
		mov ax, 1
		pop dx cx
		ret
		
	fail_make_move:
		;call AddMessage_Cannot_Make_Move		
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
Can_Pawn_╨бut_Like_This_Cx_Dx proc
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
Can_Pawn_╨бut_Like_This_Cx_Dx endp
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

	call Can_Pawn_╨бut_like_This_Cx_Dx
	cmp ax, 1
	jne fail_cut

	mov ax, bx
	mov Last_Pawned_Cell, bx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 2
	jne fail_cut

	good_cut:
		;call AddMessage_Can_Cut
		mov ax, 1
		pop dx cx
		ret
	fail_cut:
		;call AddMessage_Cannot_Cut
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
;===============================================================
;===============================================================
AddMessage_Cannot_Cut proc
	mov di, offset BufferString
	mov si, offset cannot_cut_msg
	mov cx, 10
	repne movsb

	mov al, ' '
	mov cx, 17
	repne stosb

	call Add_BufferString_To_History
	ret
	cannot_cut_msg db 'wrong cut '	
AddMessage_Cannot_Cut endp
;===============================================================
AddMessage_Can_Cut proc
	mov di, offset BufferString
	mov si, offset can_cut_msg
	mov cx, 10
	repne movsb

	mov al, ' '
	mov cx, 17
	repne stosb

	call Add_BufferString_To_History
	ret
	can_cut_msg db 'goood cut '	
AddMessage_Can_Cut endp
;===============================================================
AddMessage_Another_Step proc
	mov di, offset BufferString
	mov si, offset an_step_msg
	mov cx, 27
	repne movsb

	call Add_BufferString_To_History
	ret
	an_step_msg db 'You can make another step!!'	
AddMessage_Another_Step endp
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
		pop cx dx
		ret
	cant_cut:
		mov ax, 0
		pop cx dx
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
	
	mov ax, 2
	int 33h
	mov YOUR_COLOR, 1
	mov TURN, 1
	;call Draw_Chessboard
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
;	call Draw_Chessboard
	call Draw_Pawns
	mov TURN, 2
	mov ax, 1
	int 33h
	
	ret
	lost_rock_msg db 'Розыгрыш хода проигран.    '
	lost_rock_msg2 db 'Вы играете черными         '
Lose_Rock endp
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


