.model tiny
.386
.code
org 100h
start:		
	mov ax, 4
	int 10h	
	
	mov ax, 0
	int 33h	
	mov ax, 1
	int 33h	
	mov ax, 0Ch
	mov cx, 10010b
	mov dx, offset Mouse_Handler
	int 33h
	
;==================================================================
__Main_loop:
	
	xor ax, ax
label1:
	inc ax
	hlt	
	
	mov dx, run
	cmp dx, 1	
	jz exit_prog
	
	mov ah, 01
	int 16h
	jz __Main_loop				
	cmp ah, 1
	je exit_prog	
	mov ah, 0 
	int 16h
	
	
		
jmp __Main_loop
;==================================================================	

exit_prog:
	mov ax, 2
	int 33h		
	mov ax, 000Ch
	mov cx, 0000h
	int 33h
	mov ax, 3
	int 10h
			
	int 20h

;==================================================================		
Mouse_Handler:
	cmp ax, 2
	jne right_button
	 
	mov Pointer_Segment, cx
	push dx
	call WriteHex
	pop dx
	
	
	mov bh, 0
	mov dx, 0
	int 10h
	
	retf
	
	
	right_button:
		mov word ptr run, 1				
		retf
;==================================================================	
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
;==================================================================	
;==================================================================	
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
;==================================================================	
	Pointer_Segment dw 0
	run dw 0

end start
