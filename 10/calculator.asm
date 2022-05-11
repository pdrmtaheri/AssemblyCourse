section .data
    answer_len dd 0
    expression_len dd 0

section .bss
    expression resb 1024

    user_input resb 1008
    user_input_len resd 1

    current_operand resb 16
    current_operand_len resd 1

    current_operation resb 1

    operand_1 resb 16
    operand_1_len resd 1

    operand_2 resb 16
    operand_2_len resd 1

    answer resb 16

section .text
    global _start

read_user_input:
    mov rax, 3
    mov rbx, 0
    mov rcx, user_input
    mov rdx, 1000
    int 80h

    sub rax, 2
    mov [user_input_len], ax
    ret

append_previous_result_user_input:
    xor rcx, rcx
    mov cx, [expression_len]
    
    xor r8, r8
    input:
        cmp r8d, [user_input_len]
        jae b2

        mov dl, [user_input + r8]
        mov [expression + rcx], dl
        inc r8
        inc rcx
        jmp input
    
    b2:
    mov [expression_len], cx
    recurse:
        cmp rcx, 1024
        jae b3

        mov byte [expression + rcx], 0
        inc rcx
        jmp recurse

    b3:
    ret

reset_current_operand:
    push rcx

    xor rcx, rcx
    rco_iterate:
        cmp rcx, 16
        jae rco_break

        mov byte [current_operand + rcx], 0
        inc rcx
        jmp rco_iterate

    rco_break:
    mov dword [current_operand_len], 0
    pop rcx
    ret

fill_current_operand:
    call reset_current_operand
    push rdx
    fco_iterate:
        cmp cx, [expression_len]
        jae fco_b

        mov dl, [expression + rcx]
        cmp dl, '+'
        je fco_b
        cmp dl, '-'
        je fco_b
        cmp dl, '*'
        je fco_b
        cmp dl, '/'
        je fco_b

        mov bx, [current_operand_len]
        mov [current_operand + rbx], dl
        inc dword [current_operand_len]
        inc rcx
        jmp fco_iterate
    
    fco_b:
    pop rbx
    ret

load_operand_1:
    push rcx
    push rdx

    xor rcx, rcx
    lo1_loop:
        cmp rcx, 16
        jae lo1_b

        mov dl, [current_operand + rcx]
        mov [operand_1 + rcx] , dl
        inc rcx
        jmp lo1_loop
    
    lo1_b:
    mov rcx, [current_operand_len]
    mov [operand_1_len], rcx
    pop rdx
    pop rcx
    ret

load_operand_2:
    push rcx
    push rdx

    xor rcx, rcx
    lo2_loop:
        cmp rcx, 16
        jae lo2_b

        mov dl, [current_operand + rcx]
        mov [operand_2 + rcx] , dl
        inc rcx
        jmp lo2_loop
    
    lo2_b:
    mov rcx, [current_operand_len]
    mov [operand_2_len], rcx
    pop rdx
    pop rcx
    ret

reset_answer:
    push rcx

    xor rcx, rcx
    ra_loop:
        cmp cx, [answer_len]
        jae ra_b

        mov byte [answer + rcx], 0
        inc rcx

    ra_b:
    mov dword [answer_len], 0
    pop rcx
    ret

store_rax_in_answer:
    push rax
    push rcx
    push rdx

    test rax, rax
    jns decode
    inc dword [answer_len]
    mov byte [answer], '-'
    neg rax

    decode:
    xor rdx, rdx
    mov rbx, 10
    div bx
    test rax, rax
    je .sria_break
    call store_rax_in_answer
  .sria_break:
    add dl, '0'

    xor rbx, rbx
    mov bx, [answer_len]
    mov [answer + rbx], dl
    inc dword [answer_len]

    pop rdx
    pop rcx
    pop rax
    ret

stoi:
    push rbx
    push rcx
    push rdx

    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx

    mov cl, 10
    xor r15b, r15b
    cmp byte[rsi], '+'
    je sign
    cmp byte[rsi], '-'
    jne for
    sign:
        mov r15b, [rsi]
        dec r12
        inc rsi
    for:
        xor dl, dl
        mov bl, [rsi]
        sub bl, '0'
        mul rcx
        add rax, rbx
        inc rsi
        dec r12
        cmp r12, 0
        ja for
    cmp r15b, '-'
    jne end
    neg rax

    end:
    pop rdx
    pop rcx
    pop rbx
    ret

parse_operand_2_to_r10:
    mov rsi, operand_2
    xor r12, r12
    mov r12d, [operand_2_len]
    call stoi
    mov r10, rax
    ret

parse_operand_1_to_rax:
    mov rsi, operand_1
    xor r12, r12
    mov r12d, [operand_1_len]
    call stoi
    ret

mul_rax_by_r10:
    push rdx

    mov rdx, rax
    xor rax, rax
    mrbr_loop:
        cmp r10, 0
        jbe mrbr_end

        add rax, rdx
        dec r10
        jmp mrbr_loop
    
    mrbr_end:
    pop rdx
    ret

