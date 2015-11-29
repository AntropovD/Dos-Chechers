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
	mov CURSOR_POSITION, 0184h
	call Set_Cursor_Position_To_Variable
	ret
Mouse_Init endp

Mouse_Handler:
	mov ax, 3
	int 33h
	mov CURSOR_Y, cx
	mov CURSOR_X, dx
	mov MouseClick_flag, 1	
	retf

Check_Mouse proc
	cmp MouseClick_flag, 1
	jne check_mouse_exit
	mov MouseClick_flag, 0
	call Print_Mouse_Coords

	check_mouse_exit:
	ret
Check_Mouse endp



Set_Cursor_Position_To_Variable proc
	mov ah, 02
	mov bh, 0	
	mov dx, CURSOR_POSITION
	int 10h
	ret
Set_Cursor_Position_To_Variable endp	

Print_BX proc
	mov ah, 2
	mov cl, 16
	_print_loop_bx:
		sub cl, 4
		mov si, bx
		shr si, cl
		and si, 0Fh
		mov dl, HEX_SYMBOLS[si]
		int 21h

		cmp cl, 0
		jnz _print_loop_bx
	ret
Print_BX endp

	HEX_SYMBOLS db '0123456789ABCDEF'

	CURSOR_POSITION dw ?
	CURSOR_X dw ?
	CURSOR_Y dw ?
	MouseClick_flag db 0
