section .data
    num equ 65123
    base db 10

section .text
    global _start

_start:
    mov ax, num

digits_sum:
    xor rcx, rcx
    xor rbx, rbx
    xor rdx, rdx
  do:
    div word [base]
    add bx, dx
    xor dx, dx
    cmp ax, 0
    je exit
    
    div word [base]
    add cx, dx
    xor dx, dx
    cmp ax, 0
    jne do
    
    mov rdx, rcx
    
exit:
    mov eax, 1
    mov ebx, 0
    int 80h