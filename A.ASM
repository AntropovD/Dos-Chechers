	.model tiny
	.code
	.386
	org 100h
Start:	
	call Init

	Main_Loop:
	cli	
		call Check_History_Buffer
		call Check_Mouse
		call Check_Ticks_Counts
	;	call Check_Com_Port
	not_second_tick:
		call Keyboard_CheckBuffer
	sti
	jmp Main_Loop


Get_Board_Number proc
	mov cx, CURSOR_X
	mov dx, CURSOR_Y
	call Get_Box_From_Coords_In_Ax	
	dec ah
	dec al
	mov bl, ah
	mov ah, 0
	shl ax, 3
	mov bh, 0
	add ax, bx
	ret
Get_Board_Number endp

Check_If_Your_Colour proc
	mov bx, ax
	xor ax, ax
	mov al, bh
	shr ax, 3
	mov ah, 0
	add ax, bx
	mov bp, ax
	xor ax, ax
	lea ax, BOARD[bp]	
	ret	
Check_If_Your_Colour endp
;===============================================================
Init proc 
	call Init_Graphic	
	call Mouse_Init
	call Serial_Install	
	call Interrupts_Install	
	lea bx, Message_Buffer
	mov MsgBuf_Pointer, bx
	ret
Init endp
;===============================================================
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
;===============================================================
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
;===============================================================
Send_Sync_Impulse proc
	push ax
	mov al, 01h
	call Serial_AL_To_Buf
	call Serial_Send_All
	pop ax
	ret
Send_Sync_Impulse endp
;===============================================================
Check_Com_Port proc
	call Serial_Check_Sth_Come	
	je nothing_comes

	call Serial_Get_Symbol_To_AL
	mov ah, 2
	mov dl, al
	int 21h

	nothing_comes:
	ret
Check_Com_Port endp
;===============================================================
Check_Ticks_Counts proc	
	cmp SendSync_flag, 1
	jne not_sendSync
	mov SendSync_flag, 0
	call Send_Sync_Impulse

	not_sendSync:
	cmp ConnectionLost_flag, 1
	jne not_connectionLost
	;call ConnectionLost_Message

	not_connectionLost:
	ret
Check_Ticks_Counts endp
;===============================================================
ConnectionLost_Message proc
	push cs
	pop es
	mov ax, 1301h
	mov bx, 0dh	
	mov cx, 16
	mov dx, 1b02h
	mov bp, offset connectionLost_msg
	int 10h
	;call Set_Cursor_Position_To_Variable
;	call Exit_Procedure
	ret
ConnectionLost_Message endp
;===============================================================
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
;===============================================================
Exit_Procedure proc
	call Serial_Uninstall
	call Interrupts_Uninstall	
	xor ax, ax
	mov al, OLD_VIDEOMODE
	int 10h
	int 20h
	ret
Exit_Procedure endp	
;===============================================================	
	sync_wait_exit db 60
	sync_wait_send db 20

	sync_send db 0
	sync_exit db 0

	vector_08h dd ?
	SendSync_flag db 0	
	ConnectionLost_flag db 0
	Connection_flag db 0

	Your_Colour db 1

	connectionLost_msg db 'Connection Lost!',0
	; 1 - белая пешка 
	; 2 - черная пешка
	; 3 - выбранная белая
	; 4 - выбранная черная
	BOARD 	db 0, 0, 0, 0, 0, 0, 0, 0
		db 2, 2, 2, 2, 2, 2, 2, 2
		db 2, 2, 2, 2, 2, 2, 2, 2
		db 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0
		db 1, 1, 1, 1, 1, 1, 1, 1
		db 1, 1, 1, 1, 1, 1, 1, 1
		db 0, 0, 0, 0, 0, 0, 0, 0

	include .\LIB\GRAPHIC.ASM	
	include .\LIB\KEYBOARD.ASM
	include .\LIB\MOUSE.ASM	
	include .\LIB\SERIAL.ASM
	include .\LIB\GAME.ASM
end Start

