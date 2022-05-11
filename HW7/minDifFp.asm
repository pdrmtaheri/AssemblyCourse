section .data
    num                 dd    12.23
    decimal_precision   dd    100000  ; print up to 5 decimal places
    max_size            equ   1000
    ten                 dd    10
    min_diff            dd    -1

section .bss
    control       resw  1
    int_part      resb  max_size
    decimal_part  resb  max_size

    numbers_count  resw  1
    numbers        resd  100
    number1        resd  1
    number2        resd  1

    input_buffer  resb  max_size
    input_len     resw  1

    dummy  resb  1

section .text
    global _start

_start:
    call read_numbers
    call find_minimum_diff

    mov byte [dummy], 10
    call print_dummy_char

    call print_number1
    call print_number2

exit:
    mov rax, 1
    mov rbx, 0
    int 80h

read_numbers:
    call read_numbers_count

    xor cx, cx
    rn_loop:
        cmp cx, [numbers_count]
        jge rn_break

        push rcx
        call read_number
        pop rcx
        fstp dword [numbers + rcx*4]

        inc cx
        jmp rn_loop

    rn_break:
    ret

find_minimum_diff:
    xor rcx, rcx
    fmd_outer_loop:
        xor rdx, rdx
        cmp cx, [numbers_count]
        jge fmd_break

        fmd_inner_loop:
            cmp dx, cx
            je fmd_inner_loop_next

            cmp dx, [numbers_count]
            jge fmd_outer_break

            call diff_rcx_rdx

            fmd_inner_loop_next:
            inc dx
            jmp fmd_inner_loop

        fmd_outer_break:
        inc cx
        jmp fmd_outer_loop

    fmd_break:
    ret

diff_rcx_rdx:
    fld dword [numbers + rcx*4]
    fld dword [numbers + rdx*4]
    fsubp
    fabs

    cmp dword [min_diff], -1
    jne drr_cont
    mov r9d, [numbers + rcx*4]
    mov [number1], r9d
    mov r9d, [numbers + rdx*4]
    mov [number2], r9d
    fstp dword [min_diff]
    ret

    drr_cont:
    fld dword [min_diff]
    fcomip
    jb drr_end
    mov r9d, [numbers + rcx*4]
    mov [number1], r9d
    mov r9d, [numbers + rdx*4]
    mov [number2], r9d
    fstp dword [min_diff]

    drr_end:
    ret

read_number:
    call read_to_buffer
    call stof

    ret

read_numbers_count:
    call read_to_buffer

    mov rsi, input_buffer
    call stoi

    mov [numbers_count], ax
    ret

stof:      ; converts input_buffer to floating point
    xor rcx, rcx
    stof_iterate:
        cmp byte [input_buffer + rcx], '.'
        je stof_found_dot

        cmp cx, [input_len]
        je stof_no_dot

        inc rcx
        jmp stof_iterate

    stof_found_dot:
    push word [input_len]
    mov [input_len], cx
    mov rsi, input_buffer
    call stoi
    push rax
    fild dword [rsp]
    pop rax

    mov rsi, input_buffer
    inc rcx
    add rsi, rcx

    pop dx
    sub dx, cx
    mov [input_len], dx
    call stoi
    push rax
    fild dword [rsp]
    pop rax

    mov cx, [input_len]
    stof_div_loop:
        cmp cx, 0
        jle stof_end
        fild dword [ten]
        fxch

        fdivrp
        dec cx
        jmp stof_div_loop

    stof_end:
    faddp
    ret

    stof_no_dot:
    mov rsi, input_buffer
    call stoi
    mov [num], eax
    fild dword [num]

    ret

stoi:      ; converts rsi to integer
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx

    stoi_loop:
        cmp cx, [input_len]
        jge stoi_break

        mov bl, [rsi + rcx]
        sub rbx, '0'
        mov dx, 10
        mul dx
        add rax, rbx
        inc rcx 
        jmp stoi_loop
    
    stoi_break:
    ret

read_to_buffer:
    mov rax, 3
    mov rbx, 0
    mov rcx, input_buffer
    mov dx, max_size
    int 80h

    dec ax
    mov [input_len], ax
    ret

print_number1:
    fld dword [number1]
    fstp dword [num]
    call print_float
    ret

print_number2:
    fld dword [number2]
    fstp dword [num]
    call print_float
    ret

print_float:
    ; -------------------------------------------------------------------------
    ;| In order to convert a floating point number into a string, we will sepa-|
    ;| rate  the  integer  and  decimal  parts  and  then  put  them  together.|
    ; -------------------------------------------------------------------------
    enter 0, 0

    ; By setting rounding control to truncate, we can ignore the  decimal  part
    ; of any floating number. So 1.95 will be loaded as 1.00 and hence, we have
    ; the integer part of our floating point number in hand.
    fstcw word[control]  ; store control register
    mov ax, [control]
    or ax, 0x0c00  ; set rounding control to truncate
    mov [control], ax
    fldcw word[control]  ; set control register to the new control we defined

    ; now if we load a number into FPU unit, the decimal part is ignored.
    fld dword[num]  ; ST0 := truncated number stored in num
    fistp dword[int_part]  ; store int from the real truncated number

    ; To get the decimal part, we need to remove  the  truncate  condition  and
    ; subtract the real number from the integer part we calculated  previously.
    finit  ; initializes the FPU, i.e. resets the whole thing
    fld dword[num]  ; ST0 := num
    fild dword[int_part]  ; ST1 := ST0, ST0 := int_part
    fsub                  ; ST0 := ST1 - ST0
    fild dword[decimal_precision]  ; ST1 := ST0, ST0 := decimal_precision
    fmul                  ; ST0 := ST1 * ST0
    fistp dword[decimal_part] ; store the decimal part as an integer

    mov rax, [int_part]
    call print_integer

    mov byte [dummy], '.'
    call print_dummy_char

    mov rax, [decimal_part]
    call print_integer

    mov byte [dummy], 10
    call print_dummy_char

    leave
    ret

print_integer:
    push rax
    push rcx
    push rdx

    xor rdx, rdx
    mov rbx, 10
    div ebx
    test rax, rax
    je .pi_break
    call print_integer
  .pi_break:
    add dl, '0'
    mov [dummy], dl
    call print_dummy_char

    pop rdx
    pop rcx
    pop rax
    ret

print_dummy_char:
    mov rax, 4
    mov rbx, 1
    mov rcx, dummy
    mov rdx, 1
    int 80h
    ret
