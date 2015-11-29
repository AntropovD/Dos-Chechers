
Keyboard_CheckBuffer proc 
	mov ah, 01
	int 16h
	jz check_buffer_exit
	mov ah, 0
	int 16h
	cmp ah, 01h
	jne check_buffer_exit
	call Exit_Procedure

	check_buffer_exit:
		ret
Keyboard_CheckBuffer endp