;===============================================================
Mouse_Init proc 
	mov ax, 0
	int 33h
	mov ax, 1
	int 33h
	push cs
	pop es
	mov ax, 0Ch
	mov cx, 0100b
	mov dx, offset Mouse_Handler
	int 33h
	ret
Mouse_Init endp
;===============================================================
Mouse_Handler:
	mov ax, 3
	int 33h
	mov CURSOR_Y, cx
	mov CURSOR_X, dx
	mov MouseClick_flag, 1	
	retf
;===============================================================
Check_Mouse proc
	push cs
	pop es
	cmp MouseClick_flag, 1
	jne check_mouse_exit
	mov MouseClick_flag, 0	

	cmp CURSOR_X, 384
	jge check_mouse_exit
	cmp CURSOR_Y, 384
	jge check_mouse_exit

	call Print_Mouse_Coords
	cmp LAST_CHOSEN_BOX, 0ffffh
	je first_pawn_in_move

	Continue_Moving:
		call Get_Box_From_Coords
		mov cx, LAST_CHOSEN_BOX
		mov dx, ax
		cmp ax, cx
		je Same_Pawn_CLick
		
		call Can_Cut_Pawn
		cmp ax, 1
		je Possible_Cut_Pawn

		call Can_Make_Move
		cmp ax, 1
		je Possible_Make_Move		

		Cannot_Make_Move:
		Same_Pawn_CLick:
			call Unhighlight_Box
			mov LAST_CHOSEN_BOX, 0ffffh
			ret
			
		Possible_Make_Move:	
			call Try_Make_Move			
			mov LAST_CHOSEN_BOX, 0ffffh
			ret

		Possible_Cut_Pawn:
			call Try_Cut_Pawn			
			mov LAST_CHOSEN_BOX, 0ffffh
			ret
		

	first_pawn_in_move:
		call Get_Box_From_Coords		
		call Get_Board_Value_By_AX_to_AL
		cmp al, 1
		jne check_mouse_exit
		call Highlight_Box
		call Get_Box_From_Coords
		mov LAST_CHOSEN_BOX, ax			
	check_mouse_exit:
	ret
Check_Mouse endp
;===============================================================
Print_Mouse_Coords proc
	push cs
	pop es
	call Get_Box_From_Coords	
	add al, '0'
	add ah, '0'
	mov di, offset BufferString		
	mov bx, ax
	mov al, bh
	stosb
	mov al, bl
	stosb	

	mov si, offset LCH_MSG
	mov cx, 11 
	repne movsb
	mov al, byte ptr LAST_CHOSEN_BOX+1
	add al, '0'
	stosb
	mov al, byte ptr LAST_CHOSEN_BOX
	add al, '0'
	stosb

	mov cx, 12
	mov al, ' '
	repne stosb
	call Add_BufferString_To_History
	ret

	LCH_MSG DB ' Last cell '	
Print_Mouse_Coords endp
;===============================================================
; ah, al -> (1,1) - первая клетка
Get_Box_From_Coords proc	
	mov cx, CURSOR_X
	mov dx, CURSOR_Y	
	mov ax, cx
	mov bx, 384
	sub bx, ax
	mov ax, bx
	mov bl, 48
	div bl
	mov ah, 0
	push ax
	mov ax, dx
	mov bl, 48
	div bl
	pop bx
	mov ah, bl
	inc ah 
	inc al
	xchg ah, al
	ret
Get_Box_From_Coords endp
;===============================================================
;===============================================================
Add_BufferString_To_History proc
	mov si, offset BufferString
	mov di, HB_Pointer
	mov cx, 27
	repne movsb
	add HB_Pointer, 27
	mov bx, HB_Pointer
	cmp bx, offset HB_End
	jne not_null_hb_pointer
	mov HB_Pointer, offset History_Buffer

	not_null_hb_pointer:
		mov Update_History_Buffer_Flag, 1
		ret
Add_BufferString_To_History endp
;===============================================================
;return BOARD[ah*8+al]
Get_Board_Value_By_AX_to_AL proc
	push cx dx
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
	mov al, byte ptr BOARD[bp]	
	pop dx cx
	ret	
Get_Board_Value_By_AX_to_AL endp
;===============================================================
Update_Hist_Buf proc
	mov ax, 1300h
	mov bx, 0fh
	mov cx, 27
	mov dx, 0083h
	mov bp, HB_Pointer

	up_hist_buf_loop:		
		inc dh
		int 10h
		add bp, 27
		cmp bp, offset HB_End
		jge bp_overflow
		bp_ret:
		cmp bp, HB_Pointer		
		jne up_hist_buf_loop
	ret

	bp_overflow:
		mov bp, offset History_Buffer
		jmp bp_ret
Update_Hist_Buf endp
;===============================================================	
	LAST_CHOSEN_BOX dw 0ffffh
	
	Cant_Make_Move_Msg db 'You cant make move',0
	CURSOR_X dw ?
	CURSOR_Y dw ?
	MouseClick_flag db 0
	BufferString db 27 dup(' ')