div_rax_by_r10:
    push rdx
    push rax

    mov rdx, rax
    xor rax, rax

    test rdx, rdx
    jns drbr_loop
    neg rdx
    drbr_loop:
        cmp rdx, r10
        jb drbr_break

        sub rdx, r10
        inc rax
        jmp drbr_loop
    
    drbr_break:
    pop rdx
    test rdx, rdx
    jns drbr_end
    neg rax
    
    drbr_end:
    pop rdx
    ret

calculate_answer_in_rax:
    call parse_operand_2_to_r10
    call parse_operand_1_to_rax

    cmp byte [current_operation], '*'
    jne cair_div
    call mul_rax_by_r10
    ret

    cair_div:
    cmp byte [current_operation], '/'
    jne cair_sum
    call div_rax_by_r10 
    ret

    cair_sum:
    cmp byte [current_operation], '+'
    jne cair_sub
    add rax, r10
    ret

    cair_sub:
    cmp byte [current_operation], '-'
    jne cair_b
    sub rax, r10
    ret

    cair_b:
    ret

calculate_answer:
    call calculate_answer_in_rax
    call reset_answer
    call store_rax_in_answer
    ret

rebuild_expression:
    push rdx

    mov r13, 1 ; operator_len
    add r13d, [operand_1_len]
    add r13d, [operand_2_len]
    sub [expression_len], r13d
    sub rcx, r13

    xor r14, r14
    re_loop:
        cmp r14d, [answer_len]
        jae p2

        mov dl, [answer + r14]
        mov [expression + rcx], dl
        inc rcx
        inc r14
        jmp re_loop
    
    p2:
    add [expression_len], r14d
    sub r13, r14
    push rcx
    re_loop2:
        cmp cx, [expression_len]
        jae re_end

        mov r9b, [expression + rcx + r13]
        mov [expression + rcx], r9b
        inc rcx
        jmp re_loop2
    
    re_end:
    pop rcx
    pop rdx
    ret

store_answer_in_current_operand:
    push rdx
    push rcx

    mov dx, [answer_len]
    mov [current_operand_len], dx

    xor rcx, rcx
    saico_loop:
        cmp cx, [answer_len]
        jae saico_end

        mov dl, [answer + rcx]
        mov [current_operand + rcx] , dl
        inc rcx

        jmp saico_loop

    saico_end:
    pop rcx
    pop rdx
    ret

do_mul_div_calculations:
    xor rcx, rcx
    dmdc_traverse:
        cmp cx, [expression_len]
        jae dmdc_b

        mov dl, [expression + rcx]
        cmp dl, '+'
        je dmdc_next
        cmp dl, '-'
        je dmdc_next

        cmp dl, '*'
        je dmdc_calculate
        cmp dl, '/'
        je dmdc_calculate

        call fill_current_operand
        jmp dmdc_traverse

        dmdc_calculate:
        mov [current_operation], dl
        call load_operand_1
        inc rcx
        call fill_current_operand
        call load_operand_2
        call calculate_answer
        call store_answer_in_current_operand
        call rebuild_expression
        jmp dmdc_traverse

        dmdc_next:
        inc rcx
        jmp dmdc_traverse
    
    dmdc_b:
    ret

do_sum_sub_calculations:
    xor rcx, rcx
    dssc_traverse:
        cmp cx, [expression_len]
        jae dssc_b

        mov dl, [expression + rcx]
        cmp dl, '*'
        je dssc_next
        cmp dl, '/'
        je dssc_next

        cmp dl, '+'
        je dssc_calculate
        cmp dl, '-'
        je dssc_calculate

        call fill_current_operand
        jmp dssc_traverse

        dssc_calculate:
        mov [current_operation], dl
        call load_operand_1
        inc rcx
        call fill_current_operand
        call load_operand_2
        call calculate_answer
        call store_answer_in_current_operand
        call rebuild_expression
        jmp dssc_traverse

        dssc_next:
        inc rcx
        jmp dssc_traverse
    
    dssc_b:
    ret

print_expression:
    mov rax, 4
    mov rbx, 1
    mov rcx, expression
    mov rdx, [expression_len]
    int 80h
    ret

append_zero_if_neccessary:
    push rdx
    push rcx
    
    cmp byte [expression], '-'
    je shift_expression

    cmp byte [expression], '-'
    je shift_expression

    jmp azin_end

    shift_expression:
    mov r11d, [expression_len]
    inc dword [expression_len]
    mov cx, [expression_len]
    azin_loop:
        mov dl, [expression + r11]
        mov [expression + rcx], dl
        cmp r11, 0
        je azin_break
        dec r11
        dec rcx
        jmp azin_loop
    
    azin_break:
    mov byte [expression], '0'

    azin_end:
    pop rcx
    pop rdx
    ret
    
_start:
    do:
        call read_user_input
        call append_previous_result_user_input
        call append_zero_if_neccessary
        call do_mul_div_calculations
        call do_sum_sub_calculations
        call print_expression
        jmp do
