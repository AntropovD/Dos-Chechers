.model tiny
.386
.code
org 100h
start:
    mov ax, 1130h
    mov bh, 2
    int 10h
	mov Table_Offset, bp	
	
	mov si, word ptr Table_Offset
	add si, 01c0h	
	mov di, offset alphabet	
	
	push es
	pop ds

	push cs
	pop es		

	mov cx, 8fh
loop1:
	push cx	
	
	mov cx, 14		
	loop2:
		lodsb	
		cmp cx, 7
		jg part1
		shr al, 1
		jmp part2
	part1:
		shl al, 1
	part2:
		stosb
		loop loop2	
	
	pop cx
	loop loop1

	push cs
	pop es

	mov ax, 1100h
	mov bh, 14
	mov bl, 0
	mov cx, 8fh
	mov dx, 20h
	mov bp, offset alphabet
	int 10h


	ret

Table_Offset dw 0

alphabet dw 400h dup (0)

end start
