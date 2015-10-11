.model tiny
.386
.code
org 100h
start:
	xor bx, bx
	mov si, 080h
	lodsb
	mov cx, ax
	jcxz no_params
	read:
		lodsb
		mov n, cx
		call get_chr_cls
		mov ax, bx
		mov cl, 07h
		mul cl
		mov bx, ax
		mov cx, n
		mov bl, byte ptr state_table[bx][di]
	loop read
	
	cmp bl, 2
	je help_start
	cmp bl, 3
	je install_start
	cmp bl, 4
	je uninstall_start
	cmp bl, 5
	je kill_start	
	jmp error_start

	ret
;==============================================================
	get_chr_cls:
		mov	dx, offset keys_string
		mov	di, dx
		mov	cx, 07h
		repne	scasb
		sub	di, dx
		dec	di
		ret
;==============================================================	
	print:
		mov ah, 09h
		int 21h
		ret
;==============================================================
	no_params:
		mov ah, 09h
		mov dx, offset no_msg
		int 21h
		ret
;==============================================================		
	error_start:
		mov dx, offset error_msg
		call print
		ret
;==============================================================		
	help_start:		
		mov dx, offset help_msg
		call print
		ret
;==============================================================		
	install_start:
		mov ax, 0fecdh
		mov cx, 0fecdh
		mov dx, 0
		int 2fh
	
		cmp dx, offset interrupt_2fh
		je install_exit
		
		mov ax, 03508h
		int 21h
		mov word ptr vector_08h, bx
		mov word ptr vector_08h+2, es		
		mov ax, 02508h
		mov dx, offset interrupt_08h
		int 21h
		
		mov ax, 03510h
		int 21h
		mov word ptr vector_10h, bx
		mov word ptr vector_10h+2, es		
		mov ax, 02510h
		mov dx, offset interrupt_10h
		int 21h
		
		mov ax, 03521h
		int 21h
		mov word ptr vector_21h, bx
		mov word ptr vector_21h+2, es		
		mov ax, 02521h
		mov dx, offset interrupt_21h
		int 21h
		
		mov ax, 0352fh
		int 21h
		mov word ptr vector_2fh, bx
		mov word ptr vector_2fh+2, es		
		mov ax, 0252fh
		mov dx, offset interrupt_2fh
		int 21h
	
		mov ah, 09h
		mov dx, offset install_msg
		int 21h
		
		mov ah, 31h
		mov dx, 60h
		int 21h
		
		install_exit:
			mov ah, 09h
			mov dx, offset install_fail_msg
			int 21h
			ret
;==============================================================		
	uninstall_start:	
		mov ax, 0fecdh
		mov cx, 0fecdh
		mov dx, 0
		int 2fh
	
		cmp dx, offset interrupt_2fh
		jne uninstall_exit
		
		mov var_segment, es
		
		cli
		push 0
		pop es
		
		mov bx, 0020h
		cmp word ptr es:[bx], offset interrupt_08h
		jne uninstall_fail		

		mov bx, 0040h
		cmp word ptr es:[bx], offset interrupt_10h		
		jne uninstall_fail
		
		
		mov bx, 0084h
		push word ptr es:[bx]
		push offset interrupt_21h
		cmp word ptr es:[bx], offset interrupt_21h
		add sp, 4
		;jne uninstall_fail
				
		mov bx, 00BCh		
		push word ptr es:[bx]
		push offset interrupt_21h
		cmp word ptr es:[bx], offset interrupt_2fh
		add sp, 4
		;jne uninstall_fail
		
		mov var_flag_uk, 1
		jmp u_uninstall_part
		sti
		
		
	uninstall_fail:
		mov ah, 09h
		mov dx, offset uninstall_fail_msg
		int 21h
		ret		
