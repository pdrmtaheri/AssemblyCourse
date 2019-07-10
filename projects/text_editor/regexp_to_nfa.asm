section .data
section .text
    global _start
_start:
exit:
    mov rax, 1
    mov rbx, 0
    int 80h