section .data
    num equ 28
    perfect_msg db 'Perfect!',10
    perfect_msg_len equ $-perfect_msg 
    non_perfect_msg db 'Not Perfect!',10
    non_perfect_msg_len equ $-non_perfect_msg 

section .bss
    dummy resb 1

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
    jne next

    mov r8, rax
    mov rax, rcx
    call print_rax
    call print_newline
    mov rax, r8
    
    add r15, rcx
    next:
        cmp rcx, 1
        ja loop
        cmp r15, num
        je perfect
        jmp non_perfect
    
print_rax:
    push rax
    push rcx
    push rdx
    xor rdx, rdx
    mov rbx, 10
    div rbx
    test rax, rax
    je .l1
    call print_rax
  .l1:
    add rdx, '0'
    mov [dummy], rdx
    mov rax, 4
    mov rbx, 1
    mov rcx, dummy
    mov rdx, 1
    int 80h
    
    pop rdx
    pop rcx
    pop rax
    ret

print_newline:
    push rax
    push rcx
    push rdx

    mov byte [dummy], ' '

    mov rax, 4
    mov rbx, 1
    mov rcx, dummy
    mov rdx, 1
    int 80h

    pop rax
    pop rcx
    pop rdx
    ret

check_special_cases:
    cmp rax, 1
    je non_perfect
    ret

exit:
    mov eax, 1
    mov ebx, 0
    int 80h