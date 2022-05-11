section .data
section .text
    global _start

reverse_rax_r8:
    do:
        mov rbx, 63
        bsf rcx, rax
        jz end1
        sub rbx, rcx
        bts r8, rbx
        btc rax, rcx
        jmp do
    end1:
        ret

reverse_rdx_r9:
    do2:
        mov rbx, 63
        bsf rcx, rdx
        jz end2
        sub rbx, rcx
        bts r9, rbx
        btc rdx, rcx
        jmp do2
    end2:
        ret

reverse_rdxrax_r8r9:
    call reverse_rdx_r9
    call reverse_rax_r8
    ret

_start:
    mov rdx, 0xFFFFFFFFFFFFFFFE ; yields 0x7FFFFFFFFFFFFFFF in r9
    mov rax, 0x000F00000000E000 ; yields 0x000700000000F000 in r8
    call reverse_rdxrax_r8r9

exit:
    mov rax, 1
    mov rbx, 2
    int 80h