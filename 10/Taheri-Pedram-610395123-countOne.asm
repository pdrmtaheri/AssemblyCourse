section .data
section .text
    global _start
    
count_ones_of_rax:
    xor bl, bl
    count_bit:
        shr rax, 1
        jnc no_inc
        inc bl
      no_inc:
        cmp rax, 0
        jne count_bit
    ret
  
_start:
    mov rax, 7

    call count_ones_of_rax

exit:
    mov eax, 1
    mov ebx, 2
    int 80h