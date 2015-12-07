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
		call Check_Com_Port
		call Keyboard_CheckBuffer
	sti
	jmp Main_Loop

Enter_Pressed proc
	CLI
	mov cx, 6
	mov si, offset update_cmd
	mov di, offset Message_Buffer
	repe cmpsb
	jne not_update_cmd
	call Update_Everything
	jmp clear_buf_and_exit

	not_update_cmd:
		call Check_If_Command_Move
		cmp ax, 1
		je entered_move_command

	entered_move_back_1:
		pop dx cx
	entered_move_back:
		call Copy_Msg_To_Hist		
	clear_buf_and_exit:		
		mov di, offset Message_Buffer
		mov cx, 54	
		clear_loop:
			mov byte ptr [di], ' '
			inc di
			dec cx
			cmp cx, 0
			jne clear_loop
		call Update_Msg_Buf
		mov MsgBuf_Pointer, offset Message_Buffer	
		STI
		ret

	entered_move_command:
		mov di, MsgBuf_Pointer
		mov byte ptr [di], 'C'
		inc di
		mov byte ptr [di], 'm'
		inc di
		mov byte ptr [di], 'd'
		add MsgBuf_Pointer, 3

		mov di, offset Message_Buffer
		mov ch, byte ptr[di]
		mov cl, byte ptr[di+1]
		mov dh, byte ptr[di+2]
		mov dl, byte ptr[di+3]
		sub ch, '0'
		sub cl, '0'
		sub dh, '0'
		sub dl, '0'

		call Can_Enemy_Do_Move_Command_Cx_Dx
		cmp ax, 1
		je can_move_command

		mov ax, cx
		;твой цвет?
		call Get_Board_Value_By_AX_to_AL
		cmp al, 2
		jne enemy_cant_pawn

		call Can_Enemy_Do_Pawn_Command_Cx_dx
		cmp ax, 1
		jne not_can_command

		push cx dx

		mov di, offset Message_Buffer
		mov si, MsgBuf_Pointer
		sub si, 3
		add di, 4
		cmp si, di
		je can_pawn_command
		all_moves_loop:				
			mov cx, dx
			mov dh, byte ptr[di]
			mov dl, byte ptr[di+1]
			sub dx, 3030h
				call Can_Enemy_Do_Pawn_Command_Cx_dx
				cmp ax, 1
				jne not_can_command_1
			add di, 2
			cmp di, si
			jne all_moves_loop
		pop dx cx

		can_pawn_command:
			mov di, MsgBuf_Pointer
			mov byte ptr [di], '!'
			inc MsgBuf_Pointer
			call Execute_Enemy_Pawn_Command

			mov di, offset Message_Buffer
			mov si, MsgBuf_Pointer
			sub si, 4
			add di, 4
			cmp si, di
			je entered_move_back_1
			all_cuts_loop:				
				mov cx, dx
				mov dh, byte ptr[di]
				mov dl, byte ptr[di+1]
				sub dx, 3030h
				push si
				call Execute_Enemy_Pawn_Command
				pop si
				add di, 2
				cmp di, si
				jne all_cuts_loop
			
			jmp entered_move_back

		not_can_command_1:
			pop dx cx	
		not_can_command:
			mov di, MsgBuf_Pointer
			mov byte ptr [di], '-'
			inc MsgBuf_Pointer
			jmp entered_move_back

		can_move_command:
			mov di, MsgBuf_Pointer
			mov byte ptr [di], '+'
			inc MsgBuf_Pointer
			call Execute_Enemy_Command_Cx_Dx
			jmp entered_move_back		

	Command_msg db 'Cmd'
	update_cmd db 'update'
Enter_Pressed endp
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
Check_Ticks_Counts proc	
	cmp SendSync_flag, 1
	jne not_sendSync
	mov SendSync_flag, 0
	call Send_Sync_Impulse

	not_sendSync:
	cmp ConnectionLost_flag, 1
	jne not_connectionLost
	mov ConnectionLost_flag, 0
	call ConnectionLost_Message

	not_connectionLost:
	ret
Check_Ticks_Counts endp
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


	YOUR_COLOUR db 2 ;; White -1 Black - 2

	connectionLost_msg db 'Connection Lost!',0
	; 1 - белая пешка 
	; 2 - черная пешка
	BOARD 	db 0, 0, 0, 0, 0, 0, 0, 0
		db 2, 2, 2, 2, 2, 2, 2, 2
		db 2, 2, 2, 2, 2, 2, 2, 2
		db 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0
		db 1, 1, 1, 1, 1, 1, 1, 1
		db 1, 1, 1, 1, 1, 1, 1, 1
		db 0, 0, 0, 0, 0, 0, 0, 0

	INITIALIZE_BOARD db 0, 0, 0, 0, 0, 0, 0, 0
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
	include .\LIB\COM.ASM
end Start