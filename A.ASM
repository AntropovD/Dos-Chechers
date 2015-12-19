	.model tiny
	.code
	.386
	org 100h
Start:	
	call Init

	Main_Loop:		
		hlt		
		call Check_Com_Port
		call Check_Mouse
		call Keyboard_CheckBuffer	
		call Check_History_Buffer		
	jmp Main_Loop

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
	call Check_Com_Port
	mov sync_send, 0
	
	not_sync_send:	
	cmp sync_exit, 60
	jl not_sync_exit
	; cmp State, 0
		; je not_connectionLost
		; mov State, 0
		; mov TURN, 0
		; mov YOUR_COLOR, 0	
		; mov MY_CHOISE, 0ffh
		; mov OPPONENT_CHOISE, 0ffh		
		; call ConnectionLost_Message	
		; call RESET_BOARD

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
	YOUR_COLOR db 2; 1 - white 2 - black
	TURN db 1 ; 1- да, 2 - нет
	; STATE db 0
	; YOUR_COLOR db 0; 1 - white 2 - black
	; TURN db 0; 1- да, 2 - нет

	MY_CHOISE db 0ffh
	OPPONENT_CHOISE db 0ffh
	
	Enemy_agree_new db 0
	you_agree_new db 0
	; 1 - твоя пешка
	; 2 - пешка врага
	; 3 - твоя дамка
	; 4 - дамка врага
	BOARD 	db 0, 0, 0, 0, 0, 0, 0, 0
		db 2, 2, 0, 2, 2, 2, 2, 2
		db 2, 2, 0, 0, 2, 2, 2, 2
		db 0, 0, 0, 2, 0, 0, 0, 0
		db 0, 0, 0, 1, 0, 0, 0, 0
		db 1, 1, 1, 1, 1, 1, 1, 1
		db 1, 1, 1, 1, 1, 1, 1, 1
		db 0, 0, 0, 0, 0, 0, 0, 0
	
	CONST_BOARD db 0, 0, 0, 0, 0, 0, 0, 0
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