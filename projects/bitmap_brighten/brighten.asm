section .data
    filename db 'sample.bmp',0
    outfile db 'dark_sample.bmp',0
    datasize dd 0
    bufsize  equ 10000000
    headsize equ 54
    darken_degree equ 20

section .bss
    buf resb 10000000
    head resb 54
    file_descriptor resb 1

section  .text              ; declaring our .text segment
  global  _start            ; telling where program execution should start

read_header:
    mov     ebx,  [file_descriptor]       ;   file_descriptor,
    mov     eax,  3         ; read(
    mov     ecx,  head       ;   *buf,
    mov     edx,  54;   *bufsize
    int 80h

    ret

read_image_data:
    mov     ebx,  [file_descriptor]       ;   file_descriptor,
    mov     eax,  3         ; read(
    mov     ecx,  buf       ;   *buf,
    mov     edx,  bufsize;   *bufsize
    int     80h             ; );
    mov [datasize], eax

    ret

darken_image:
    mov ecx, dword [datasize]
  image:
    dec ecx
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

    mov edx, headsize          ;number of bytes
    mov ecx, head         ;message to write
    mov ebx, eax    ;file descriptor 
    mov eax,4            ;system call number (sys_write)
    int 80h             ;call kernel

    pop eax
    mov edx, datasize          ;number of bytes
    mov ecx, buf         ;message to write
    mov ebx, eax    ;file descriptor 
    mov eax,4            ;system call number (sys_write)
    int 80h             ;call kernel

    ret


_start:
  ; open the file
    mov   eax,  5           ; open(
    mov   ebx, filename
    mov   ecx,  0           ;   read-only mode
    int   80h               ; );

    mov [file_descriptor], eax

    call read_header
    call read_image_data
    call darken_image
    call create_new_image

exit:
    mov   eax,  1           ; exit(
    mov   ebx,  0           ;   0
    int   80h               ; );
