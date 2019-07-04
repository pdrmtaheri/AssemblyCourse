section .data
    n dd 0
    nums times 8 db 0
    sum dd 0

section .bss
    numbers resd 1000

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
    
read_int:
    mov edi, num
    
    mov eax, 3
    mov ebx, 0
    mov ecx, edi
    mov edx, 8
    int 80h
    
    mov ecx, eax
    mov esi, edi
    dec ecx
    call string_to_int
    
    ret

calculate_mean:
    call read_int; reads a str value and converts it to integer in eax    
    mov [n], eax
    xor ebx, ebx
  summation:
    call read_int
    add [sum], eax
    dec byte[n]
    cmp byte[n], 0
    ja summation
    
    mov ebx, dword[sum]
    
exit:
    mov eax, 1
    mov ebx, 0
    int 80h