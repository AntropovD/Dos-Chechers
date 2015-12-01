;==============================================================
Keyboard_CheckBuffer proc 
	mov ah, 01
	int 16h
	jz check_buffer_exit
	mov ah, 0
	int 16h
	cmp ah, 01h
	je esc_pressed	

	check_buffer_exit:
		ret

	esc_pressed:
		call Exit_Procedure
		ret
Keyboard_CheckBuffer endp
;==============================================================