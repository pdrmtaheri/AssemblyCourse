section .data
    data db 1, 2, 3, 4, 5, 6, 7
    len equ $-data
section .text
    global _start

count_ones_esi_to_edi:
    mov ecx, esi
    xor eax, eax
    count_all:
        mov bl, [ecx]
        count_byte:
            shr bl, 1
            jnc no_inc
            inc eax
          no_inc:
            cmp bl, 0
            ja count_byte
        inc ecx
        cmp ecx, edi
        jb count_all
    ret
    
_start:
    mov esi, data
    lea edi, [data + len]
    call count_ones_esi_to_edi

exit:
    mov eax, 1
    mov ebx, 2
    int 80h