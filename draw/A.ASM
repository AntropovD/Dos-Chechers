.model tiny
.386
.code
org 100h
start:	

	call StartProg
		
;===============================================================
__Main_loop:		
	
	xor ax, ax
label1:
	inc ax
	hlt	
	
	
	
	mov dx, run	
	cmp dx, 2	
	je right_click	
	cmp dx, 1
	je left_click
	jmp here
	
	right_click:
		mov ax, 10h
		int 10h		
		mov ax, 1
		int 33h
		jmp here
		
	left_click:
		mov ax, 03
		int 33h		
		mov ax, 0c03h
		mov bh, 0000h		
		sub cx, 2
		sub dx, 2				
		int 10h		
		inc cx 
		inc dx
		int 10h		
		inc cx 
		inc dx
		int 10h
		
here:
	mov ah, 01
	int 16h
	jz __Main_loop				
	cmp ah, 1
	je exit_prog	
	mov ah, 0 
	int 16h	
	
jmp __Main_loop
;===============================================================
ExitProg proc near
	mov ax, 2
	int 33h		
	mov ax, 000Ch
	mov cx, 0000h
	int 33h	
	mov ax, 3
	int 10h			
	int 20h
	ret
ExitProg endp
;===============================================================
StartProg proc near			
	mov ax, 10h
	int 10h	
	mov ax, 0
	int 33h		
	mov ax, 1
	int 33h
	mov ax, 0Ch
	mov cx, 10110b
	mov dx, offset Mouse_Handler
	int 33h	
	ret
StartProg endp
;==================================================================	
;==================================================================	
Mouse_Handler:
	cmp ax, 10000b
	je right_button
	
	cmp ax, 100b
	je left_release
	
	mov word ptr run, 1
	retf	
	
	right_button:
		mov word ptr run, 2				
		retf
	left_release:
		mov word ptr run, 0
		retf
;==================================================================	
write_buffer:
	mov bx, ds:[_tail]
	mov ds:[bx], ax
	add _tail, 2
	cmp _tail, offset _buffer_end
	jle __continue_write_buffer
	mov _tail, offset _buffer	
	__continue_write_buffer:
	ret
;==================================================================		
	Pointer_Segment dw 0
	run dw 0
	
end start
