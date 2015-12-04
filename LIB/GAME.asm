
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
	cmp al, Your_Colour
	jne fail_make_move
	; пустая клетка
	mov ax, dx
	call Get_Board_Value_By_AX_to_AL
	cmp al, 0
	jne fail_make_move

	sub dx, cx
	cmp dh, 1
	jg fail_make_move
	cmp dl, 1
	jg fail_make_move

		
		
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
Set_New_Pawn_On_Board proc
	push cx dx
	mov ax, dx
	mov dl, Your_Colour
	call Set_Board_Value_To_AX_From_DL
	pop dx cx
	ret
Set_New_Pawn_On_Board endp
;===============================================================
Draw_New_Pawn_On_Screen proc
	push cx dx
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
 	call Draw_WhitePawn
 	mov ax, 1 
 	int 33h

	pop dx cx
	ret
Draw_New_Pawn_On_Screen endp
;===============================================================
Try_Make_Move proc
	call Repaint_Cell	
	call Remove_Pawn_From_Board
	call Set_New_Pawn_On_Board
	call Draw_New_Pawn_On_Screen
	ret
Try_Make_Move endp
;===============================================================





