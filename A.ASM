	.model tiny
	.code
	.386
	org 100h
Start:
	call Init	
	
	Main_Loop:
	cli
		call Check_Mouse
		call Check_Ticks_Counts
		call Check_Com_Port
	not_second_tick:
		call Keyboard_CheckBuffer
	sti
	jmp Main_Loop



Print_Mouse_Coords proc
	mov ax, CURSOR_Y
	mov bl, 48
	div bl
	xor bx, bx
	mov bl, al
	inc bx
	call Print_BX
	mov ah, 2 
	mov dl, ':'
	int 21h

	mov ax, CURSOR_X
	mov bl, 48
	div bl
	xor bx, bx
	mov bl, al
	inc bx
	call Print_BX	
	cmp CURSOR_POSITION, 1700h		
	jl print_coords_exit
	call Clear_Message_Frame

	print_coords_exit:
	add CURSOR_POSITION, 100h
	call Set_Cursor_Position_To_Variable
	ret
Print_Mouse_Coords endp

Init proc 
	call Clear_Screen
	call Draw_Chessboard
	call Draw_Frame
	call Mouse_Init
	call Serial_Install	
	call Interrupts_Install	
	ret
Init endp

Interrupts_Install proc
	cli
		mov ax, 3508h
		int 21h
		mov word ptr vector_08h, bx
		mov word ptr vector_08h+2, es		
		mov ax, 02508h
		mov dx, offset interrupt_08h
		int 21h
	sti
	ret
Interrupts_Install endp

Interrupts_Uninstall proc
	cli
		push ds
		mov dx, word ptr vector_08h
		mov ax, word ptr vector_08h+2
		mov ds, ax
		mov ax, 2508h
		int 21h
		pop ds
	sti
	ret
Interrupts_Uninstall endp

Send_Sync_Impulse proc
	push ax
	mov al, 01h
	call Serial_AlToBuf
	call Serial_Send
	pop ax
	ret
Send_Sync_Impulse endp

Check_Com_Port proc
	cmp serial_recvCount, 0
	je nothing_comes

	call Serial_GetSymbol
	mov ah, 2
	mov dl, al
	int 21h

	nothing_comes:
	ret
Check_Com_Port endp

Check_Ticks_Counts proc	
	cmp SendSync_flag, 1
	jne not_sendSync
	mov SendSync_flag, 0
	call Send_Sync_Impulse

	not_sendSync:
	cmp ConnectionLost_flag, 1
	jne not_connectionLost
	call ConnectionLost_Message

	not_connectionLost:
	ret
Check_Ticks_Counts endp

ConnectionLost_Message proc
	push cs
	pop es
	mov ax, 1301h
	mov bx, 0dh	
	mov cx, 16
	mov dx, 1b02h
	mov bp, offset message_buffer	
	int 10h
	call Set_Cursor_Position_To_Variable
;	call Exit_Procedure
	ret
ConnectionLost_Message endp


interrupt_08h proc
	inc sync_send
	inc sync_exit

	mov al, sync_send
	cmp al, sync_wait_send
	jl not_sync_send
	mov SendSync_flag, 1
	mov sync_send, 0

	not_sync_send:
	mov al, sync_exit
	cmp al, sync_wait_exit
	jl not_sync_exit
	mov ConnectionLost_flag, 1
	mov sync_exit, 0
	not_sync_exit:

	mov al, 20h
	out 20h, al
	iret
interrupt_08h endp

Exit_Procedure proc
	mov ah, 02
	mov bh, 0	
	mov dx, 1b02h
	int 10h
	mov ax, 2
	int 33h		
	call Serial_Uninstall
	call Interrupts_Uninstall
	int 20h
	ret
Exit_Procedure endp
	
	sync_wait_exit db 60
	sync_wait_send db 20

	sync_send db 0
	sync_exit db 0

	vector_08h dd ?
	SendSync_flag db 0	
	ConnectionLost_flag db 0
	Connection_flag db 0

	connectionLost_msg db 'Connection Lost!',0
	message_buffer db 'Connection Lost!',0

	include .\LIB\GRAPHIC.ASM	
	include .\LIB\KEYBOARD.ASM
	include .\LIB\MOUSE.ASM	
	include .\LIB\SERIAL.ASM
end Start

