	.model tiny
	.code
	.386
	org 100h
Start:	
	call Init

	Main_Loop:		
		hlt
		call Check_Mouse
		call Check_Com_Port
		call Keyboard_CheckBuffer	
		call Check_History_Buffer		
	jmp Main_Loop		
	
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
			mov TURN, 2			
			mov LAST_CHOSEN_BOX, 0ffffh
			ret

		Possible_Cut_Pawn:
			call Try_Cut_Pawn	
			call Check_Another_Possible_Cut		
			cmp ax, 1
			je can_another_cut
			
			push dx
			cant_another_cut:
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
				mov TURN, 2
				ret
			can_another_cut:				
				mov ax, dx				
				mov LAST_CHOSEN_BOX, dx
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
		jne check_mouse_exit
		call Highlight_Box
		call Get_Box_From_Coords
		mov LAST_CHOSEN_BOX, ax			
	check_mouse_exit:
	ret
	
	cut_buffer db 40 dup (0)
	cb_pointer dw 0	
Check_Mouse endp

;==============================================================
Init proc 
	call Serial_Install
	call Init_Graphic	
	call Mouse_Init		
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
interrupt_08h proc	
	push cx dx
	inc sync_send
	inc sync_exit
	
	push cs
	pop es
	cmp sync_send, 20
	jl not_sync_send
	call Send_Sync_Impulse	
	mov sync_send, 0
	
	not_sync_send:	
	cmp sync_exit, 60
	jl not_sync_exit
	cmp State, 0
		je not_connectionLost
		mov State, 0
		call ConnectionLost_Message	

	not_connectionLost:
	not_sync_exit:
	pop dx cx
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
	sync_send db 0
	sync_exit db 0

	vector_08h dd 0

	SendSync_flag db 0	
	ConnectionLost_flag db 0
	Update_History_Buffer_Flag db 0	

	; STATE db 4
	; YOUR_COLOR db 2; 1 - white 2 - black
	; TURN db 1 ; 1- да, 2 - нет
	STATE db 0
	YOUR_COLOR db 0; 1 - white 2 - black
	TURN db 0; 1- да, 2 - нет

	MY_CHOISE db 0ffh
	OPPONENT_CHOISE db 0ffh
	; 1 - твоя пешка
	; 2 - пешка врага
	; 3 - твоя дамка
	; 4 - дамка врага
	BOARD 	db 0, 0, 0, 0, 0, 0, 0, 0
		db 2, 2, 2, 2, 2, 2, 2, 2
		db 2, 2, 2, 2, 2, 2, 2, 2
		db 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0
		db 1, 1, 1, 1, 1, 1, 1, 1
		db 1, 1, 1, 1, 1, 1, 1, 1
		db 0, 0, 0, 0, 0, 0, 0, 0

	; INITIALIZE_BOARD db 0, 0, 0, 0, 0, 0, 0, 0
		; db 2, 2, 2, 2, 2, 2, 2, 2
		; db 2, 2, 2, 2, 2, 2, 2, 2
		; db 0, 0, 0, 0, 0, 0, 0, 0
		; db 0, 0, 0, 0, 0, 0, 0, 0
		; db 1, 1, 1, 1, 1, 1, 1, 1
		; db 1, 1, 1, 1, 1, 1, 1, 1
		; db 0, 0, 0, 0, 0, 0, 0, 0

	include .\LIB\GRAPHIC.ASM	
	include .\LIB\KEYBOARD.ASM
	include .\LIB\MOUSE.ASM	
	include .\LIB\SERIAL.ASM
	include .\LIB\GAME.ASM
	include .\LIB\COM.ASM
end Start