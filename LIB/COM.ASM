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
	call Sync_Comes
	not_01h:

	nothing_comes:
	ret
Check_Com_Port endp

Sync_Comes proc
	mov sync_exit, 0
	cmp State, 0
	jne exit_of_here
	mov State, 1
	call Connection_Estabilished
	
	exit_of_here:
	ret
Sync_Comes endp
;===============================================================
Send_Clear_Choose_Buffer proc
	push ax
	mov al, 'B'
	call Serial_AL_To_Buf
	call Serial_Send_All
	pop ax
	ret
Send_Clear_Choose_Buffer endp
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
Send_Clear_Choose_Buffer endp
;===============================================================