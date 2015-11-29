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

	mov ah, 1
	int 16h
	jz main_loop
	mov ah, 0
	int 16h
	cmp ah, 01h
	je exit

	cmp ah, 1ch
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
	call serial_alToBuf
	call serial_send
	jmp main_loop

exit:
	call serial_uninstall	
	ret

	include .\serial.asm
end start
