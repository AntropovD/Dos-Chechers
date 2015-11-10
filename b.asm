	.model tiny
	.code
	.386
	org 100h
start:
	call serial_install

	xor ax, ax
main_loop:
	inc ax
	hlt

	cmp serial_recvCount, 0	
	je Nothing_come
	call serial_getSymbol	

	cmp al, 1ch
	jne not_enter
	mov ah,2 
	mov dl, 0dh
	int 21h
	mov dl, 0ah
	int 21h
	jmp here

not_enter:
	mov ah, 2
	mov dl, al
	int 21h
here:
	
Nothing_come:
	mov ah, 1
	int 16h
	jz main_loop
	mov ah, 0
	int 16h
	cmp ah, 01h
	je exit
	
	jmp main_loop

exit:
	call serial_uninstall	
	ret

	include .\serial.asm
end start
