section .data
    n dw 0

section .bss
    numbers resq 1000
    input resb 132

section .text
    global _start

string_to_int:
    xor ebx, ebx
  next_digit:
    movzx eax, byte[esi]
    inc esi
    sub al, '0'
    imul ebx, 10
    add ebx, eax
    loop next_digit
    mov eax, ebx
    
    ret

read_n:
    mov edi, input
    
    mov eax, 3
    mov ebx, 0
    mov ecx, edi
    mov edx, 8
    int 80h
    
    mov ecx, eax
    mov esi, edi
    dec ecx
    call string_to_int
    mov [n], eax
    
    ret

read_numbers:
    ret

array_fmean:
    enter 0, 0
    mov edx, [ebp + 8]
    movzx ecx, byte[ebp + 12]
    
    fldz
  add_loop:
    fadd qword[edx + ecx*8]
    loop add_loop
    fild qword[n]
    fdivp
    leave
    ret

_start:
;    mov ebp, esp; for correct debugging
    
    call read_n
    call read_numbers
    
    mov edx, numbers
    mov ecx, [n]
    
    push word[n]
    push numbers
    
    call array_fmean; mean on top of stack
 

exit:
    mov eax, 1
    mov ebx, 0
    int 80h