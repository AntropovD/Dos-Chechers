	.model tiny
	.code
	.386
	org 100h
start:
	
	call Serial_Install
	
	xor ax, ax
	main_loop:
		inc ax
		hlt
		
		
		mov al, 01
		call Serial_AL_To_Buf
		call Serial_Send_All
		
		call Serial_Check_Sth_Come
		je later
		
		call Serial_Get_Symbol_To_Al
		mov ah, 2
		mov dl, al
		int 21h
		
		later:
		mov ah, 01
		int 16h
		jz main_loop
		mov ah, 0
		int 16h
		cmp ah, 01
		je exit_proc
		
		
		jmp main_loop

	ret
	
	exit_proc:
		call Serial_Uninstall
		int 20h
		ret
	
	include .\LIB\SERIAL.ASM
end start 