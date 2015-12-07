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
	;твой цвет?
	call Get_Board_Value_By_AX_to_AL
	cmp al, 1
	jne fail_make_move
	; пустая клетка
	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne fail_make_move

	call Can_Pawn_Move_like_This_Cx_Dx
	cmp ax, 0
	je fail_make_move		
	
	success_make_move:
		call AddMessage_Can_Make_Move
		mov ax, 1
		pop dx cx
		ret
		
	fail_make_move:
		call AddMessage_Cannot_Make_Move		
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
	mov ax, Last_Pawned_Cell
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
	call Repaint_Cell	
	call Remove_Pawn_From_Board
	mov bl, 1
	call Set_New_Pawn_On_Board
	mov bl, PAWN_WHITE
	call Draw_New_Pawn_On_Screen
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
Can_Pawn_Сut_Like_This_Cx_Dx proc
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
Can_Pawn_Сut_Like_This_Cx_Dx endp
;===============================================================
Can_Cut_Pawn proc
	push cx dx

	mov ax, cx
	;твой цвет?
	call Get_Board_Value_By_AX_to_AL
	cmp al, 1
	jne fail_cut
	; пешка врага
	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne fail_cut

	call Can_Pawn_Сut_like_This_Cx_Dx
	cmp ax, 1
	jne fail_cut

	mov ax, bx
	mov Last_Pawned_Cell, bx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 2
	jne fail_cut

	good_cut:
		call AddMessage_Can_Cut
		mov ax, 1
		pop dx cx
		ret
	fail_cut:
		call AddMessage_Cannot_Cut
		mov ax, 0
		pop dx cx
		ret	
Can_Cut_Pawn endp
;===============================================================
Try_Cut_Pawn proc
	call Repaint_Cell	
	call Repaint_Pawned_Cell
	call Remove_Pawn_From_Board
	call Remove_Pawned_Pawn_From_Board
	mov bl, 1
	call Set_New_Pawn_On_Board
	mov bl, PAWN_WHITE
	call Draw_New_Pawn_On_Screen
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
		add al, 01
		jmp find_mid_cell_ret
	find_4:
		sub al, 01
		jmp find_mid_cell_ret
	find_2:
		add ah, 01
		jmp find_mid_cell_ret
	find_3:
		sub ah, 01
		jmp find_mid_cell_ret

	find_mid_cell_ret:
	pop dx cx
	ret
Find_Middle_Cell endp




