%include '../commons.asm'

section .data
    filename db 'original/sample.bmp',0
    outfile db 'modified/light_sample.bmp',0
    datasize dq 0
    bufsize  equ 10000000
    headsize equ 54
    darken_degree equ 20

section .bss
    buf resb 10000000
    head resb 54
    file_descriptor resb 1

section .text
  global _start

read_header:
    mov rdi, [file_descriptor]
    mov rax, SYS_READ
    mov rsi, head
    mov rdx, headsize
    syscall

    ret

read_image_data:
    mov rdi, [file_descriptor]
    mov rax, SYS_READ
    mov rsi, buf
    mov rdx, bufsize
    syscall
    mov [datasize], rax

    ret

darken_image:
    mov rcx, qword [datasize]
  image:
    dec rcx
    mov dl, byte [buf + rcx]
    add [buf + rcx], byte darken_degree
    cmp [buf + rcx], dl
    ja cont
    mov [buf + rcx], byte BYTE_MAX
    cont:
    inc rcx
  loop image
    ret

create_new_image:
    mov rax, SYS_CREAT
    mov rdi, outfile
    mov rsi, RWX_PERM
    syscall
    push rax

    mov rdx, headsize
    mov rsi, head
    mov rdi, rax
    mov rax, SYS_WRITE
    syscall

    pop rax
    mov rdx, datasize
    mov rsi, buf
    mov rdi, rax
    mov rax, SYS_WRITE
    syscall

    ret


_start:
    mov rax, SYS_OPEN
    mov rdi, filename
    mov rsi, RW_CREAT
    mov rdx, READONLY_PERM
    syscall

    mov [file_descriptor], rax

    call read_header
    call read_image_data
    call darken_image
    call create_new_image

exit:
    mov rax, SYS_EXIT
    mov rdi, EXIT_SUCCESS
    syscall
