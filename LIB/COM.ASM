;===============================================================
Send_Sync_Impulse proc
	mov al, 01h
	call Serial_AL_To_Buf
	call Serial_Send_All	
	ret
Send_Sync_Impulse endp
;===============================================================

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