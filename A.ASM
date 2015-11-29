	.model tiny
	.code
	.386
	org 100h
Start:
	call Init	
	
	Main_Loop:
	cli
		cmp timer_flag, 1
		jne not_second_tick
		mov timer_flag, 0
		mov ah, 2
		mov dl, 'A'
		int 21h
	not_second_tick:
		call Keyboard_CheckBuffer
	sti
	jmp Main_Loop
	

Init proc 
	call Clear_Screen
	call Draw_Chessboard
	call Serial_Install	
	call Interrupts_Install
	
	ret
Init endp

Interrupts_Install proc
	cli
		mov ax, 3508h
		int 21h
		mov word ptr vector_08h, bx
		mov word ptr vector_08h+2, es		
		mov ax, 02508h
		mov dx, offset interrupt_08h
		int 21h
	sti
	ret
Interrupts_Install endp

Interrupts_Uninstall proc
	cli
		push ds
		mov dx, word ptr vector_08h
		mov ax, word ptr vector_08h+2
		mov ds, ax
		mov ax, 2508h
		int 21h
		pop ds
	sti
	ret
Interrupts_Uninstall endp

interrupt_08h proc
	cmp tick_count, 18
	jl not_next_second
	mov tick_count, 0
	mov timer_flag, 1
	not_next_second:
	inc tick_count
	mov al, 20h
	out 20h, al
	iret
interrupt_08h endp

Exit_Procedure proc
	call Serial_Uninstall
	call Interrupts_Uninstall
	int 20h
	ret
Exit_Procedure endp

	vector_08h dd ?
	timer_flag db 0
	tick_count dw 0
	include .\LIB\GRAPHIC.ASM	
	include .\LIB\KEYBOARD.ASM
	include .\LIB\MOUSE.ASM	
	include .\LIB\SERIAL.ASM
end Start

