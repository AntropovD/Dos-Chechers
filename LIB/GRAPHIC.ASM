;===============================================================
Init_Graphic proc 
	mov ax, 12h
	int 10h

	mov ah, 0Fh
	int 10h
	mov Old_Videomode, al

	mov HB_Pointer, offset History_Buffer

	cmp YOUR_COLOR, 2
	jne not_change_Color
		mov bl, PAWN_WHITE
		mov bh, PAWN_BLACK
		mov PAWN_BLACK, bl
		mov PAWN_WHITE, bh	
	not_change_Color:
	
	call Init_Pawn_Buffer
	call Draw_Chessboard
	call Draw_Pawns
	call Draw_Frame
	call Draw_Message_Box
	call Update_Name_Box
	
	call Execute_Help_Command
	ret
Init_Graphic endp
;===============================================================
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
;===============================================================
Print_Pixel proc
	push es
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
	pop es
	ret
Print_Pixel endp
;===============================================================
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

	mov ax, 3d00h
	mov dx, offset King_Filename
	int 21h	

	mov bx, ax
	mov ax, 4200h
	xor cx, cx
	mov dx, 076h
	int 21h

	mov ah, 3fh
	mov cx, 480h
	mov dx, offset King_Buffer
	int 21h

	ret
Init_Pawn_Buffer endp
;===============================================================
Draw_Chessboard proc
	mov cx, 0
	mov dx, 0
	mov Index, 0
		draw_chessboard_loop:	
			xor ax, ax
			mov al, byte ptr Index
			mov bl, 8
			div bl
			and ah, 0001b
			and al, 0001b
			cmp ah, al		
			jne black_cell
				call Draw_WhiteBox
				jmp $+5
			black_cell:
				call Draw_BlackBox		
			
				add cx,48
				cmp cx, 384
				jne not_new_line
				sub cx, 384
				add dx, 48
			
			not_new_line:
				inc Index 
				cmp Index, 64	
				jne draw_chessboard_loop	
	ret
Draw_Chessboard endp
;===============================================================
Draw_Pawns proc
	cmp YOUR_COLOR, 0
	jne can_draw_pawns
	ret
	can_draw_pawns:

	mov cx, 0
	mov dx, 0
	mov Index, 0
	mov si, offset BOARD

	draw_chessboard_loop_2:
		lodsb
		cmp al, 0
		je no_pawn_in_cell
		cmp al, 1
		je white_pawn_in_cell
		cmp al, 2
		je black_pawn_in_cell
		cmp al, 3
		je white_king_in_cell
		cmp al, 4
		je black_king_in_cell
		
		no_pawn_in_cell:
			add cx,48
			cmp cx, 384
			jne not_new_line_2
			sub cx, 384
			add dx, 48
		
		not_new_line_2:
			inc Index 
			cmp Index, 64
			jne draw_chessboard_loop_2
	ret

	white_pawn_in_cell:
		push si
		call Draw_WhitePawn
		pop si
		jmp no_pawn_in_cell
	black_pawn_in_cell:
		push si
		call Draw_BlackPawn
		pop si
		jmp no_pawn_in_cell
	white_king_in_cell:
		push si
		call Draw_WhiteKing
		pop si
		jmp no_pawn_in_cell
	black_king_in_cell:
		push si
		call Draw_BlackKing
		pop si
		jmp no_pawn_in_cell
Draw_Pawns endp
;===============================================================
	Draw_WhiteBox proc 
		mov al, CHESSBOARD_WHITE
		call Change_Colour
		call Draw_Box
		ret
	Draw_WhiteBox endp
	Draw_BlackBox proc 
		mov al, CHESSBOARD_BLACK	
		call Change_Colour
		call Draw_Box
		ret
	Draw_BlackBox endp	
	Draw_Box proc 
		cli
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
			sti
			ret
	Draw_Box endp
;===============================================================
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
		cli
		mov X, 0
		mov Y, 0
		mov si, offset Pawn_Buffer
		draw_pawn_loop:
			lodsb
			mov Temp, al
			shr al, 4
			call Print_Pixel_If_Not_Zero
			inc cx
			mov al, Temp
			and al, 01111b
			call Print_Pixel_If_Not_Zero
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
			sti
			ret
	Draw_Pawn endp
;===============================================================
	Draw_WhiteKing proc 
		mov al, PAWN_WHITE
		call Change_Colour
		call Draw_King
		ret	
	Draw_WhiteKing endp
	Draw_BlackKing proc
		mov al, PAWN_BLACK
		call Change_Colour
		call Draw_King
		ret
	Draw_BlackKing endp
	Draw_King proc
		cli
		mov X, 0
		mov Y, 0
		mov si, offset King_Buffer
		draw_king_loop:
			lodsb
			mov Temp, al
			shr al, 4
			call Print_Pixel_If_Not_Zero
			inc cx
			mov al, Temp
			and al, 01111b
			call Print_Pixel_If_Not_Zero
			inc cx
			inc Y
			cmp Y, 24
			je draw_king_new_line
			jmp draw_king_loop

		draw_king_new_line:
			sub cx, 48
			inc dx
			inc X
			mov Y, 0
			cmp X, 48
			je draw_king_exit
			jmp draw_king_loop

		draw_king_exit:
			sub dx, 48
			sti
			ret
	Draw_King endp
;===============================================================
Print_Pixel_If_Not_Zero proc
	cmp al, 0
	jne Print_Pixel_If_Not_Zero_exit
	call Print_Pixel
	Print_Pixel_If_Not_Zero_exit:
		ret
