	BITS 16

_start:
	jmp init

decrypt:
	mov cx, 256
	mov di, 0x6000
	xor ax, ax

;ksa
.generate_s:
	mov [di], ax
	inc ax
	inc di
	loop .generate_s

.read_key:
	mov cx, 8
	mov si, 0x6500

.read_sym:
	mov ah, 0
	int 0x16
	mov [si], al
	inc si
	loop .read_sym

	mov cl, 0 ; i
	mov ch, 0 ; j

.shuffle_s:
	mov si, 0x6000 ;text
	mov di, 0x6500 ;key

	; j = (j + s[i] + t) % 256
	xor ax, ax
	mov al, cl
	mov bl, 8
	idiv bl

	xor dx, dx
	mov dl, ah
	add di, dx
	mov bl, [di] ; store t = key[i % 8]

	mov dl, cl
	add si, dx;
	mov bh, [si] ; store s[i]
	mov si, 0x6000
	add ch, bh ; add s[i]
	add ch, bl ; add t

	;s[i], s[j] = s[j], s[i]
	mov dl, ch
	add si, dx
	mov bl, [si] ; store s[j]
	mov [si], bh ; s[j] = s[i]
	mov si, 0x6000
	mov dl, cl
	add si, dx
	mov [si], bl ; s[i] = s[j]


	cmp cl, 0xff
	jz .exit_s

	inc cl

	jmp .shuffle_s

.exit_s:

.pgra:
	mov cl, 0 ; i
	mov ch, 0 ; j

	mov di, 0x7e00 ;sector
.xor:
	mov si, 0x6000 ;gamma
	xor dx, dx
	xor bx, bx

	inc cl ; i = (i + 1) % 256

	;j = (j + s[i]) % 256
	mov dl, cl 
	add si, dx
	mov bh, [si] ; store s[i]
	add ch, bh

	;s[i], s[j] = s[j], s[i]
	mov si, 0x6000
	mov dl, ch
	add si, dx
	mov bl, [si] ; store s[j]
	mov [si], bh ; s[j] = s[i]
	mov si, 0x6000
	mov dl, cl
	add si, dx
	mov [si], bl ; s[i] = s[j]

	add bl, bh ;t = (s[i] + s[j]) % 256

	mov si, 0x6000
	mov dl, bl
	add si, dx
	mov bh, [si] ; store s[t]

	xor [di], bh

	inc di

	cmp di, 0x8000
	jz .end

	jmp .xor

.end:
	ret

init:
	
	mov ax, 0x7e0
	mov bx, 0
	mov es, ax

	mov ah, 2
	mov al, 1
	mov cl, 2
	xor ch, ch
	mov dh, 0
	int 0x13

	call decrypt

	jmp 0x7e0:0

	times 510-($-$$) db 0
	dw 0xaa55
