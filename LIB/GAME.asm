
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
;===============================================================
;===============================================================
;===============================================================





