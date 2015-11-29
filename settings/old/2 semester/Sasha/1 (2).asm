	model tiny
	.code
	org 100h
	.386
	
programm:
	jmp start
ero		db 'Error! Wrong entering of keys.',0dh,0ah,24h
hlp		db 'Help: /h - help, /i - take ints and stay resident,',0dh,0ah,'/u - correct del, /k - forward del',0dh,0ah,24h
take	db 'Interrupts 08h, 10h and 21h are taken!',0dh,0ah,24h
took	db 'Interrupts 08h, 10h and 21h already took!',0dh,0ah,24h
udel	db 'Correctly deleting is complete!',0dh,0ah,24h
uerr	db 'Correctly deleting cant be complete!',0dh,0ah,24h
fdel	db 'Forward deleting is complete!',0dh,0ah,24h
norun	db 'You try to delete nothing!',0dh,0ah,24h

state  	dw 0
count	dw 7
string	db ' /hiuk'

address_08h dd ?
address_10h dd ?
address_21h	dd ?
address_2fh dd ?

state_tbl:
	db 0, 1, 6, 6, 6, 6, 6
	db 6, 6, 2, 3, 4, 5, 6
	db 2, 6, 6, 6, 6, 6, 6
	db 3, 6, 6, 6, 6, 6, 6
	db 4, 6, 6, 6, 6, 6, 6
	db 5, 6, 6, 6, 6, 6, 6
	db 6, 6, 6, 6, 6, 6, 6
	
handler_08h:
	jmp cs:address_08h
handler_10h:
	jmp cs:address_10h
handler_21h:
	jmp cs:address_21h
handler_2Fh:
		cmp ax, 0ff18h
		je next_1
		jmp cs:address_2fh
	next_1:
		cmp cx, 012ffh
		je next_2
		jmp cs:address_2fh
	next_2:
		mov dx, offset handler_2Fh
		push cs
		pop ax
	iret
;	
_e:
	jmp _estart
_h:
	jmp _hstart
_i:
	jmp _istart
_u:
	jmp _ustart
_k:
	jmp _kstart
start:
	mov bp, 80h
	mov cl, 0000h:[bp]
	cmp cl, 0
	je _e
;
	mov bp, 81h
dfa:
	mov si, bp
	lodsb
	mov bp, si
;
	mov dl, cl
	call get_code
	mov cl, dl
;
	mov ax, [state]
	mul [count]
	add ax, bx
	mov bx, ax
;
	mov si, offset state_tbl
	add si, bx
	lodsb
	mov dx, 0
	mov dl, al
	mov [state], dx
;
	cmp [state], 6
	je _e
loop dfa
;
	cmp [state], 2
	je _h
	cmp [state], 3
	je _i
	cmp [state], 4
	je _u
	cmp [state], 5
	je _k
	jmp _e
;
_estart:
	mov ah, 9
	mov dx, offset ero
	int 21h
	jmp exit
;
_hstart:
	mov ah, 9
	mov dx, offset hlp
	int 21h
	jmp exit
;
_istart:
	mov ax, 0ff18h
	mov cx, 012ffh
	mov dx, 0
	int 2fh
;
	cmp dx, offset handler_2Fh
	jne _icontinue
;
	mov ah, 9
	mov dx, offset took
	int 21h
;
	jmp exit
_icontinue:
	mov ah, 35h
	mov al, 2fh
	int 21h
	mov word ptr address_2fh, bx
	mov word ptr address_2fh+2, es
;
	mov ah, 25h
	mov al, 2fh
	mov dx, offset handler_2Fh
	int 21h
;
	mov ah, 35h
	mov al, 08h
	int 21h
	mov word ptr address_08h, bx
	mov word ptr address_08h+2, es
;
	mov ah, 25h
	mov al, 08h
	mov dx, offset handler_08h
	int 21h
;
	mov ah, 35h
	mov al, 10h
	int 21h
	mov word ptr address_10h, bx
	mov word ptr address_10h+2, es
;
	mov ah, 25h
	mov al, 10h
	mov dx, offset handler_10h
	int 21h
;
	mov ah, 35h
	mov al, 21h
	int 21h
	mov word ptr address_21h, bx
	mov word ptr address_21h+2, es
;
	mov ah, 25h
	mov al, 21h
	mov dx, offset handler_21h
	int 21h
;
	mov ah, 9
	mov dx, offset take
	int 21h
;
	mov ah, 31h
	mov dx, 80h
	int 21h
;
_ustart:
	mov ax, 0ff18h
	mov cx, 012ffh
	mov dx, 0
	int 2fh
;
	cmp dx, offset handler_2Fh
	je _ucontinue
;
	mov ah, 9
	mov dx, offset norun
	int 21h
;
	jmp exit
_ucontinue:
;ПИСАТЬ ЗДЕСЬ!
;
	jmp exit
;
_kstart:
	mov ax, 0ff18h
	mov cx, 012ffh
	mov dx, 0
	int 2fh
;
	cmp dx, offset handler_2Fh
	je _kcontinue
;
	mov ah, 9
	mov dx, offset norun
	int 21h
;
	jmp exit
_kcontinue:
	mov dx, ax
	cli
	push dx
	pop es
	mov bx, 0020h
	mov ax, word ptr es:address_08h 
	push 0000h
	pop es
	mov es:[bx], ax
	push dx
	pop es
	mov ax, word ptr es:address_08h+2
	push 0000h
	pop es
	mov es:[bx+2], ax
	sti
;
	cli
	push dx
	pop es
	mov bx, 0040h
	mov ax, word ptr es:address_10h 
	push 0000h
	pop es
	mov es:[bx], ax
	push dx
	pop es
	mov ax, word ptr es:address_10h+2
	push 0000h
	pop es
	mov es:[bx+2], ax
	sti
;
	cli
	push dx
	pop es
	mov bx, 0084h
	mov ax, word ptr es:address_21h 
	push 0000h
	pop es
	mov es:[bx], ax
	push dx
	pop es
	mov ax, word ptr es:address_21h+2
	push 0000h
	pop es
	mov es:[bx+2], ax
	sti
;
	cli
	push dx
	pop es
	mov bx, 00bch
	mov ax, word ptr es:address_2Fh 
	push 0000h
	pop es
	mov es:[bx], ax
	push dx
	pop es
	mov ax, word ptr es:address_2Fh+2
	push 0000h
	pop es
	mov es:[bx+2], ax
	sti
	sti
;
	mov ah, 49h
	push dx
	pop es
	int 21h
;
	mov ah, 9
	mov dx, offset fdel
	int 21h
;
	jmp exit
;
get_code:
	mov bx, 6
	mov cx, 7
	mov di, offset string
	repne scasb
	jcxz exit
	sub bx, cx
	jmp exit
;
exit:
	ret
end programm