.model tiny
.386
.code
org 100h

Start:		
	call Update_Char_Table
	call Clear_Screen_Page1
	call AddFences
	call Clear_Screen_Page2
	call Print_Help
	call Set_Normal_Morda
	call AddMouseWork
	
	mov Rotation_Sequence, offset Rotation_Sequence_Right	

;==============================================================
	call Set_Interrupts	

	mov _head, offset _buffer
	mov _tail, offset _buffer	
	
	mov ax, 0501h
	int 10h
;==============================================================
__Main_loop:
	cli
		push 0B800h
		pop es
		mov di, 0F9Eh
		mov dx, 1423h
		mov es:[di], dx
		
		cmp Timer_Flag, 1
		
		mov ax, 2
		int 33h
		
		je second_tick		
		second_tick_return:		
		
		mov ax, 1
		int 33h
		
		keyboard_check:
			mov ax, _head
			mov bx, _tail
			cmp ax, bx
			jne char_available
			char_available_return:		
	sti
	jmp __Main_loop	
;==============================================================
second_tick:
		call Show_Points

		mov Timer_Flag, 0
		
		cmp Rotate_Flag, 1
		jne second_tick_return

		mov cx, Rotate_Index_To_Check
		cmp Rotate_Index, cx
		jge mov_count_0
	back_mov0:
		
		
		mov ax, 0B800h
		mov es, ax
		mov di, Position	

		mov dx, es:[di]
		cmp Eat_Mode_Flag, 1					
		jne second_tick_mark
		mov dh, 0eh
	second_tick_mark:
		mov ax, es:[di+2]
		cmp Eat_Mode_Flag, 1					
		jne second_tick_mark_2
		mov ah, 0eh

	second_tick_mark_2:
		mov bx, Rotation_Sequence
		
		mov cx, Rotate_Index
		add bx, cx
		
		mov dl, byte ptr cs:[bx]
		mov es:[di], dx    
		inc dl
		mov dh, ah
		mov es:[di+2], dx
		
		inc Rotate_Index		
		jmp second_tick_return
		
	mov_count_0:			
		call Clear_Position

		mov dx, Position
		mov Old_Position, dx
		cmp Move_Flag, 1
		je _right_flag
		cmp Move_Flag, 2
		je _left_flag
		cmp Move_Flag, 4
		je _up_flag
		cmp Move_Flag, 3
		je _down_flag
	
	flag_back:
		push 0B800h
		pop es
		mov di, Position
		mov dx, es:[di]
		cmp dl, 023h			
		je FenceCollision	
		cmp dl, 0f0h
		je Add_Points_1
	back1:
		mov dx, es:[di+2]
		cmp dl, 023h
		je FenceCollision		
		cmp dl, 0f0h
		je Add_Points_2
	back2:
		cmp Move_Type_Flag, 1
		jne move_type_neq_1
	move_type_back:
		mov Rotate_Index, 0
		jmp back_mov0

	move_type_neq_1:
		mov Move_Flag, 0
		mov Rotate_Flag, 0
		jmp move_type_back
		
	
	Add_Points_1:
		mov bx, Points
		inc bx
		mov Points, bx
		jmp back1
		
	Add_Points_2:
		mov bx, Points
		inc bx
		mov Points, bx
		jmp back2
	
	FenceCollision:
		mov bx, Old_Position
		mov Position, bx 
		mov Move_Flag, 0
		mov Rotate_Flag, 0
		call Set_Normal_Morda
		call PlayMusic
		jmp second_tick_return


	_right_flag:
		add Position, 2
		mov ax, Position
		mov cl, 0a0h
		div cl		
		cmp ah, 0
		je right_border		
		jmp flag_back
		
	right_border:
		mov cx, 0a0h
		sub Position, cx
		jmp flag_back
		
	_left_flag:
		mov ax, Position
		mov cl, 0a0h
		div cl		
		cmp ah, 0
		je left_border				
		sub Position, 2
		jmp flag_back
		
	left_border:
		mov cx, 78*2
		add Position, cx
		jmp flag_back
		
	_up_flag:
		sub Position, 0a0h
		cmp Position, 0 
		jl up_border
		jmp flag_back
		
	up_border:
		mov cx, 80*2*25
		add Position,cx
		jmp flag_back
		
	_down_flag:
		add Position, 0a0h
		cmp Position, 0fa0h
		jg down_border
		jmp flag_back
	
	down_border:
		mov cx, 80*25*2
		sub Position, cx
		jmp flag_back
	