Print_Pixel_If_Not_Zero endp
;===============================================================
Draw_Frame proc
	mov ax, 1300h
	mov bx, 09h
	mov cx, 29 
	mov dx, 0082h
	mov bp, offset Frame_Part1
	int 10h
	mov Temp, 28
	mov bp, offset Frame_Part2
	draw_frame_loop:
	add dx, 100h
	int 10h
	dec Temp
	cmp Temp, 0
	jg draw_frame_loop
	
	add dx, 100h
	mov bp, offset Frame_Part3
	int 10h
	ret
Draw_Frame endp
;===============================================================
Draw_Message_Box proc
	mov ax, 1300h
	mov bx, 09h
	mov cx, 50
	mov dx, 1b00h
	lea bp, Message_Box
	int 10h
	mov ax, 1300h
	mov bx, 09h
	mov cx, 50
	mov dx, 1c00h
	lea bp, Message_Box[50]
	int 10h
	mov ax, 1300h
	mov bx, 09h
	mov cx, 50
	mov dx, 1d00h
	lea bp, Message_Box[100]
	int 10h
	ret
Draw_Message_Box endp
;===============================================================
Update_Msg_Buf proc
	mov bx, offset Message_Buffer
	mov ax, MsgBuf_Pointer 
	sub ax, bx
	mov cx, ax
	
	mov ax, 1300h
	mov bx, 00fh	
	mov dx, 01c02h
	mov bp, offset Message_Buffer
	int 10h
	ret
Update_Msg_Buf endp
;===============================================================
Msg_Buf_Clear proc
	mov ax, 1300h
	mov bx, 00fh
	mov dx, 1c02h
	mov bp, offset Clear_Buffer
	int 10h
	ret
Msg_Buf_Clear endp
;===============================================================
; Change_Colour before using
Highlight_Chosen_Box  proc
	call Print_Pixel

	mov ax, 2
	int 33h
	cmp Last_Was_King, 1	
	je draw_king_1
		call Draw_Pawn
		jmp fin_drawing_pawn
	draw_king_1:
		call Draw_King
	fin_drawing_pawn:
	mov ax, 1
	int 33h

	ret
Highlight_Chosen_Box endp
;===============================================================
Check_History_Buffer proc
	cmp Update_History_Buffer_Flag, 1
	jne not_update_Hist_Buf
	call Update_Hist_Buf	
	mov Update_History_Buffer_Flag, 0
	not_update_Hist_Buf:		
	ret
Check_History_Buffer endp
;===============================================================
;===============================================================
; cx - заданная клекта в формате ah,al -> 1,1
;===============================================================
Unhighlight_Box proc	
	mov al, PAWN_WHITE
	call Change_Colour

	mov ax, LAST_CHOSEN_BOX
	dec ah
	dec al
	mov dl, 7
	sub dl, al
	mov al, dl
	mov bh, ah
	mov ah, 0	
	mov bl, 48
	mul bl
	mov dx, ax
	xor ax, ax
	mov al, bh
	mul bl
	mov cx, ax
	call Highlight_Chosen_Box
	ret
Unhighlight_Box endp
;===============================================================
Highlight_Box proc
	call Get_Box_From_Coords
	dec ah
	dec al
	mov dl, 7
	sub dl, al
	mov al, dl
	mov bh, ah
	mov ah, 0	
	mov bl, 48
	mul bl
	mov dx, ax
	xor ax, ax
	mov al, bh
	mul bl
	mov cx, ax
	mov al, 4
	call Change_Colour

	call Highlight_Chosen_Box
	ret
Highlight_Box endp
;===============================================================
Repaint_Pawned_Cell proc
	push cx
	call Find_Middle_Cell
	mov cx, ax
	call Repaint_Cell
	pop cx	
	ret
Repaint_Pawned_Cell endp
;===============================================================
; cx
Repaint_Cell proc 	
	push bx cx dx
	mov bl, CHESSBOARD_BLACK
	mov chosen_cell_colour, bl
	and ch, 0001b
	and cl, 0001b
	cmp ch, cl
	je change_cell_colour
	mov bl, CHESSBOARD_WHITE
	mov chosen_cell_colour, bl
	change_cell_colour:
	mov al, chosen_cell_colour
	call Change_Colour

	pop dx cx
	push cx dx
	dec ch 
	dec cl
	xchg cl, ch
	mov bl, 48
	xor dx, dx
	mov dl, ch
	mov ch, 0

	mov ax, cx
	mul bl
	mov cx, ax

	mov ax, 7
	sub ax, dx
	mul bl
	mov dx, ax
	
	mov ax, 2
	int 33h
 	call Draw_Box
 	mov ax, 1 
 	int 33h

	pop dx cx bx
	ret	

	chosen_cell_colour db 0
Repaint_Cell endp
;===============================================================
	Index db ?
	Old_Videomode db ?
	X dw ?
	Y dw ?
	Temp db ?

	Pawn_Filename db 'IMG\PAWN.BMP',0
	Pawn_Buffer db 480h dup (0)

	King_Filename db 'IMG\KING.BMP',0
	King_Buffer db 480h dup (0)

	Empty_Frame_Part db 27 dup(32)
	Frame_Part1 db 201, 27 dup (205), 187
	Frame_Part2 db 186, 27 dup (32), 186
	Frame_Part3 db 200, 27 dup(205), 188

	Message_Box 	db 201, 48 dup(205), 187
					db 186, 48 dup(32), 186
					db 200, 48 dup(205), 188

	HB_Pointer dw 0
	History_Buffer db 756 dup (32)
	HB_End db ?

	MsgBuf_Pointer dw 0
	Message_Buffer db 54 dup (32)
	Clear_Buffer db 54 dup (32)

	CHESSBOARD_BLACK db 6
	CHESSBOARD_WHITE db 14
	PAWN_WHITE db 7
	PAWN_BLACK db 0	