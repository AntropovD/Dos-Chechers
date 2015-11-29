	.model tiny
	.386
	.code
	org 100h
start:
;===============================================================
	call Start_Prog
	call Draw_View	
	call Draw_Colour
;===============================================================
	xor ax, ax
__Main_Loop:
	inc ax
	hlt			
	
	mov dx, word ptr Status	
	cmp dx, 2	
	je right_click	
	cmp dx, 1
	je left_click
	cmp dx, 3
	je left_release
	jmp __Loop_Continue	
right_click:
	call Clear_Screen	
	mov Status, 0
	jmp __Loop_Continue	
left_click:
	call Check_Area
	; mov Status, 0
	jmp __Loop_Continue	
left_release:
	call Choose_Colour
	mov Status, 0
	
__Loop_Continue:
	mov ah, 01
	int 16h
	jz __Main_Loop
	mov ah, 0 
	int 16h		
	cmp ah, 01h
	jne __Main_Loop
	call Exit_Prog	
;===============================================================
Start_Prog proc near			
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
Start_Prog endp
;===============================================================
Draw_View proc near			
	mov ax, 0C0fh
	mov cx, 0
	mov dx, 300
	mov bh, 0
	
__Draw_Loop:	
	int 10h
	inc cx
	cmp cx, 640
	jne __Draw_Loop
	
mov ax, 0c00h
mov cx, 0
loop_cx:
	mov dx, 301
loop_dx:	
	int 10h
	inc dx
	cmp dx, 350
	jl loop_dx		
	inc cx	
	call Check_Cx
	jne loop_cx	
	inc ax
	cmp cx, word ptr Strip_Width
	jle loop_cx

	ret
Draw_View endp
;===============================================================
Draw_Colour proc near
	mov ah, 0Ch
	mov al, byte ptr Colour
	mov cx, word ptr Colour_Box_Offset
	loop_cx_1:
		mov dx, 301
	loop_dx_1:	
		int 10h
		inc dx
		cmp dx, 350
		jl loop_dx_1		
		inc cx
		cmp cx, word ptr 639
		jle loop_cx_1		

	ret
Draw_Colour endp
;===============================================================
Check_Cx proc near
	push ax
	mov ax, cx
	div byte ptr Box_Width
	cmp ah, 0
	pop ax
	ret
Check_Cx endp
;===============================================================
Clear_Screen proc near				
	mov ax, 10h
	int 10h			
	call Draw_View	
	mov ax, 1
	int 33h
	call Draw_Colour
	ret
Clear_Screen endp
;===============================================================
Choose_Colour proc near				
	mov ax, 3
	int 33h		
	cmp dx, 301
	jl choose_colour_ret
	cmp cx, Strip_Width
	jg choose_colour_ret
	
	dec cx
	dec dx
	mov ah, 0Dh
	mov bh, 0
	int 10h
	
	mov Colour, al
	call Draw_Colour
choose_colour_ret:
	ret
Choose_Colour endp
;===============================================================
Check_Area proc near	
	mov ax, 3
	int 33h			
	cmp dx, 300
	jge check_area_ret
	cmp cx, 3
	jl check_area_ret
	call Put_5Pixels	
check_area_ret:
	ret	
Check_Area endp
;===============================================================
Put_5Pixels proc near					
	mov ah, 0Ch
	mov al, byte ptr Colour
	mov bh, 0000h		
	dec dx
	int 10h		
	dec cx	
	int 10h
	dec dx
	int 10h
	add dx, 2
	int 10h
	dec cx
	dec dx
	int 10h
	ret
Put_5Pixels endp
;===============================================================
Exit_Prog proc near
	mov ax, 2
	int 33h		
	mov ax, 000Ch
	mov cx, 0000h
	int 33h	
	mov ax, 3
	int 10h			
	int 20h
	ret
Exit_Prog endp
;===============================================================
Mouse_Handler:
	cmp ax, 10000b
	je right_button	
	cmp ax, 100b
	je left_button_release	
	mov word ptr Status, 1
	retf		
right_button:
	mov word ptr Status, 2				
	retf
left_button_release:
	mov word ptr Status, 3
	retf
;==================================================================				
	Colour db 15
	Box_Width db 36
	Strip_Width dw 577
	Colour_Box_Offset dw 610
	Status dw 0
end start