;==============================================================
	char_available:			
		mov bx, _head
		mov ax, ds:[bx]
		
	cmp al, 01
		je esc_pressed
		
	cmp al, 02h
		je Button_1
	cmp al, 03h
		je Button_2
	cmp al, 04h
		je Button_3
	cmp al, 05h
		je Button_4
	cmp al, 06h
		je Button_5
	cmp al, 07h
		je Button_6
	cmp al, 08h
		je Button_7
	cmp al, 09h
		je Button_8
	cmp al, 0Ah
		je Button_9
	cmp al, 0Bh
		je Button_0		
		
	cmp al, 3bh
		je F1_Button
	cmp al, 3ch
		je F2_Button
	cmp al, 3dh
		je F3_Button	
	cmp al, 3eh
		je F4_Button	
	cmp al, 3fh
		je F5_Button	
	cmp al, 41h
		je F7_Key
		
	cmp al, 48h
		je up_arrow
	cmp al, 4bh
		je left_arrow
	cmp al,4dh
		je right_arrow
	cmp al, 50h
		je down_arrow				
		
	cmp al, 39h
		je space	
		
	keyboard_back:
		add _head, 2
		cmp _head, offset _buffer_end
		;jle keyboard_check
		jle __Main_loop
		mov _head, offset _buffer		
		;jmp keyboard_check	
		jmp __Main_loop
		
	esc_pressed:
		call Exit_Proc		
	
	Button_0:		
		jmp space		
	Button_1:
		mov Rotate_Index_To_Check, 8
		mov Ticks_On_Rotate,9
		jmp keyboard_back
	Button_2:
		mov Rotate_Index_To_Check, 8
		mov Ticks_On_Rotate,8
		jmp keyboard_back
	Button_3:
		mov Rotate_Index_To_Check, 8
		mov Ticks_On_Rotate,7
		jmp keyboard_back
	Button_4:
		mov Rotate_Index_To_Check, 8
		mov Ticks_On_Rotate,6
		jmp keyboard_back
	Button_5:
		mov Rotate_Index_To_Check, 4
		mov Ticks_On_Rotate,5
		jmp keyboard_back
	Button_6:
		mov Rotate_Index_To_Check, 4
		mov Ticks_On_Rotate,4
		jmp keyboard_back
	Button_7:
		mov Rotate_Index_To_Check, 4
		mov Ticks_On_Rotate,3
		jmp keyboard_back
	Button_8:
		mov Rotate_Index_To_Check, 4
		mov Ticks_On_Rotate,2
		jmp keyboard_back
	Button_9:
		mov Rotate_Index_To_Check, 2
		mov Ticks_On_Rotate,1
		jmp keyboard_back
	
	F1_Button:
		mov Game_Active_Flag, 0
		
		mov ax, 2
		int 33h
		mov Move_Flag, 0
		mov Rotate_Flag, 0
		call Set_Normal_Morda
		mov ax, 0501h
		int 10h
		jmp keyboard_back		
	F2_Button:			
	
		mov Game_Active_Flag, 1
		mov ax, 1
		int 33h		
		
		mov ax, 4
		mov cx, 0
		mov dx, 1000		
		int 33h
		
		mov ax, 0500h
		int 10h
		jmp keyboard_back

	F3_Button:		
		cmp Game_Active_Flag, 0
		je keyboard_back
		mov dl, Eat_Mode_Flag
		xor dl, 1
		mov Eat_Mode_Flag, dl
		call Set_Normal_Morda
		jmp keyboard_back	

	F4_Button:
		cmp Game_Active_Flag, 0
		je keyboard_back
		call Restart_Proc
		jmp keyboard_back	
		
	F5_Button:
		cmp Game_Active_Flag, 0
		je keyboard_back
		mov dl, Move_Type_Flag
		xor dl, 1
		mov Move_Type_Flag, dl
		jmp keyboard_back
	
	space:
		mov Move_Flag, 0
		mov Rotate_Flag, 0
		call Set_Normal_Morda
		jmp keyboard_back
	
	F7_Key:
	
		call PlayMusic
		jmp keyboard_back	
		
	up_arrow:		
		cmp Game_Active_Flag, 0
		je keyboard_back
		mov Move_Flag, 4
		mov Rotate_Flag, 1
		jmp keyboard_back
		
	left_arrow:
		cmp Game_Active_Flag, 0
		je keyboard_back
		cli
		mov bx, offset Rotation_Sequence_Left
		mov Rotation_Sequence, bx
		mov Move_Flag, 2
		mov Rotate_Flag, 1
		sti
		jmp keyboard_back

				
	right_arrow:
		cmp Game_Active_Flag, 0
		je keyboard_back
		cli
		mov bx, offset Rotation_Sequence_Right
		mov Rotation_Sequence, bx	
		mov Move_Flag, 1
		mov Rotate_Flag, 1
		sti
		jmp keyboard_back
		
	down_arrow:
		cmp Game_Active_Flag, 0
		je keyboard_back
		mov Move_Flag, 3
		mov Rotate_Flag, 1
		jmp keyboard_back	
			
