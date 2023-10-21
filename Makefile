CC=gcc
CFLAGS=-Wall -pedantic -Werror

build: loader.bin payload.bin
	@echo "Combining into image.bin"

%.bin: %.asm
	@echo "Building $@..."
	@nasm -fbin $< -o $@

run:
	@qemu-system-i386 -fda image.bin -display curses

clean:
	@echo "Cleaning"
	@rm -fv *.exe *.bin