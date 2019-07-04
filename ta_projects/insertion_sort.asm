section .data
    n dw 0
    ten dd 10

section .bss
    numbers resd 1000
    numbers_buffer resb 10000
    buffer resb 10
    
    dummy resb 1

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
    mov edi, buffer
        
    mov eax, 3
    mov ebx, 0
    mov ecx, edi
    mov edx, 10
    int 80h
    
    mov ecx, eax
    mov esi, edi
    dec ecx
    call string_to_int
    
    ret
    
read_numbers:
    mov edi, numbers_buffer
        
    mov eax, 3
    mov ebx, 0
    mov ecx, edi
    mov edx, 10000
    int 80h
    
    mov ecx, eax
    mov esi, edi
    dec ecx
    xor ebx, ebx
    movzx edx, word[n]
      next_d:
        movzx eax, byte[esi]
        inc esi
        cmp al, ' '
        je break
        cmp al, 10
        je re
        sub al, '0'
        imul ebx, 10
        add ebx, eax
        jmp next_d
      break:
      mov [numbers + edx*4 - 4], ebx
      xor ebx, ebx
      dec edx
      jmp next_d
    re:
    mov [numbers + edx*4 - 4], ebx
    ret

read_input:
    call read_int
    mov [n], eax
    mov ecx, eax
    
    call read_numbers
    
    ret
    
sort_numbers:
    movzx ecx, word[n]
    cmp ecx, 1
    jbe return
    mov esi, numbers
    dec ecx

    out_loop:
        dec ecx
        mov eax, ecx
        
        mov ebx, [numbers + eax*4]
        in_loop:
            inc eax
            cmp [numbers + eax*4], ebx
            jb continue
            mov edx, [numbers + eax*4]
            mov [numbers + eax*4 - 4], edx
            jmp in_loop
        continue:
        mov [numbers + eax*4 - 4], ebx
        inc ecx
        loop out_loop
  return:
    ret

print_eax:
    push eax
    push edx
    xor edx, edx
    mov ebx, 10
    div ebx
    test eax, eax
    je .l1
    call print_eax
  .l1:
    add edx, '0'
    mov [dummy], edx
    mov eax, 4
    mov ebx, 1
    mov ecx, dummy
    mov edx, 1
    int 80h
    
    pop edx
    pop eax
    ret

print_result:
    mov ecx, [n]
    conv:
        mov eax, [numbers + ecx*4 - 4]
        push ecx
        call print_eax
        mov [dummy], byte ' '
        mov eax, 4
        mov ebx, 1
        mov ecx, dummy
        mov edx, 1
        int 80h
        pop ecx
        loop conv
    retn
    
_start:
    call read_input
    call sort_numbers
  
    call print_result
    
exit:
    mov eax, 1
    mov ebx, 0
    int 80h