;==============================================================
Set_Interrupts proc near
	cli
		mov ax, 03509h
		int 21h
		mov word ptr vector_09h, bx
		mov word ptr vector_09h+2, es		
		mov ax, 02509h
		mov dx, offset interrupt_09h
		int 21h

		mov ax, 3508h
		int 21h	
		mov word ptr vector_08h, bx
		mov word ptr vector_08h+2, es
		mov ax, 02508h
		mov dx, offset interrupt_08h
		int 21h
		ret
	sti
Set_Interrupts endp
;==============================================================
Clear_Position proc near
		mov ax, 0B800h
		mov es, ax
		mov di, word ptr Position
		mov dx, es:[di]
		mov dl, 0
		mov  es:[di], dx
		mov dx, es:[di+2]
		mov dl, 0
		mov  es:[di+2], dx
		ret
Clear_Position endp
;==============================================================
Set_Normal_Morda proc near
		mov ax, 0B800h
		mov es, ax
		mov di, word ptr Position

		mov dx, es:[di]
		cmp Eat_Mode_Flag, 1		
		jne set_morda_mark
		mov dh, 0eh

	set_morda_mark:
		mov dl, 0e0h
		mov  es:[di], dx
		mov dl, 0e1h
		mov  es:[di+2], dx
		ret
Set_Normal_Morda endp
;==============================================================
Exit_Proc proc near
	cli		
			push ds
			pop es		
			mov bx, 0020h
			mov ax, word ptr es:[vector_08h]
			push 0
			pop es 
			mov es:[bx], ax
			push ds
			pop es
			mov ax, word ptr es:[vector_08h+2]
			push 0
			pop es
			mov es:[bx+2], ax	
		
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
			
			mov ax, 000Ch
			mov cx, 0000h
			int 33h
			
			mov ax, 3
			int 10h
	sti	
	int 20h
	ret		
Exit_Proc endp
;==============================================================
Write_Buffer proc near
		mov bx, ds:[_tail]
		mov ds:[bx], ax
		add _tail, 2
		cmp _tail, offset _buffer_end
		jle __continue_write_buffer
		mov _tail, offset _buffer	
		__continue_write_buffer:
		ret
