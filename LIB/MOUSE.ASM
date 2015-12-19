;===============================================================
Mouse_Init proc 
	mov ax, 0
	int 33h
	mov ax, 1
	int 33h
	
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
	cmp MouseClick_flag, 1
	jne check_mouse_exit
	mov MouseClick_flag, 0	
	
	cmp STATE, 4
	jl check_mouse_exit
	
	cmp TURN, 1
	jne check_mouse_exit
	
	cmp CURSOR_X, 384
	jge check_mouse_exit
	cmp CURSOR_Y, 384
	jge check_mouse_exit

	cmp LAST_CHOSEN_BOX, 0ffffh
	je first_pawn_in_move

	Continue_Moving:
		call Get_Box_From_Coords
		mov dx, ax				
		mov cx, LAST_CHOSEN_BOX
		
		call Can_Cut_King_Position_To_Bx
		cmp ax, 1
		je Possible_Cut_King
		
		call Can_Cut_Pawn
		cmp ax, 1
		je Possible_Cut_Pawn
		
		call Check_Possible_Cut_CX
		cmp ax, 1
		je check_mouse_exit

		call Can_Make_Move
		cmp ax, 1
		je Possible_Make_Move		
		
			call Unhighlight_Box
			mov LAST_CHOSEN_BOX, 0ffffh
			ret
			
		Possible_Make_Move:	
			call Try_Make_Move		
			;mov TURN, 2			
			mov LAST_CHOSEN_BOX, 0ffffh
			ret
		
		Possible_Cut_King:
			mov Last_Was_King, 1
			call Try_Cut_King
			call Check_Another_Possible_Cut_King
			cmp ax, 1
			je can_another_cut			
			jmp cant_another_cut			

		Possible_Cut_Pawn:
			call Try_Cut_Pawn	
			call Check_Another_Possible_Cut		
			cmp ax, 1
			je can_another_cut
			
			cant_another_cut:				
				push dx
				mov al, 'S'
				call Serial_AL_To_Buf
				mov cx, cb_pointer
				sub cx, offset cut_buffer
				mov bp, offset cut_buffer				
				send_loop:
					mov dx, [bp]
					call Reverse_DX					
					add dx, 3030h
					mov al, dl
					call Serial_AL_To_Buf
					mov al, dh 
					call Serial_AL_To_Buf
					add bp, 2	
					sub cx, 2
					cmp cx, 0
					jne send_loop
				pop dx
				call Reverse_DX
				mov al, dh
				add al, '0'
				call Serial_AL_To_Buf		
				mov al, dl
				add al, '0'
				call Serial_AL_To_Buf		
				mov al, 'E'
				call Serial_AL_To_Buf				
				call Serial_Send_All	
				mov LAST_CHOSEN_BOX, 0ffffh
			;	mov TURN, 2
				ret
			can_another_cut:				
				mov ax, dx				
				mov LAST_CHOSEN_BOX, dx
				cmp dl, 8
				jne not_put_king
				mov Last_Was_King, 1
				not_put_king:
				mov bp, cb_pointer
				mov byte ptr [bp], ah
				mov byte ptr [bp+1], al		
				add cb_pointer, 2
				call Highlight_Box				
				ret		

	first_pawn_in_move:
		call Check_If_Maximal_Cut_Way
		cmp ax, 1
		jne check_mouse_exit
		call Get_Box_From_Coords				
		mov bp, offset cut_buffer
		mov cb_pointer, bp
		mov byte ptr [bp], ah
		mov byte ptr [bp+1], al		
		add cb_pointer, 2
		call Get_Board_Value_By_AX_to_AL
		cmp al, 1
		je sth_good_pawn
		cmp al, 3
		je sth_good_king
		jmp check_mouse_exit
		sth_good_king:
			mov Last_Was_King, 1
			jmp sth_good
		sth_good_pawn:
			mov Last_Was_King, 0
		sth_good:
			jne check_mouse_exit
			call Highlight_Box
			call Get_Box_From_Coords
			mov LAST_CHOSEN_BOX, ax			
	check_mouse_exit:
	ret
	
	cut_buffer db 40 dup (0)
	cb_pointer dw 0	
	king_can_msg db 'King can                   '
Check_Mouse endp
;===============================================================
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
	push bx cx dx	
	dec ah
	dec al
	cmp ah, 7 
	jg fail_get_value
	cmp al, 7
	jg fail_get_value

	mov bx, ax
	mov ax, 7
	sub al, bl
	shl ax, 3
	mov bl, 0
	xchg bl, bh	
	add ax, bx
	mov bp, ax
	mov al, byte ptr BOARD[bp]	
	pop dx cx bx
	ret	
	
	fail_get_value:
		mov ax, 0ffh
		pop dx cx bx
		ret
Get_Board_Value_By_AX_to_AL endp
;===============================================================
Update_Hist_Buf proc
	push cs 
	pop es
	
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
Check_If_Maximal_Cut_Way proc
	mov ax, 1
	ret
Check_If_Maximal_Cut_Way endp
;===============================================================	
	LAST_CHOSEN_BOX dw 0ffffh	
	CURSOR_X dw ?
	CURSOR_Y dw ?
	MouseClick_flag db 0
	BufferString db 27 dup(' ')
	Last_Was_King db 0