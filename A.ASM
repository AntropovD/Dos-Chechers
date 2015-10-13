.model tiny
.386
.code
org 100h
;==============================================================
Start:
	call Open_File	
	call Read_Buffer	
	
	mov ax, 10h
	int 10h
		
	mov si, offset Buffer_End
	std
	mov ax, 0CFFh
	mov bh, 0
	mov cx, 4073h	
	
loop_draw:		
	push cx
	
	mov cx, _x
	mov dx, _y
	lodsb	
	mov temp, al
	and al, 00001111b
	int 10h	
	dec cx
	mov al, temp
	shr al, 4
	int 10h
	dec cx
	cmp cx, 0
	je add_dx
add_dx_back:
	mov _x, cx
	mov _y, dx
	
	pop cx
	
	loop loop_draw
	
	call Exit	
	
add_dx:
	inc dx
	mov _y, dx
	mov cx, 220
	jmp add_dx_back

;==============================================================
Open_File proc near
	mov ax, 3d00h		
	mov dx, offset Filename
	int 21h	
	jc File_Error
	
	mov File_Handle, ax
	ret	
File_Error:	
	mov ah, 09h
	mov dx, offset Error_str
	int 21h
	call Exit	
Open_File endp
;==============================================================
Read_Buffer proc near		
		mov ah, 3fh
		mov bx, File_Handle
		mov cx, 4073h
		mov dx, offset Buffer
		int 21h			
		ret		
Read_Buffer endp
;==============================================================	
Exit proc near
	mov ax, 4c00h
	int 21h	
	ret
Exit endp
;==============================================================	
	_x dw 220
	_y dw 0
	temp db 0
	Filename db 'PIC2.PIC',0h
	Error_str db 'File Error',0h
	File_Handle dw 0	
	Buffer db 4073h dup(0)
	Buffer_End db 0
;==============================================================
end start