Write_Buffer endp
;==============================================================
interrupt_09h:
		 push      ax
	     push      di
	     push      es
	     in        al,60h	 
		 call Write_Buffer
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
;==============================================================
interrupt_08h:			
		mov dx, Music_Tick_Counter
		inc dx	
		mov Music_Tick_Counter, dx	
		
		mov dx, Tick_Counter	
		inc dx	
		cmp dx, Ticks_On_Rotate
		jl not_second_tick
		mov Timer_Flag, 1
		mov dx, 0
		
	not_second_tick:		
		mov Tick_Counter, dx
		jmp cs:vector_08h	
;==============================================================
Update_Char_Table proc near		
		mov ax, 1100h	
	    mov bh, 14
	    mov bl, 0	
	    mov cx, 17
		mov bp, offset Font
	    mov dx, 0e0h
	    int 10h
	ret 	
	Include		.\Font.inc
Update_Char_Table endp
;==============================================================
Clear_Screen_Page1 proc near	
		mov ax, 0B800h
		mov es, ax
		mov dx, 02e00h	
		mov di, 0
		mov cx, 2000
		
	green_loop:
			mov  es:[di], dx   		
			add di, 2
		loop green_loop
	ret	
Clear_Screen_Page1 endp
;==============================================================
AddFences proc near	
		mov ax, 0B800h
		mov es, ax
		
		mov di, 0h
		mov dx, 1423h		
		mov cx, 40
		
	fence_loop1:
			mov es:[di], dx
			add di, 2
			loop fence_loop1
			
		mov di, 0e10h
		mov cx, 40
		mov es:[di+0a0h],dx
		mov es:[di+0a0h+78],dx
	fence_loop2:
			mov es:[di], dx
			mov es:[di+140h], dx
			add di, 2
			loop fence_loop2
		
	ret
AddFences endp
;==============================================================
Clear_Screen_Page2 proc near	
		mov ax, 0501
		int 10h	
		mov ax, 0B800h
		mov es, ax
		mov dx, 02e00h	
		mov di, 01000h
		mov cx, 2000
		
	green_loop2:
			mov  es:[di], dx   		
			add di, 2
		loop green_loop2
	ret	
Clear_Screen_Page2 endp
;==============================================================
Restart_Proc proc near
		mov Position, 07D0h
		mov Rotation_Sequence, offset Rotation_Sequence_Right
		mov Eat_Mode_Flag, 0
		mov Points, 0
		call Clear_Screen_Page1
		call AddFences	
		call Set_Normal_Morda
	ret	
Restart_Proc endp
;==============================================================
Print_Help proc near	
	mov ax, 0B800h
	mov es, ax
	mov dh, 02eh	
	
	mov cx, 13
	mov di, 01530h
	mov bp, offset HelpMessage1
	call Print_Rotation_Sequence
	
	mov cx, 55
	mov di, 01650h
	mov bp, offset HelpMessage2
	call Print_Rotation_Sequence
	
	mov cx, 19
	mov di, 016F0h
	mov bp, offset HelpMessage3
	call Print_Rotation_Sequence
	
	mov cx, 15
	mov di, 01790h
	mov bp, offset HelpMessage4
	call Print_Rotation_Sequence
	
	mov cx, 13
	mov di, 01830h
	mov bp, offset HelpMessage5
	call Print_Rotation_Sequence
	
	mov cx, 12
	mov di, 018D0h
	mov bp, offset HelpMessage6
	call Print_Rotation_Sequence
	
	mov cx, 21
	mov di, 01970h
	mov bp, offset HelpMessage7
	call Print_Rotation_Sequence
	
	mov cx, 28
	mov di, 01A10h
	mov bp, offset HelpMessage13
	call Print_Rotation_Sequence
	
	mov cx, 15
	mov di, 01AB0h
	mov bp, offset HelpMessage8
	call Print_Rotation_Sequence
	
	mov cx, 22
	mov di, 01B50h
	mov bp, offset HelpMessage9
	call Print_Rotation_Sequence
	
	mov cx, 27
	mov di, 01BF0h
	mov bp, offset HelpMessage10
	call Print_Rotation_Sequence
	
	mov cx, 12
	mov di, 01C90h
	mov bp, offset HelpMessage11
	call Print_Rotation_Sequence
	
	mov cx, 10
	mov di, 01D30h
	mov bp, offset HelpMessage12
	call Print_Rotation_Sequence
	ret	
