section .data
    nums db 1, 7, 0, 4, 5, 6, 9,
    datalen equ $-nums

section .text
    global _start

_start:
    mov rcx, datalen
    dec rcx
    
    sort_outer:
        mov rdx, datalen
        dec rdx
        
        mov rax, rcx
        sub rax, datalen
        neg rax
        sort_inner:
            mov bl, [nums + rdx - 1]
            cmp bl, [nums + rdx]
            jae skip_swap
        swap:
            mov bh, [nums + rdx]
            mov [nums + rdx], bl
            mov [nums + rdx - 1], bh
        skip_swap:
            dec rdx
            cmp rdx, rax
            jae sort_inner
        dec rcx
        cmp rcx, 0
        ja sort_outer

exit:
    mov eax, 1
    mov ebx, 0
    int 80h