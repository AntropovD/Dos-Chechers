.model tiny
.386
.code
org 100h
;==============================================================
Start:			
	call Init	
	call Read_Picture	
	call Main_Loop		
;==============================================================
Init proc near
	mov ax, 12h
	int 10h	
	mov ax, 0
	int 33h
	mov ax,1
	int 33h
	mov ax, 0ch
	mov cx, 10110b
	mov dx, offset Mouse_Handler
	int 33h	
	ret
Init endp
;==============================================================
Main_Loop proc near
	xor ax, ax
	main_loop_label:
		inc ax 
		hlt
		
		cmp State, 15
		je Right_Button_Press
	Right_Button_Press_Back:
		cmp State, 1
		je Left_Button_Press
	Left_Button_Press_Back:

		
		call Check_Keyboard			
		jmp Main_Loop

	Right_Button_Press:
		mov ax, 3
		int 33h
		mov _X, cx
		mov _Y, dx	
		mov ax, 2
		int 33h	
		call Draw_Picture
		mov State, 0
		mov ax, 1
		int 33h
		jmp Right_Button_Press_Back	

	Left_Button_Press:
		mov ax,2
		int 33h
		call Draw_Black
		mov ax, 3
		int 33h
		mov _X, cx
		mov _Y, dx
		call Draw_Picture
		mov ax, 1
		int 33h		
		jmp Left_Button_Press_Back
Main_Loop endp	
;==============================================================
Check_Keyboard proc near
	mov ah, 01
	int 16h
	jz check_keyboard_exit
	mov ah, 0
	int 16h
	cmp ah, 01h
	je Esc_key
	ret	

	Esc_key:	
		call Exit_Prog
	check_keyboard_exit:
		ret
Check_Keyboard endp
;==============================================================
Read_Picture proc near
	call Open_File
	call Read_File
	ret
Read_Picture endp
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
	call Exit_Prog
	ret
Open_File endp
;==============================================================	
Read_File proc near
	mov ax, 4200h
	mov bx, File_Handle
	xor cx, cx
	mov dx, 076h
	int 21h
	
	mov ah, 3fh
	mov bx, File_Handle
	mov cx, 480h
	mov dx, offset Picture
	int 21h
	ret
Read_File endp
;==============================================================	
Mouse_Handler:
	cmp ax, 010b
	je left_but_press
	cmp ax, 0100b
	je left_but_release
	cmp ax, 10000b
	je right_but_release	
	retf	
	right_but_release:
		mov State, 15
		retf
	left_but_press:
		mov State, 1	
		retf	
	left_but_release:
		mov State, 0
		retf
;==============================================================
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
;==============================================================
;al -color	
Change_Color proc near
	push ax dx
	xor ax, 0fh
	shl ax, 8
	inc ax
	mov dx, 3ceh ; регистр разрешения установки сброса
	out dx, ax
	pop dx ax
	ret
Change_Color endp
;==============================================================
; cx - x, dx - y
Print_Pixel proc near
	push ax cx dx

	shl dx, 6
	mov bx, dx
	shr dx, 2
	add bx, dx ; 80*dx
	mov dx, cx
	shr dx, 3 ; cx/8
	add bx, dx
	; в bx смещений до нужного байта

	; установка бита нужного пикселя
	and cl, 7
	mov ch, 7
	sub ch, cl
	xchg cl, ch
	mov ch, 1
	rol ch, cl
	; в ch маска с единицей на позиции изменяемого пикселя

	mov ax, 8
	mov ah, ch
	mov dx, 3ceh ; регистр битовой маски
	out dx, ax

	mov dh, 0ffh
	xchg dh, byte ptr es:[bx]

	pop dx cx ax
	ret
Print_Pixel endp
;==============================================================
Draw_Picture proc near
	mov ax, 0a000h
	mov es, ax
	
	mov cx, word ptr _X
	mov dx, word ptr _Y
	
	call Check_Coords
	cmp ax, 1
	je Finish_Drawing	
		
	mov CoordX, cx
	mov CoordY, dx
	add cx, 24
	mov X_Border, cx
	sub cx, 48
	
	sub dx, 24
	mov Y_Border, dx
	add dx, 48
	
	mov si, offset Picture	
	Paint_Loop:
		lodsb
		mov temp, al
		shr al, 4
		call Check_Colour
		call Change_Color		
		call Print_Pixel
		inc cx
		
		mov al, temp
		and al, 01111b	
		call Check_Colour
		call Change_Color
		call Print_Pixel
		inc cx
		
		cmp cx, X_Border
		je New_Line
	New_Line_back:	
		
		cmp si, offset Picture_End
		jl Paint_Loop
		ret		
	New_Line:
		dec dx
		cmp dx, Y_Border
		je Finish_Drawing
		mov cx, CoordX
		sub cx, 24
		jmp New_Line_back	
			
	Finish_Drawing:
		ret
Draw_Picture endp
;==============================================================
Draw_Black proc near
	mov ax, 0a000h
	mov es, ax
	
	mov cx, word ptr _X
	mov dx, word ptr _Y

	call Check_Coords
	cmp ax, 1
	je Finish_Drawing_2		
	
	sub cx, 24
	add dx, 24

	mov al, 0
	call Change_Color
	mov rows, 48
	mov cols, 48

	some_loop:
		call Print_Pixel
		inc cx		
		dec cols
		cmp cols, 0
		je new_Row
		jmp some_loop

	new_Row:
		dec dx
		dec rows
		cmp rows, 0
		je Finish_Drawing_2
		mov cols, 48
		sub cx, 48
		jmp some_loop


	Finish_Drawing_2:
		ret
Draw_Black endp
;==============================================================
Check_Coords proc near
	cmp cx, 24
	jle Not_Success
	cmp dx, 24
	jle Not_Success
	cmp cx, 616
	jge Not_Success
	cmp dx, 456
	jge Not_Success
	
	mov ax, 0
	ret
	Not_Success:
	mov ax, 1
	ret	
Check_Coords endp
;==============================================================	
Check_Colour proc near
	cmp al, 3
	je change_3
	cmp al, 6
	je change_6
	cmp al, 0bh
	je change_b
	cmp al, 0eh
	je change_e
	cmp al, 1
	je change_1
	cmp al, 4
	je change_4	
	cmp al, 0ch
	je change_c	
	cmp al, 09
	je change_9	
	ret	
	change_9:
		mov al, 0ch
		ret	
	change_c:
		mov al, 9
		ret
	change_1:
		mov al, 4
		ret
	change_4:
		mov al, 1
		ret
	change_3:
		mov al, 6
		ret
	change_6:
		mov al, 3
		ret
	change_b:
		mov al, 0eh
		ret
	change_e:
		mov al, 0bh
		ret	
Check_Colour endp

cols db 0
rows db 0
State db 0
temp db 0
Move_Count dw 10
CoordX dw 0
CoordY dw 0
_X dw 0
_Y dw 0
X_Border dw 0
Y_Border dw 0
File_Handle dw 0
Filename db 'car.bmp', 0
Error_str db 'Picture file Error', 0
Picture db 480h dup(0) 
Picture_End db 0
end start
