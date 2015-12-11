;===============================================================
Send_Sync_Impulse proc
	mov al, 01h
	call Serial_AL_To_Buf
	call Serial_Send_All	
	ret
Send_Sync_Impulse endp
;===============================================================
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

	ready_msg db 'Противник готов к игре     '	
Check_Com_Port endp
;===============================================================
Sync_Comes proc
	mov sync_exit, 0
	cmp STATE, 0
	jne exit_of_here
	mov STATE, 1
	call Connection_Estabilished	
	exit_of_here:
	ret
Sync_Comes endp
;===============================================================
; dl - '1' - rock '2'-ножницы '3' - бумага
Send_Rock_Scissors proc
	push ax
	mov al, 'C'
	call Serial_AL_To_Buf
	mov al, dl
	call Serial_AL_To_Buf
	call Serial_Send_All
	pop ax
	ret
Send_Rock_Scissors endp
;===============================================================
ConnectionLost_Message proc
	push cs
	pop es
	mov di, offset BufferString
	mov si, offset connection_lost_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History
	ret	
 	connection_lost_msg db 'Соединение разорвано       '	
ConnectionLost_Message endp
;===============================================================
Connection_Estabilished proc	
	mov di, offset BufferString
	mov si, offset connection_set_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	mov di, offset BufferString
	mov si, offset choose_msg
	mov cx, 27
	rep movsb
	call Add_BufferString_To_History

	ret	
 	connection_set_msg db 'Игрок присоединился        '
	choose_msg	   db 'Камень, ножницы, бумага?   '

Connection_Estabilished endp
;===============================================================
;===============================================================
;===============================================================
;===============================================================
;===============================================================
;===============================================================
;===============================================================
;===============================================================
;===============================================================