section .data
    string_len dw 0
    pattern_len dw 0
    
    max_string_len equ 5000
    max_pattern_len equ 1000

section .bss
    string resb max_string_len
    pattern resb max_pattern_len
    
    dummy resb 1

section .text
    global _start

%macro read_str 2
    mov eax, 3
    mov ebx, 0
    mov ecx, %1
      tt%2:
    mov edx, %2
    int 80h    
%endmacro

count_occurences:
    mov esi, string
    mov edi, pattern
    xor edx, edx
    
    movzx ecx, word[string_len]
    for:
        mov eax, esi
        mov ebx, edi
        push ecx
        rep cmpsb
        pop ecx
        sub edi, ebx
        cmp di, [pattern_len]
        jbe cont
        inc edx
      cont:
        mov edi, pattern
        inc eax
        mov esi, eax
        loop for
    ret

print_eax:
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
    
    ret

_start:
    read_str string, max_string_len
    mov [string_len], ax
    
    read_str pattern, max_pattern_len
    dec ax                              ; compensate for the \n
    mov [pattern_len], ax
    
    call count_occurences               ; result in edx
    mov eax, edx
    call print_eax
   
exit:
    mov eax, 1
    mov ebx, 0
    int 80h