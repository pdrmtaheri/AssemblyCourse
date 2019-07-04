section .data
    num equ 7
    prime_msg db 'Prime!',10
    prime_msg_len equ $-prime_msg 
    non_prime_msg db 'Not Prime!',10
    non_prime_msg_len equ $-non_prime_msg 
section .text
    global _start

prime:
    mov ecx, prime_msg
    mov edx, prime_msg_len
    mov eax, 4
    mov ebx, 1
    int 80h
    jmp exit

non_prime:
    mov ecx, non_prime_msg
    mov edx, non_prime_msg_len
    mov eax, 4
    mov ebx, 1
    int 80h
    jmp exit

_start:
    mov rax, num


is_prime:    
    call check_special_cases
    mov rcx, rax
    xor rdx, rdx
  loop:
    dec rcx
    mov rax, num
    xor rdx, rdx
    div rcx
    cmp rdx, 0
    je non_prime
    cmp rcx, 2
    ja loop
    jmp prime
    
check_special_cases:
    cmp rax, 1
    je non_prime
    cmp rax, 2
    je prime
    ret

exit:
    mov eax, 1
    mov ebx, 0
    int 80h