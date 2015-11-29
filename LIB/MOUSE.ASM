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
	ret
Mouse_Init endp

Mouse_Handler:
	mov ax, 3
	int 33h
	mov CURSOR_X, cx
	mov CURSOR_Y, dx
	mov MouseClick_flag, 1	
	retf

Check_Mouse proc
	call Print_Mouse_Coords
	ret
Check_Mouse endp


Print_Mouse_Coords proc
	mov bx, CURSOR_Y
	call Print_BX
	mov ah, 2 
	mov dl, ':'
	int 21h
	mov bx, CURSOR_Y
	call Print_BX
	add CURSOR_POSITION, 100h	
	call Set_Cursor_Position_To_Variable
	ret
Print_Mouse_Coords endp

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
