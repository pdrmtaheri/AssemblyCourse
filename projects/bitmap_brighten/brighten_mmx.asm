section .data
    filename db 'sample.bmp',0
    outfile db 'dark_sample.bmp',0
    datasize dd 0
    bufsize  equ 10000000
    headsize equ 54
    darken_degree_bytes db 20,20,20,20,20,20,20,20
    darken_degree equ 20

section .bss
    buf resb 10000000
    head resb 54
    file_descriptor resb 1

section .text
  global _start

read_header:
    mov ebx, [file_descriptor]
    mov eax, 3
    mov ecx, head
    mov edx, 54
    int 80h

    ret

read_image_data:
    mov ebx, [file_descriptor]
    mov eax, 3
    mov ecx, buf
    mov edx, bufsize
    int 80h
    mov [datasize], eax

    ret

darken_image:
    movq mm1, [darken_degree_bytes]
    mov ecx, dword [datasize]
  image:
    dec ecx
    cmp ecx, 8
    jb normal_add
    movq mm0, [buf + ecx]
    psubusb mm0, mm1
    movq [buf + ecx], mm0
    sub ecx, 6
    loop image
  normal_add:
    mov dl, byte [buf + ecx]
    sub [buf + ecx], byte darken_degree
    cmp [buf + ecx], dl
    jb cont
    mov [buf + ecx], byte 0
    cont:
    inc ecx
  loop image
    ret

create_new_image:
    mov  eax, 8
    mov  ebx, outfile
    mov  ecx, 0777
    int  80h
    push eax

    mov edx, headsize
    mov ecx, head
    mov ebx, eax
    mov eax,4
    int 80h

    pop eax
    mov edx, datasize
    mov ecx, buf
    mov ebx, eax
    mov eax,4
    int 80h

    ret

_start:
    mov eax,  5
    mov ebx, filename
    mov ecx,  0
    int 80h

    mov [file_descriptor], eax

    call read_header
    call read_image_data
    call darken_image
    call create_new_image

exit:
    mov eax, 1
    mov ebx, 0
    int 80h
