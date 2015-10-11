.model tiny
.386
.code
org 100h
start:
	mov ax, 03509h
	int 21h
	mov word ptr vector_09h, bx
	mov word ptr vector_09h+2, es		
	mov ax, 02509h
	mov dx, offset interrupt_09h
	int 21h
		
	mov _head, offset _buffer
	mov _tail, offset _buffer
		
__Main_loop:
	mov ax, _head
	mov bx, _tail
	cmp ax, bx
	je __Main_loop	
	
	mov bx, _head
	mov ax, ds:[bx]
	
	cmp al, 01
	je exit
	
	cmp al, 39h
	je show_string
	
	string_back:
	
	call print_register_al
	add _head, 2	
	
	cmp _head, offset _buffer_end
	jle continue_main_loop
	mov _head, offset _buffer
	
	continue_main_loop:
	jmp __Main_loop	

exit:
	cli		
			push ds
			pop es		
			mov bx, 0024h
			mov ax, word ptr es:[vector_09h]
			push 0
			pop es 
			mov es:[bx], ax
			push ds
			pop es
			mov ax, word ptr es:[vector_09h+2]
			push 0
			pop es
			mov es:[bx+2], ax	
	sti	
	int 20h
	ret	

	
	nop
show_string:
	mov ah,9
	mov dx, offset msg
	int 21h
	jmp string_back
		
write_buffer:
	mov bx, ds:[_tail]
	mov ds:[bx], ax
	add _tail, 2
	cmp _tail, offset _buffer_end
	jle __continue_write_buffer
	mov _tail, offset _buffer	
	__continue_write_buffer:
	ret
	
interrupt_09h:
	 push      ax
     push      di
     push      es
     in        al,60h
	 
	 call write_buffer
	 
     pop       es
     pop       di
     in        al,61h    
     mov       ah,al
     or        al,80h    
     out       61h,al
     xchg      ah,al     
     out       61h,al	 
	 nop
	 nop	 
     mov       al,20h    
     out       20h,al    
     pop       ax
     iret
	
print_register_al:
		mov	cl, 4    
		xchg	dx,ax          
	Repeat:
		mov	ax,dx          
		shr	ax,cl          
		and	al,0Fh         
		add	al,'0'         
		cmp	al,'9'         
		jbe	Digit09        
		add	al,'A'-('9'+1) 
	Digit09:	
		mov ah, 2
		int	21h    
		sub	cl,4           
		jnc	Repeat   
		mov ah, 09h
		mov dx,offset new_line
		int 21h
	ret

new_line db 'h',0dh,0ah,024h
vector_09h dd ?
_head dw 0
_tail dw 0
_buffer dw 6 dup (0)
_buffer_end dw 0
msg db '=============================', 0dh, 0ah, 024h

end start