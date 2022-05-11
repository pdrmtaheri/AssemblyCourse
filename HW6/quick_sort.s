section .data
    array dq 41,19,45,34,5,17,16,37,42,12,3,9,50,26,29,24,8,1,25,15

section .text
    global _start

swap_r9_r12:
    push rdx

    mov rdx, [array + r9*8]
    xchg rdx, [array + r12*8]
    xchg rdx, [array + r9*8]

    pop rdx
    ret

partition:
    mov r9, [rsp + 16]
    mov r10, [rsp + 8]
    mov r11, [array + r10*8] ; pivot
    mov r12, r9
    dec r12

    iterate:
        cmp r9, r10 
        je p_break

        cmp r11, [array + r9*8]
        jl next
        inc r12
        call swap_r9_r12
        next:
        inc r9
        jmp iterate

    p_break:
    mov r9, r10
    inc r12
    call swap_r9_r12

    ret 16

quicksort:
    mov rax, [rsp+16]
    mov rbx, [rsp+8]

    enter 24, 0
    mov [rbp-24], rax
    mov [rbp-16], rbx

    cmp rax, rbx
    jl recurse
    leave
    ret 16

    recurse:
    push rax
    push rbx
    call partition ; partition result in r12

    mov [rbp-8], r12

    push qword [rbp-24]
    dec qword [rbp-8]
    push qword [rbp-8]
    call quicksort

    add qword [rbp-8], 2
    push qword [rbp-8]
    push qword [rbp-16]
    call quicksort

    leave
    ret 16

_start:
    push qword 0  ; start
    push qword 19 ; end
    call quicksort

exit:
    mov rax, 60
    mov rdi, 0
    syscall
