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
	cmp MouseClick_flag, 1
	jne check_mouse_exit
	mov MouseClick_flag, 0	

	cmp CURSOR_X, 384
	jge check_mouse_exit
	cmp CURSOR_Y, 384
	jge check_mouse_exit

	call Print_Mouse_Coords
	cmp LAST_CHOSEN_BOX, 255
	je first_pawn_in_move

	Continue_Moving:
		; call Get_Board_Number
		; mov ax, LAST_CHOSEN_BOX
		; mov bl, 8
		; div bl
		; mov dx, ax
		call Can_Make_Move
		cmp ax, 1
		je Possible_Make_Move

		Cannot_Make_Move:		
			call Unhighlight_Box
			mov LAST_CHOSEN_BOX, 255
			; mov si, offset Cant_Make_Move_Msg
			; mov di, HB_Pointer
			; mov cx, 18
			; repne movsb
			; mov cx, 9
			; mov al, ' '
			; repne stosb
			; mov Update_History_Buffer_Flag, 1

			ret
		Possible_Make_Move:
			ret

	first_pawn_in_move:
		call Highlight_Box	
		call Get_Board_Number	
		mov LAST_CHOSEN_BOX, ax
	check_mouse_exit:
	ret
Check_Mouse endp	
;===============================================================
Get_Box_From_Coords_In_Ax proc
	mov bl, 48
	div bl
	xor bx, bx
	mov bl, al
	mov ax, bx
	ret
Get_Box_From_Coords_In_Ax endp
;===============================================================
Print_Mouse_Coords proc
	push cs
	pop es

	mov ax, CURSOR_Y
	call Get_Box_From_Coords_In_Ax	
	add al, '0'
	mov di, offset BufferString	

	stosb
	mov al, ':'
	stosb	

	mov ax, CURSOR_X
	call Get_Box_From_Coords_In_Ax	
	add al, '0'
	stosb

	mov cx, 24
	mov al, ' '
	repne stosb

	call Add_BufferString_To_History
	ret
Print_Mouse_Coords endp
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
Highlight_Box proc
	mov ax, CURSOR_Y
	call Get_Box_From_Coords_In_Ax
	mov bl, 48
	mul bl
	push ax
	mov ax, CURSOR_X
	call Get_Box_From_Coords_In_Ax
	mov bl, 48
	mul bl
	mov dx, ax
	pop cx		
	call Highlight_Chosen_Box
	ret
Highlight_Box endp
;===============================================================
Get_Board_Number proc
	mov ax, CURSOR_Y
	call Get_Box_From_Coords_In_Ax
	push ax
	mov ax, CURSOR_X
	call Get_Box_From_Coords_In_Ax
	pop bx
	add ax, bx
	ret
Get_Board_Number endp



	LAST_CHOSEN_BOX db 255
	
	Cant_Make_Move_Msg db 'You cant make move',0
	CURSOR_X dw ?
	CURSOR_Y dw ?
	MouseClick_flag db 0
	BufferString db 27 dup(' ')
;===============================================================
	;HEX_SYMBOLS db '0123456789ABCDEF'
	; Print_AX proc
	; 	mov bx, ax
	; 	mov ah, 2
	; 	mov cl, 16
	; 	_print_loop_bx:
	; 		sub cl, 4
	; 		mov si, bx
	; 		shr si, cl
	; 		and si, 0Fh
	; 		mov dl, HEX_SYMBOLS[si]
	; 		cmp dl, '0'
	; 		je $+4
	; 		int 21h

	; 		cmp cl, 0
	; 		jnz _print_loop_bx
	; 	ret
	; Print_AX endp
;===============================================================