;==============================================================		
	kill_start:		
		mov ax, 0fecdh
		mov cx, 0fecdh
		mov dx, 0
		int 2fh
	
		cmp dx, offset interrupt_2fh
		jne uninstall_exit						
		
		mov var_segment, es
	
	u_uninstall_part:
		cli		
			push var_segment
			pop es		
			mov bx, 0020h
			mov ax, word ptr es:[vector_08h]
			push 0
			pop es 
			mov es:[bx], ax
			push var_segment
			pop es
			mov ax, word ptr es:[vector_08h+2]
			push 0
			pop es
			mov es:[bx+2], ax	
		sti			
		
		cli		
			push var_segment
			pop es		
			mov bx, 0040h
			mov ax, word ptr es:[vector_10h]
			push 0
			pop es 
			mov es:[bx], ax
			push var_segment
			pop es
			mov ax, word ptr es:[vector_10h+2]
			push 0
			pop es
			mov es:[bx+2], ax	
		sti	
		
		cli		
			push var_segment
			pop es		
			mov bx, 0084h
			mov ax, word ptr es:[vector_21h]
			push 0
			pop es 
			mov es:[bx], ax
			push var_segment
			pop es
			mov ax, word ptr es:[vector_21h+2]
			push 0
			pop es
			mov es:[bx+2], ax	
		sti	
		
		cli		
			push var_segment
			pop es		
			mov bx, 00BCh
			mov ax, word ptr es:[vector_2fh]
			push 0
			pop es 
			mov es:[bx], ax
			push var_segment
			pop es
			mov ax, word ptr es:[vector_2fh+2]
			push 0
			pop es
			mov es:[bx+2], ax	
		sti	
		
		mov dx, var_segment
		mov ah, 049h
		push dx
		pop es
		int 21h
		
		cmp var_flag_uk, 0
		jne u_uninstall_exit
		mov ah, 09h
		mov dx, offset kill_msg
		int 21h				
		ret		
		
	u_uninstall_exit:
		mov ah, 09h
		mov dx, offset uninstall_msg
		int 21h
		ret
;==============================================================		
	uninstall_exit:
		mov ah, 09h
		mov dx, offset no_interrupts_msg
		int 21h
		ret
;==============================================================	
interrupt_08h:
	jmp cs:vector_08h
interrupt_10h:
	jmp cs:vector_10h
interrupt_21h:
	jmp cs:vector_21h
interrupt_2fh:
	cmp ax, 0fecdh
	je _int2f
	jmp cs:vector_2fh	
	_int2f:
		mov dx, offset interrupt_2fh		
		push cs
		pop es
	iret	
;==============================================================
n dw 0
keys_string 		db '/hiuk '
no_msg 				db 'No keys found', 0Dh, 0Ah, 024h
help_msg 			db 'Help message',0Dh,0Ah,024h,'Use keys /h - help, /i - install /u -uninstall /k - kill', 0Dh, 0Ah, 024h
install_msg 		db 'Installed interrupts 08h, 10h, 21h, 2fh', 0Dh, 0Ah, 024h
install_fail_msg	db 'Interrupts 08h, 10h, 21h, 2fh already installed', 0Dh, 0Ah, 024h
uninstall_msg 		db 'Uninstall finished', 0Dh, 0Ah, 024h
uninstall_fail_msg  db 'Uninstall can not be finished', 0Dh, 0Ah, 024h
kill_msg 			db 'Interrupts killed', 0Dh, 0Ah, 024h
no_interrupts_msg 	db 'Interrupts are not installed', 0Dh, 0Ah, 024h
error_msg 			db 'Error', 0Dh, 0Ah, 024h

var_segment			dw 0
var_flag_uk			dw 0

vector_08h dd ?
vector_10h dd ?
vector_21h dd ?
vector_2fh dd ?

state_table:
	db 1, 6, 6, 6, 6, 0, 6
	db 6, 2, 3, 4, 5, 6, 6
	db 6, 6, 6, 6, 6, 6, 2
	db 6, 6, 6, 6, 6, 6, 3
	db 6, 6, 6, 6, 6, 6, 4
	db 6, 6, 6, 6, 6, 6, 5
	db 6, 6, 6, 6, 6, 6, 6 
;==============================================================
end start