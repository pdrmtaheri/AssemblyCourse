section .data
    num equ 28
    perfect_msg db 'Perfect!',10
    perfect_msg_len equ $-perfect_msg 
    non_perfect_msg db 'Not Perfect!',10
    non_perfect_msg_len equ $-non_perfect_msg 
section .text
    global _start

perfect:
    mov ecx, perfect_msg
    mov edx, perfect_msg_len
    mov eax, 4
    mov ebx, 1
    int 80h
    jmp exit

non_perfect:
    mov ecx, non_perfect_msg
    mov edx, non_perfect_msg_len
    mov eax, 4
    mov ebx, 1
    int 80h
    jmp exit

_start:
    mov rax, num

is_perfect:    
    call check_special_cases
    mov rcx, rax
    xor rdx, rdx
  loop:
    dec rcx
    mov rax, num
    xor rdx, rdx
    div rcx
    cmp rdx, 0
    jne non_divisor
    add r15, rcx
non_divisor:
    cmp rcx, 1
    ja loop
    cmp r15, num
    je perfect
    jmp non_perfect
    
check_special_cases:
    cmp rax, 1
    je non_perfect
    ret

exit:
    mov eax, 1
    mov ebx, 0
    int 80h