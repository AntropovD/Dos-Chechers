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

Check_Com_Port proc
	call Serial_Check_Sth_Come	
	je nothing_comes


	call Serial_Get_Symbol_To_AL

	____01h:
		cmp al, 01h
		jne not_01h
		call Sync_Comes
		jmp nothing_comes

	not_01h:
		cmp al, 'B'
		jne not_B
		cmp STATE, 1
		jne not_B
		mov STATE, 2
		mov Opponent_Choise, 0ffh
		jmp nothing_comes

	not_B:
		cmp al, 'C'
		jne not_C
		cmp STATE, 2
		jne not_C
		mov STATE, 3		
		jmp nothing_comes

	not_C:
		cmp al, 'D'
		jne not_D
		mov di, offset BufferString
		mov si, offset ready_msg
		mov cx, 27
		rep movsb
		call Add_BufferString_To_History
		mov STATE, 4

	not_D:
		cmp al, 'S'
		jne not_S		
		lea di, command_buffer
		mov bx, 40
		s_loop:
			call Serial_Get_Str_To_DI	
			cmp cx, 0
			je s_loop
		
	not_S:
		cmp al, 'F'
		jne not_F

	not_F:
		cmp al, 'G'
		jne not_G

	not_G:
		cmp al, 'M'
		jne not_M

	not_M:
		cmp al, 'U'
		jne not_U

	not_U:
		cmp al, 'Y'
		jne not_Y

	not_Y:
		cmp al, 'N'
		jne not_N

	not_N:
		cmp al, 'R'
		jne not_R

	not_R:
		cmp al, 'W'
		jne not_W

	not_W:
		cmp al, 'H'
		jne not_H
	not_H:
		cmp al, '1'
		jne not_1
		cmp State, 3		
		jne not_1
		mov Opponent_Choise, '1'
		call Check_Opponent_Choise
		ret

	not_1:
		cmp al, '2'
		jne not_2
		cmp State, 3 
		jne not_2
		mov Opponent_Choise, '2'
		call Check_Opponent_Choise
		ret
		

	not_2:
		cmp al, '3'
		jne not_3
		cmp State, 3 
		jne not_3
		mov Opponent_Choise, '3'
		call Check_Opponent_Choise
		ret

	not_3:

	nothing_comes:
	ret
	command_buffer db 40 dup(0)
	cmbuffer_point dw 0
	ready_msg db 'Противник готов к игре     '	
Check_Com_Port endp
;===============================================================
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

	STATE db 4
	YOUR_COLOR db 1; 1 - white 2 - black
	TURN db 1 ; 1- да, 2 - нет

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