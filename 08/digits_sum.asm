section .data
    num equ 1012
    base db 10

section .text
    global _start

_start:
    mov ax, num

digits_sum:
    xor bx, bx
    xor dx, dx
  do:
    div word [base]
    add bx, dx
    xor dx, dx
    cmp ax, 0
    jne do
    
    mov rdx, rbx
    
exit:
    mov eax, 1
    mov ebx, 0
    int 80h