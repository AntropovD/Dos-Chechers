mov ax, 1
mov dx, 3ceh
out dx,ax
mov ax, 011111110b
mov dx, 3cfh
out dx, ax
mov byte pty es:[bx], 011111110b
