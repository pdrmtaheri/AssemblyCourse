
section .data
    array dq 2,5,8,10,12,13,14,15,16,18,20,21,24,26,27,28,36,39,40,48

section .text
    global _start

binary_search: ; searches for third in [first, second). returns third's index in array in rax. if third does not exist, places -1 in rax
    mov rax, [rsp+24] ; start
    mov rbx, [rsp+16] ; end
    mov r9, [rsp+8] ; value to search for

    mov r10, rax
    mov r11, rbx
    sub r11, r10
    cmp r11, 1
    jne recurse

    cmp [array + rax*8], r9
    je found

    mov rax, -1  ; not found
    found:
    ret 24

    recurse:
    add rax, rbx
    xor rdx, rdx
    mov rcx, 2
    div cx
    push dx

    cmp [array + rax*8], r9
    jne compare
    pop dx
    ret 24 ; found

    compare:
    cmp [array + rax*8], r9
    jg left_half

    right_half:
    pop dx
    mov rdx, [rsp+16]
    push rax
    push rdx
    push r9
    call binary_search ; recurese right
    ret 24

    left_half:
    pop dx
    cmp dx, 0
    je contl
    inc rax
    contl:
    push qword [rsp+24]
    push rax
    push r9
    call binary_search ; recurse left
    ret 24


_start:
    push qword 0
    push qword 20
    push qword 28
    call binary_search ; rax : 15

exit:
    mov rax, 60
    mov rdi, 0
    syscall
