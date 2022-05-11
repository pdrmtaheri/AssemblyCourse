section .data
    num equ 6512301803 ; 11, 18

section .text
    global _start

_start:
    mov rax, num
    mov r8, 10 ; base

digits_sum:
    xor rcx, rcx
    xor rbx, rbx
    xor rdx, rdx
  do:
    div r8
    add rbx, rdx
    xor rdx, rdx
    cmp ax, 0
    je exit
    
    div r8
    add rcx, rdx
    xor rdx, rdx
    cmp rax, 0
    jne do
    
    mov rdx, rcx
    xchg rdx, rbx ; [TOF] swap rbx, rdx because BARAKS HESAB KARDAM
    
exit:
    mov rax, 1
    mov rbx, 0
    int 80h