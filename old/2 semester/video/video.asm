.model tiny
.386
.code
org 100h
start:	
	mov si, 082h
	lodsb
	sub al, '0'
	mov _mode, al
	mov si, 084h
	lodsb 
	sub al, '0'
	mov _page, al
	
	cmp _mode, 0
	je _0
	cmp _mode, 1
	je _0
	cmp _mode, 2
	je _2
	cmp _mode, 3
	je _2
	cmp _mode, 7
	je _7
	ret	
	__jump_from_check:	
	
	xor ah, ah
	mov al, _mode
	int 10h	
	mov ah, 05h
	mov al, _page	
	int 10h			
	push _Main_offset
	pop es
			
	xor ax, ax
	mov al, _page
	mov dx, 01000h
	mul dx	
	mov page_start, ax		
	add ax, 20ah
	mov _offset, ax
	
	mov di, ax	
	mov bx, di		
	mov word ptr es:[di], 1eC9h
	mov word ptr es:[di+0be0h], 1eC8h	
	mov word ptr es:[di+72], 1EBBh
	mov word ptr es:[di+72+0be0h], 1EBCh		
	mov word ptr es:[di+0a0h+2], 1e00h	
	mov cx, 18
	__side_line:
		add bx, 0a0h
		mov word ptr es:[bx], 1ebah
		mov word ptr es:[bx+72], 1ebah		
		mov word ptr es:[bx+4], 1eb3h
		loop __side_line		
	mov cx, 35
	__first_line:	
		mov word ptr es:[di+2], 1eCDh
		mov word ptr es:[di+2+0be0h], 1eCDh
		mov word ptr es:[di+2+0a0h+0a0h], 1ec4h
		add di, 2	
		loop __first_line				
	mov di, _offset
	mov word ptr es:[di+4], 1ed1h
	mov word ptr es:[di+4+0be0h], 1ecfh
	mov word ptr es:[di+4+0a0h+0a0h], 01ec5h		
	mov word ptr es:[di+0a0h+0a0h], 01ec7h
	mov word ptr es:[di+0a0h+0a0h+72], 01eb6h
	mov dx, 1e30h
	mov cx, 10
	mov bx, di
	add bx, 1e2h
	__numbers_line:		
		mov word ptr es:[di+0a0h+6], 1e00h
		mov word ptr es:[di+0a0h+8], dx
		mov word ptr es:[bx], dx
		add bx, 0a0h
		inc dx
		add di, 4
		loop __numbers_line
	mov dx, 1e41h
	mov cx, 6
	__numbers_line_2:		
		mov word ptr es:[di+0a0h+6], 1e00h
		mov word ptr es:[di+0a0h+8], dx
		mov word ptr es:[bx], dx
		add bx, 0a0h
		inc dx
		add di, 4
		loop __numbers_line_2
	mov word ptr es:[di+0a0h+6], 1e00h	
	mov ax, word ptr page_start
	add ax, 03F0h
	mov di, ax	
	mov dx, 1e00h
	mov cx, 256
	xor bx, bx
	main_loop_2:	
		mov word ptr es:[di], 1e00h
		mov es:[di+2], dx		
		inc dx
		inc bx
		cmp bx, 16
		je bx_counter_2
		bx_counter_back_2:
		add di, 4
	loop main_loop_2	
	ret		
	bx_counter_2:
		xor bx, bx
		mov word ptr es:[di+4], 1e00h
		add di, 4*24		
	jmp bx_counter_back_2	
	ret
_0:
	cmp _page, 0
	jl _error
	cmp _page, 7
	jg _error		
	
	xor ah, ah
	mov al, _mode
	int 10h	
	mov ah, 05h
	mov al, _page	
	int 10h			
	push 0b800h
	pop es			
	xor ax, ax
	mov al, _page
	mov dx, 0800h
	mul dx	
	mov page_start, ax		
	add ax, 0f4h
	mov _offset, ax
	
	mov di, ax	
	mov bx, di		
	mov word ptr es:[di], 1eC9h
	mov word ptr es:[di+05f0h], 1eC8h	
	mov word ptr es:[di+72], 1EBBh
	mov word ptr es:[di+72+5f0h], 1EBCh		
	mov word ptr es:[di+050h+2], 1e00h	
	mov cx, 18
	__side_line_0:
		add bx, 050h
		mov word ptr es:[bx], 1ebah
		mov word ptr es:[bx+72], 1ebah		
		mov word ptr es:[bx+4], 1eb3h
		loop __side_line_0		
	mov cx, 35
	__first_line_0:	
		mov word ptr es:[di+2], 1eCDh
		mov word ptr es:[di+2+05f0h], 1eCDh
		mov word ptr es:[di+2+050h+050h], 1ec4h
		add di, 2	
		loop __first_line_0
	mov di, _offset
	mov word ptr es:[di+4], 1ed1h
	mov word ptr es:[di+4+05f0h], 1ecfh
	mov word ptr es:[di+4+050h+050h], 01ec5h			
	mov word ptr es:[di+050h+050h], 01ec7h
	mov word ptr es:[di+050h+050h+72], 01eb6h		
	mov dx, 1e30h
	mov cx, 10
	mov bx, di
	add bx, 0f2h
	__numbers_line_0:		
		mov word ptr es:[di+050h+6], 1e00h
		mov word ptr es:[di+050h+8], dx
		mov word ptr es:[bx], dx
		add bx, 050h
		inc dx
		add di, 4
		loop __numbers_line_0
	mov dx, 1e41h
	mov cx, 6
	__numbers_line_2_0:		
		mov word ptr es:[di+050h+6], 1e00h
		mov word ptr es:[di+050h+8], dx
		mov word ptr es:[bx], dx
		add bx, 050h
		inc dx
		add di, 4
		loop __numbers_line_2_0
	mov word ptr es:[di+050h+6], 1e00h	
	mov ax, word ptr page_start
	add ax, 01eah
	mov di, ax	
	mov dx, 1e00h
	mov cx, 256
	xor bx, bx
	main_loop_2_0:	
		mov word ptr es:[di], 1e00h
		mov es:[di+2], dx		
		inc dx
		inc bx
		cmp bx, 16
		je bx_counter_2_0
		bx_counter_back_2_0:
		add di, 4
	loop main_loop_2_0
	ret		
	bx_counter_2_0:
		xor bx, bx
		mov word ptr es:[di+4], 1e00h
		add di, 16
	jmp bx_counter_back_2_0	
	ret
_2:
	cmp _page, 0
	jl _error
	cmp _page, 3
	jg _error
	mov _Main_offset, 0b800h	
	jmp __jump_from_check
_7:
	cmp _page, 0
	jl _error
	cmp _page, 7
	jg _error
	mov _Main_offset, 0b000h
	jmp __jump_from_check
_error:
	ret
	
;==============================================================
_mode db ?
_page db ?
_offset dw ?
page_start dw ?
_Main_offset dw ?
end start