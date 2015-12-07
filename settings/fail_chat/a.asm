	model tiny
	.code
	.386
	org 100h
start:
	;call Init 
		call Serial_Install
	xor ax, ax
	main_loop:
		inc ax 
		hlt		
		call Check_ComPort
		mov al, 01
		call Al_To_BufMsg
		call Keyboard_CheckBuffer
		call Send_Message
		jmp main_loop

Init proc 
	call Serial_Install
	call Init_Graphic
	call Clear_Message_Buffer

	mov data_pointer, offset data_buffer
	mov message_pointer, offset message_buffer	
	mov message_fin, offset message_buffer

	ret
Init endp

Printable_Letter_Proc proc
	call Al_To_BufMsg	
	call Output_BufMsg
	call Serial_AlToBuf
	ret
Printable_Letter_Proc endp

Output_BufMsg proc
	mov ax, 1301h
	mov bx, 0dh	
	mov cx, 76
	mov dx, 1502h
	mov bp, offset message_buffer	
	int 10h
	mov ax, 1301h
	mov bx, 0dh	
	mov cx, 76
	mov dx, 1602h
	mov bp, offset message_buffer	
	add bp, 76
	int 10h

	inc pointer_coords
	mov ah, 2
	mov bh, 0
	mov dx, pointer_coords
	int 10h

	ret
Output_BufMsg endp

AddMessage_To_Buffer proc
	mov si, offset message_buffer
	mov di, data_pointer
	mov count, 0
	loop1:
		lodsb
		stosb
		inc data_pointer
		inc count		
		cmp si, message_fin
		jl loop1
	mov al, 20h
	loop2:
		stosb
		inc data_pointer
		inc count 
		cmp count, 152
		jl loop2
	ret
AddMessage_To_Buffer endp

Keyboard_CheckBuffer proc 
	mov ah, 01
	int 16h
	jz check_buffer_exit
	mov ah, 0
	int 16h
	cmp ah, 01h
	je esc_pressed
	cmp al, 08h	
	je backspace
	cmp ah, 53h
	je delete
	cmp ah, 4bh
	je left
	cmp ah,  4dh	
	je right
	cmp ah, 1ch
	je enter_pressed
	cmp al, 20h
	jge printable_letter
	ret
	printable_letter:
		call Printable_Letter_Proc
		ret
	right:
		call Right_Proc
		ret
	left:
		call Left_Proc
		ret
	backspace:
		call Backspace_proc
		ret
	delete:
		call Delete_proc
		ret
	enter_pressed:
		call Send_Message
		ret
	esc_pressed:
		call Exit_Procedure	
	check_buffer_exit:
		ret
Keyboard_CheckBuffer endp	

Al_To_BufMsg proc 
	mov di, message_pointer
	stosb
	inc message_pointer	
	inc message_fin
	ret
Al_To_BufMsg endp

Right_proc proc
	call Read_Cursor_Position	
	inc dl
	cmp dl, 78
	je next_Line
	inc message_pointer
	inc pointer_coords
	call Set_Cursor_Position
	ret
	next_Line:
		cmp dh, 22
		je last_line
		inc dh
		mov dl, 02	
		inc message_pointer
		inc pointer_coords
		call Set_Cursor_Position
	last_line:
		ret
Right_Proc endp

Left_Proc proc
	call Read_Cursor_Position
	dec dl
	cmp dl, 01
	je prev_line
	dec message_pointer
	dec pointer_coords
	call Set_Cursor_Position
	ret
	prev_line:
		cmp dh, 21
		je first_line
		dec dh
		mov dl, 77
		dec message_pointer
		dec pointer_coords
		call Set_Cursor_Position
	first_line:
		ret
Left_Proc endp

Delete_proc proc 
	
	ret
Delete_proc endp

Backspace_proc proc

	ret
Backspace_proc endp
Init_Graphic proc
	call Clear_Screen	
	call Draw_Frame
	ret
Init_Graphic endp

Exit_Procedure proc
	call Serial_Uninstall
	;call Clear_Screen
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
	include serial.asm
	include lib.asm

	data_buffer db 1368 dup(32)
	data_pointer dw 0

	message_buffer db 152 dup(32)
	message_pointer dw 0
	message_fin dw 0

	pointer_coords dw 0
	count dw 0
	color db 0

	empty_format_border db 78 dup(32)
	format_border db 201, 78 dup (205), 187
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 204, 78 dup (205), 185
		db 186, 78 dup (32), 186
		db 186, 78 dup (32), 186
		db 200, 78 dup (205), 188	
end start