	BITS 16
	
	mov ax, 0x7e0
	mov ds, ax
	mov ax, 0xb800
	mov es, ax

	mov ax, 3
	int 0x10

	xor di, di
	mov si, msg
	mov ah, 0x5f

next: 
	lodsb
	test al, al
	jz end
	stosw
	jmp next

end: jmp $
msg: 
	db ".o> <*_*> \^-^/ Hello guys welcome to my new tutorial!!!! And today i want to show you some interesting experiments!!!!", 0

