section .data
    dir db 'original',0
    dir_fd db 0

section .bss
    filenames resb 200

section .text
    global _start

_start:
    mov eax, 5
    mov ebx, dir
    mov ecx, 0
    int 80h

    mov [dir_fd], al

    mov eax, 141
    mov ebx, [dir_fd]
    mov ecx, filenames
    mov edx, 0x3210
    int 80h

exit:
    mov eax, 1
    mov ebx, 0
    int 80h
