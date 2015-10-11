.model tiny
.386
.code
org 100h
start:				

    mov ax, 1100h	
    mov bh, 14	
    mov bl, 0	
    mov cx, 1
	mov dx, 58h
	mov bp, offset cs:char
    mov dx, 58h
    int 10h
	ret
char:
	db 00000000b
    db 01000010b
    db 00100100b
    db 00011000b
    db 00011000b
    db 00100100b
    db 01000010b
    db 01000010b
    db 00100100b
    db 00011000b
    db 00011000b
    db 00100100b
    db 01000010b
    db 00000000b	
end start