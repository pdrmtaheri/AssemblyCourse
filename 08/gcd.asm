section .data
    num equ 24
    num2 equ 36
section .text
    global _start

_start:
    mov rax, num
    mov rbx, num2

gcd:
    cmp rax, rbx
    ja cont
    xchg rax, rbx
  cont:
    mov rcx, rbx
    xor rdx, rdx
    
    mov r12, rax
    mov r13, rbx
  loop:    
    mov rax, r12
    xor rdx, rdx
    div rcx
    mov r15, rdx
    
    mov rax, r13
    xor rdx, rdx
    div rcx
    mov r14, rdx
    
    cmp r14, r15
    je exit
    
    dec rcx
    cmp rcx, 1
    ja loop
    
exit:
    mov rdx, rcx
    mov eax, 1
    mov ebx, 0
    int 80h