Print_Help endp
;==============================================================
Print_Rotation_Sequence proc near
	Print_Loop:
		mov dl, byte ptr cs:[bp]		
		mov es:[di], dx
		add di, 2
		add bp, 1
		loop Print_Loop
	ret	
Print_Rotation_Sequence endp
;==============================================================
Show_Points proc near	
		push 0B800h
		pop es
		
		mov ax, 2
		int 33h
		
		mov bl, 10
		mov ax, Points
		div bl
		push ax
		mov cl, al
		xor ax, ax
		mov al, cl
		div bl		
		push ax
		
		mov dh, 02eh
		mov dl, al
		add dl, '0'
		mov di, 0ed8h
		mov es:[di], dx
		pop ax
		mov dl, ah
		add dl, '0'
		mov es:[di+2],dx
		pop ax
		mov dl, ah
		add dl, '0'
		mov es:[di+4],dx
		
		mov ax, 1
		int 33h		
	ret
Show_Points endp
;==============================================================
Sound proc near
	push     ax    
	push     bx
	push     dx
	mov      bx,ax  
	mov      ax,34DDh
	mov      dx,12h 
	cmp      dx,bx  
	jnb      Done   
	div      bx     
	mov      bx,ax
	in       al,61h
	or       al,3  
	out      61h,al
	mov      al,00001011b 
					  
	mov      dx,43h
	out      dx,al     
	dec      dx
	mov      al,bl
	out      dx,al     
	mov      al,bh
	out      dx,al     
Done:
	pop		dx        
	pop     bx
	pop     ax
	ret
Sound  endp
;==============================================================
No_Sound proc near	
		push     ax
		in       al,61h 
		and      al,not 3
		out      61h,al
		pop      ax
	ret
No_Sound endp
;==============================================================
AddMouseWork proc near	
		mov ax, 0000h
		int 33h
		
		push cs
		pop es
		
		mov ax, 000Ch
		mov cx, 0ah
		mov dx, offset Mouse_Handler
		int 33h		
	ret
AddMouseWork endp

Mouse_Handler:
		push bx
		mov ax, 2
		int 33h
		
		mov ax, cx 
		mov bl, 08h
		div bl
		xor cx, cx
		mov cl, al
		
		mov ax, dx
		mov bl, 08h
		div bl
		xor dx, dx
		mov dl, al
		
		mov bl, 0A0h
		mov ax, dx
		mul bl		
		add ax, cx
		add ax, cx
		mov di, ax
		
		pop bx
		cmp bx, 1
		jne Right_Button
		
		push 0B800h
		pop es
		
		mov dx, es:[di]
		cmp dl, 0h
		jne exit_handle_mouse
		mov dx, es:[di+2]
		cmp dl, 0h
		jne exit_handle_mouse
		
		mov dh, 2eh
		mov dl, 0f0h		
		mov es:[di],  dx	
	exit_handle_mouse_2:	
		mov ax, 1
		int 33h		
		retf

	Right_Button:
		cmp ax, Position
		je exit_handle_mouse
		mov bx, ax
		sub bx, 2
		cmp bx, Position
		je exit_handle_mouse
		
		mov dx, 1423h
		
		push 0B800h
		pop es
		mov es:[di],  dx		
		
	exit_handle_mouse:
		mov ax, 1
		int 33h		
		retf
