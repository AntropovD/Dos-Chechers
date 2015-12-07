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