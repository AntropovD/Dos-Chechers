.model tiny
.386
.code
org 100h
;==============================================================
Start:
	mov si, 80h
	lodsb	
	cmp al, 0
	je Input_Error
	dec al
	mov Search_len, al	
	
	call Read_Param
	call Open_File
	
	call Main_Loop
	
	ret
;==============================================================		
Input_Error:
	mov dx, offset InputError_str
	call Write
	call Exit
	ret
;==============================================================		
Read_Param proc near	
		mov cl, search_len
		mov si, 82h
		mov di, offset Search_str	
	Read:
		lodsb	
		stosb	
		loop Read
	ret	
Read_Param endp
;==============================================================
Open_File proc near
		mov ax, 3d00h		
		mov dx, offset Filename
		int 21h	
		jc File_Error
		
		mov File_Handle, ax
		ret
	
	File_Error:	
		mov dx,offset Error_str
		call Write
		call Exit
		ret	
Open_File endp
;==============================================================	
Main_Loop proc near

Main_Loop_Start:
		call Read_Buffer	
		call Buffer_Loop	
	
		mov ax, Pointer_Offset
		add ax, 0ffh				
		mov Pointer_Offset, ax		
		jc Overflow	
		jmp Main_Loop_Start
		
	Overflow:
		mov ax, Pointer_Segment
		inc ax
		mov Pointer_Segment, ax
		jmp Main_Loop_Start	
	
	ret
Main_Loop endp
;==============================================================
Read_Buffer proc near
		
		mov ah, 3fh
		mov bx, File_Handle
		mov cx, 0ffh
		mov dx, offset Buffer
		int 21h			

		mov FLAG, 1
		
		cmp ax, 0ffh
		jne Finish_Loop
		
	
		ret
	
	Finish_Loop:
		call Buffer_Loop
		call Exit		
		ret
		
Read_Buffer endp
;==============================================================
; Move_File_Pointer proc near	
	; mov ax, 4201h
	; mov bx, File_Handle
	; mov cx, 0
	; mov dx, 0ffh
	; int 21h	
	; ret
; Move_File_Pointer endp
;==============================================================
Buffer_Loop proc near
		xor cx, cx
		
	b_loop:
		push cx
		call Search
		pop cx
		cmp eax, 1
		je Success
	back:	
		inc cx
		mov dx, 0ffh
		sub dl, byte ptr Search_len
		cmp cx, dx
		jl b_loop	
	ret
	
	Success:
		push cx			
		mov bx, Pointer_Offset
		add bx, cx
		
		push bx
		call WriteHex
		pop bx	
		
		call WriteString
		pop cx
				
		jmp back	
Buffer_Loop endp
;==============================================================
Search proc near
		push bp 
		mov bp, sp
		
		mov bx, cx
		xor cx,cx
		mov cl, Search_len
		
		mov dx, [bp+4]
		mov si, offset Search_str
		mov di, offset buffer
		add di, dx	
		
		repe cmpsb
		jne mismatch		
	Match:
		mov eax, 1
		pop bp
		mov cx,bx
		ret
	Mismatch:
		mov eax, 0
		pop bp
		mov cx,bx
		ret
Search endp	
;==============================================================	
Write proc near
	mov ah, 9
	int 21h
	ret
Write endp
;==============================================================	
WriteHex proc near	
	push bp
	mov bp, sp
	
	mov dx, Pointer_Segment
	mov al, dh
	call Print_Al	
	mov dx, Pointer_Segment
	mov al, dl
	call Print_Al	
	
	mov ah, 2
	mov dl, ':'
	int 21h
	
	mov dx, [bp+4]
	mov al, dh
	call Print_Al
	mov dx, [bp+4]
	mov al, dl
	call Print_Al		
	
	mov ah, 02h
	mov dl, ' '
	int 21h
		
	pop bp
	ret
WriteHex endp
;==============================================================	
WriteString proc near
	push bp
	mov bp, sp
	
	std	
	lea si, Buffer
	add si, [bp+4]
	
loop1:
	lodsb	
	cmp si, offset Buffer
	je part2
	cmp al, 0ah
	jne loop1
	lodsb 
	cmp al, 0dh	
	jne loop1
	
	cld
	lodsb 
	lodsb
	lodsb
	
part2:	
	; mov dl, byte ptr FLAG
	; cmp dl, 1
	; je Extra_Buffer_Load
 Extra_Buffer_Load_Back:
	cld
	mov ah, 2	
loop2:
	lodsb	
	mov dl, al
	int 21h
	cmp si, offset Buffer_end
	je w_exit	
	cmp al, 0dh
	jne loop2	
	lodsb 
	cmp al, 0ah
	jne loop2
w_exit:	
	pop bp 
	ret

Extra_Buffer_Load:
	mov ax, 4201h
	mov bx, File_Handle
	mov cx, 0
	mov dx, -07fh
	int 21h	
	
	mov ah, 3fh
	mov bx, File_Handle
	mov cx, 07fh
	mov dx, offset Buffer
	int 21h	
	jmp Extra_Buffer_Load_Back




WriteString endp
;==============================================================	
Print_Al proc near
		mov	cl, 4    
		xchg	bx,ax          
	Repeat:
		mov	ax,bx          
		shr	ax,cl          
		and	al,0Fh         
		add	al,'0'         
		cmp	al,'9'         
		jbe	Digit0_9        
		add	al,'A'-('9'+1) 
	Digit0_9:			
		mov ah, 2
		mov dl, al
		int 21h
		sub cl, 4
		jnc	Repeat   
	ret
Print_Al endp	
;==============================================================	
Exit proc near
	mov ax, 4c00h
	int 21h	
	ret
Exit endp

;==============================================================	
	FLAG db 0
	Filename db 'pcidevs0.txt',0h
	File_Handle dw 0
	Pointer_Segment dw 0
	Pointer_Offset dw 0
	Error_str db 'File error', 0dh,0ah,024h
	InputError_str db 'input error', 0dh, 0ah, 024h
	Search_len db 0
	Search_str db 20h dup(0)
	Buffer db 0ffh dup(0)
	Buffer_end db 0
	Buffer_Extra db 07fh dup(0)
	Buffer_Extra_end db 0
	crlf db 0dh,0ah,024h
;==============================================================
end start