section .data
    num equ 10120123807 ; digits' sum: 25

section .text
    global _start

_start:
    mov rcx, 10  ; base
    mov rax, num ; num

digits_sum:
    xor rbx, rbx
    xor rdx, rdx
  do:
    div rcx
    add rbx, rdx
    xor rdx, rdx
    cmp rax, 0
    jne do
    
    mov rdx, rbx
    
exit:
    mov rax, 1
    mov rbx, 0
    int 80h