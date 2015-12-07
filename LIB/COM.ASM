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
	cmp al, 01h
	jne not_01h
	mov sync_exit, 0
	not_01h:

	nothing_comes:
	ret
Check_Com_Port endp

ConnectionLost_Message proc
	mov di, offset BufferString
	mov si, offset connection_lost_msg
	mov cx, 16
	repne movsb

	mov al, ' '
	mov cx, 11
	repne stosb

	call Add_BufferString_To_History
	ret
	
 	connection_lost_msg db 'Connection lost!'	
ConnectionLost_Message endp
;===============================================================
;===============================================================