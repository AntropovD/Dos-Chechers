Clear_Screen proc 
	mov ax, 12h
	int 10h
Clear_Screen endp

Change_Colour proc 
	push ax dx
	xor ax, 0fh
	shl ax, 8
	inc ax
	mov dx, 3ceh ; регистр разрешени¤ установки сброса
	out dx, ax
	pop dx ax
	ret
Change_Colour endp

Print_Pixel proc
	push ax cx dx
	mov ax, 0a000h
	mov es, ax

	shl dx, 6
	mov bx, dx
	shr dx, 2
	add bx, dx ; 80*dx
	mov dx, cx
	shr dx, 3 ; cx/8
	add bx, dx
	; в bx смещений до нужного байта

	; установка бита нужного пиксел¤
	and cl, 7
	mov ch, 7
	sub ch, cl
	xchg cl, ch
	mov ch, 1
	rol ch, cl
	; в ch маска с единицей на позиции измен¤емого пиксел¤

	mov ax, 8
	mov ah, ch
	mov dx, 3ceh ; регистр битовой маски
	out dx, ax

	mov dh, 0ffh
	xchg dh, byte ptr es:[bx]

	pop dx cx ax
	ret
Print_Pixel endp

Draw_Chessboard proc 
	mov cx, CHESSBOARD_X
	mov dx, CHESSBOARD_Y

	push X
	push Y
	mov al, CHESSBOARD_BLACK
	mov LAST_COLOUR, al

	mov X, 0
	mov Y, 0
	draw_chessboard_loop:
		call Draw_NextColourBox
		add cx, 48
		call Draw_NextColourBox
		add cx, 48
		inc Y
		cmp Y, 4
		je draw_checssboard_new_line
		jmp draw_chessboard_loop

	draw_checssboard_new_line:		
		call Change_Last_Colour
		mov cx, CHESSBOARD_X
		mov Y, 0
		add dx, 48
		inc X
		cmp X, 8
		je draw_chessboard_exit
		jmp draw_chessboard_loop

	draw_chessboard_exit:
		call Init_Pawn_Buffer
		call Reset_Pawns

		pop Y
		pop X
		ret
Draw_Chessboard endp

Draw_WhiteBox proc 
	mov al, CHESSBOARD_WHITE	
	mov LAST_COLOUR, al
	call Change_Colour
	call Draw_Box
	ret
Draw_WhiteBox endp

Draw_BlackBox proc 
	mov al, CHESSBOARD_BLACK	
	mov LAST_COLOUR, al
	call Change_Colour
	call Draw_Box
	ret
Draw_BlackBox endp

Draw_NextColourBox proc 
	cmp LAST_COLOUR , CHESSBOARD_BLACK
	je Was_Black
		call Draw_BlackBox
		ret

	Was_Black:
		call Draw_WhiteBox
		ret
Draw_NextColourBox endp

Draw_Box proc 
	push X
	push Y
	mov X, 0
	mov Y, 0	

	draw_box_loop:
		call Print_Pixel
		inc cx
		inc Y
		cmp Y, 48
		je draw_box_new_line
		jmp draw_box_loop
	draw_box_new_line:
		mov Y, 0
		sub cx, 48
		inc dx
		inc X
		cmp X, 48
		je draw_box_exit
		jmp draw_box_loop

	draw_box_exit:
		sub dx, 48
		pop Y 
		pop X
		ret
Draw_Box endp

Change_Last_Colour proc
	cmp LAST_COLOUR, CHESSBOARD_BLACK
	jne last_color_black	
		mov LAST_COLOUR, CHESSBOARD_WHITE
		ret
	last_color_black:
		mov LAST_COLOUR, CHESSBOARD_BLACK
		ret
Change_Last_Colour endp

Init_Pawn_Buffer proc near
	mov ax, 3d00h
	mov dx, offset Pawn_Filename
	int 21h	

	mov bx, ax
	mov ax, 4200h
	xor cx, cx
	mov dx, 076h
	int 21h

	mov ah, 3fh
	mov cx, 480h
	mov dx, offset Pawn_Buffer
	int 21h
	ret
Init_Pawn_Buffer endp

Draw_WhitePawn proc 
	mov al, PAWN_WHITE
	call Change_Colour
	call Draw_Pawn
	ret	
Draw_WhitePawn endp

Draw_BlackPawn proc
	mov al, PAWN_BLACK
	call Change_Colour
	call Draw_Pawn
	ret
Draw_BlackPawn endp

Draw_Pawn proc
	push X
	push Y

	mov X, 0
	mov Y, 0

	mov si, offset Pawn_Buffer

	draw_pawn_loop:
		lodsb
		mov temp, al
		shr al, 4
		call Print_Pixel_NZ
		inc cx
		mov al, temp
		and al, 01111b
		call Print_Pixel_NZ
		inc cx
		inc Y
		cmp Y, 24
		je draw_pawn_new_line
		jmp draw_pawn_loop

	draw_pawn_new_line:
		sub cx, 48
		inc dx
		inc X
		mov Y, 0
		cmp X, 48
		je draw_pawn_exit
		jmp draw_pawn_loop

	draw_pawn_exit:
		sub dx, 48
		pop Y
		pop X 
		ret
Draw_Pawn endp

; al - PixelColor
Print_Pixel_NZ proc
	cmp al, 0
	jne print_pixel_nz_exit
	call Print_Pixel
	print_pixel_nz_exit:
		ret
Print_Pixel_NZ endp


Reset_Pawns proc 
	call Init_Pawn_Buffer

	mov cx, CHESSBOARD_X
	mov dx, CHESSBOARD_Y

	add dx, 48
	call Draw_BlackPawn_Line
	add dx, 48
	call Draw_BlackPawn_Line

	add dx, 144
	call Draw_WhitePawn_Line
	add dx, 48
	call Draw_WhitePawn_Line


	ret
Reset_Pawns endp


Draw_WhitePawn_Line proc 
	mov index, 0
	draw_white_line:
		call Draw_WhitePawn
		add cx, 48
		inc index
		cmp index, 8
		jl draw_white_line
	sub cx, 384
	ret
Draw_WhitePawn_Line endp

Draw_BlackPawn_Line proc 
	mov index, 0
	draw_black_line:
		call Draw_BlackPawn
		add cx, 48
		inc index
		cmp index, 8
		jl draw_black_line
	sub cx, 384
	ret
Draw_BlackPawn_Line endp

	X dw 0
	Y dw 0
	index db 0
	temp db 0
	CHESSBOARD_X equ 30
	CHESSBOARD_Y equ 30
	CHESSBOARD_BLACK equ 6
	CHESSBOARD_WHITE equ 14
	PAWN_WHITE equ 7
	PAWN_BLACK equ 0
	LAST_COLOUR db 0
	Pawn_Filename db 'IMG\PAWN.BMP',0
	Pawn_File_Handle dw 0
	Pawn_Buffer db 480h dup (0)
	Pawn_Buffer_end db 0