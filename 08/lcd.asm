section .data
    num equ 10
    num2 equ 24
section .text
    global _start

gcd:
    cmp rax, rbx
    ja cont
    xchg rax, rbx
  cont:
    mov rcx, rbx
    xor rdx, rdx
    
  loop:    
    mov rax, r12
    xor rdx, rdx
    div rcx
    mov r15, rdx
    
    mov rax, r13
    xor rdx, rdx
    div rcx
    mov r14, rdx
    
    cmp r14, 0
    jne cont2
    cmp r15, 0
    jne cont2
    ret

  cont2:
    dec rcx
    cmp rcx, 1
    ja loop


_start:
    mov rax, num
    mov rbx, num2
    
    mov r12, rax
    mov r13, rbx
    
    call gcd
    
    mov rax, r12
    mul r13
    div rcx
    mov rdx, rax
    
exit:
    mov eax, 1
    mov ebx, 0
    int 80h