;==============================================================
PlayMusic proc near	
	sti
		mov ax, 392
		call PlayDouble
		mov ax, 329
		call PlayOnce
		call PlayOnce
		
		mov ax, 392
		call PlayDouble
		mov ax, 329
		call PlayOnce
		call PlayOnce
		
		mov ax, 392
		call PlayOnce		
		mov ax, 349
		call PlayOnce
		mov ax, 329
		call PlayOnce
		mov ax, 293
		call PlayOnce
		mov ax, 261
		call PlayOnce
		
		call Delay
		
		; mov ax, 440
		; call PlayDouble
		; mov ax, 523
		; call PlayOnce
		; mov ax, 440
		; call PlayOnce
		
		; mov ax, 392
		; call PlayDouble
		; mov ax, 329
		; call PlayOnce
		; call PlayOnce
		
		; mov ax, 392
		; call PlayOnce		
		; mov ax, 349
		; call PlayOnce
		; mov ax, 329
		; call PlayOnce
		; mov ax, 293
		; call PlayOnce
		; mov ax, 261
		; call PlayOnce
	cli
	ret
PlayMusic endp
;==============================================================
Delay proc near
	mov Music_Tick_Counter,0
	My_Loop:
		cmp Music_Tick_Counter, 2
		jl My_Loop			
	mov Music_Tick_Counter, 0		
	ret
Delay endp
;==============================================================
DelayL proc near
	mov Music_Tick_Counter,0
	My_LoopL:
		cmp Music_Tick_Counter, 1
		jl My_Loop			
	mov Music_Tick_Counter, 0		
	ret
DelayL endp
;==============================================================
PlayDouble proc near
		call Sound
		call Delay		
		call Delay
		call No_Sound
		call DelayL
	ret
PlayDouble endp
;==============================================================
PlayOnce proc near	
		call Sound
		call Delay
		call No_Sound
		call DelayL
	ret
PlayOnce endp
;==============================================================
;	Data_Segment

	vector_09h 	dd ?
	vector_08h 	dd ?
	_head 		dw 0
	_tail 		dw 0
	
	HelpMessage1 	db 'K O L O B O K'
	HelpMessage2 	db 'Kolobok videogame created by Antropov Dmitry, year 2015.'
	HelpMessage3 	db 'F1 - Show this page'
	HelpMessage4 	db 'F2 - Start Game'
	HelpMessage5 	db 'F3 - Eat Mode'
	HelpMessage6 	db 'F4 - Restart'
	HelpMessage7 	db 'F5 - Change Move Type'
	HelpMessage8 	db 'F7 - Play Music'
	HelpMessage9 	db 'Arrows to move Kolobok'
	HelpMessage10 	db 'Numbers 0..9 - Change Speed'
	HelpMessage11 	db 'Space - Stop'
	HelpMessage12 	db 'Esc - Exit'
	HelpMessage13 	db 'F6 - Fence construction Mode'
	
	Rotation_Sequence dw 0
	Rotation_Sequence_Right	db 0e0h,0e2h,0e4h,0e6h,0e8h,0eah,0ech,0eeh	
	Rotation_Sequence_Left  db 0e0h, 0eeh, 0ech, 0eah, 0e8h, 0e6h, 0e4h, 0e2h
	
	Position 			dw 07d0h	
	Old_Position 		dw 0
	
	Rotate_Index 		dw 0
	Timer_Flag 			db 0			
	Move_Flag 			db 0
	Tick_Counter 		dw 0
	Ticks_On_Rotate 	dw 2		
	Music_Tick_Counter 	dw 0		
	
	Rotate_Flag			db 0
	Eat_Mode_Flag 		db 0	
	Move_Type_Flag 		db 0

	Fence_Construct_Flag db 0
	
	Rotate_Index_To_Check dw 8
	
	Game_Active_Flag 	db 0

	Points 				dw 0
	_buffer 			dw 6 dup (0)
	_buffer_end 		dw 0
	
end Start