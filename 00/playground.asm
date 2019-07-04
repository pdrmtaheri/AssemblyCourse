section .data
    d1 dd 0x1234
    d2 dd 0x90

section .text
    global _start
    
test:
    push rbp
    xor rax, rax
    mov rcx, [rsp + 16]
    pop rbp
    ret

_start:
    ;call test
    mov rbx, 100000000000000000
    push rbx
;    push ebx
;    push bx
;    push bl
    call test
    mov rbx, 20
    push rbx
    pop rbx
    call test
    
exit:
    mov eax, 1
    mov ebx, 0
    int 80h