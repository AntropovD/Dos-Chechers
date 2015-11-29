Init_Graphic proc
	call Clear_Screen	
	call Draw_Frame
	ret
Init_Graphic endp

Exit_Procedure proc
	call Serial_Uninstall
	call Clear_Screen
	int 20h
	ret
Exit_Procedure endp

Send_Message proc 	
	cmp serial_bufCount, 0
	je check_buffer_exit
	call Serial_Send
	call AddMessage_To_Buffer
	mov color, 0bh		
	call Update_Window
	call Clear_Message_Buffer	
	ret
Send_Message endp

Clear_Message_Buffer proc
	mov ax, 1301h
	mov bx, 000eh
	mov cx, 78	
	mov dx, 1501h
	mov bp, offset empty_format_border
	int 10h
	mov ax, 1301h
	mov bp, offset empty_format_border
	mov dx, 1601h
	int 10h
	mov message_pointer, offset message_buffer
	mov message_fin, offset message_buffer
	mov pointer_coords, 1502h
	mov ah, 2
	mov bh, 0
	mov dx, pointer_coords
	int 10h
	ret
Clear_Message_Buffer endp

Output_Al_Symbol proc	
	mov ah, 2
	mov dl, al
	int 21h
	ret
Output_Al_Symbol endp

Read_Cursor_Position proc
	mov ah, 03h
	xor bx, bx
	int 10h
Read_Cursor_Position endp

Set_Cursor_Position proc
	mov ah, 02h
	int 10h
	ret
Set_Cursor_Position endp

Clear_Screen proc
	mov ax, 3
	int 10h
	ret
Clear_Screen endp

Draw_Frame proc
	mov ax, 1301h
	mov bx, 009h
	mov cx, 1920	
	xor dx, dx
	mov bp, offset format_border
	int 10h
	ret
Draw_Frame endp

Update_Window proc
	call Draw_Frame
	mov count, 1

	loop3:
		mov ax, 1301h
		mov bh, 0
		mov bl, color		
		mov dx, 002h
		mov bp, offset data_buffer
		sub bp, 76
		mov cx, count
		loop4:
			add dx, 100h
			add bp, 76
			loop loop4
		mov cx, 76
		int 10h

		inc count
		cmp count, 19
		jl loop3	
	ret
Update_Window endp

Check_ComPort proc
	cmp serial_recvCount, 0
	je nothing_comes	
	mov cx, serial_recvCount
	print_symbol:
		call Serial_GetSymbol
		mov ah, 2
		mov dl, al
		int 21h
		loop print_symbol	
	nothing_comes:
	ret
Check_ComPort endp