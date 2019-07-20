%include '../commons.asm'

section .data
    in_dir db 'original',0
    out_dir db 'modified',0
    getdents_bytes_read dq 0

    filename db 'original/sample.bmp',0
    outfile db 'modified/light_sample.bmp',0

    datasize dq 0
    bufsize  equ 10000000
    headsize equ 54
    darken_degree_bytes db 20,20,20,20,20,20,20,20
    darken_degree equ 20

section .bss
    buf resb 10000000
    head resb 54
    file_descriptor resb 1
    filenames resb 2048

section .text
  global _start

read_filenames:
    mov rax, SYS_OPEN
    mov rdi, in_dir
    xor rsi, rsi
    mov rdx, RWX_PERM
    syscall

    mov rdi, rax
    mov rsi, filenames
    mov rdx, 0x3210
    mov rax, SYS_GETDENTS
    syscall

    mov [getdents_bytes_read], rax
    ret

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
    movq mm1, [darken_degree_bytes]
    mov rcx, qword [datasize]
  image:
    dec rcx
    cmp rcx, 8
    jb normal_add
    movq mm0, [buf + rcx]
    paddusb mm0, mm1
    movq [buf + rcx], mm0
    sub rcx, 6
    loop image
  normal_add:
    mov dl, byte [buf + rcx]
    add [buf + rcx], byte darken_degree
    cmp [buf + rcx], dl
    ja cont
    mov [buf + rcx], byte 255
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

find_filename:
    mov rdi, filename ;debug
    mov rsi, filenames
    dec rsi
  next_bmp:
    inc rsi
    cmp [rsi], byte 0
    loope next_bmp
    cmp [rsi], byte '.'
    loope next_bmp

    xor rdx, rdx
    next_chr:
      cmp [rsi], byte 0
      je out
      inc rdx
      inc rsi
      dec rcx
      movzx rbx, byte[rsi]
      mov [filename + rdx], rbx
      jmp next_chr
      out:
      mov [filename + rdx + 1], byte 0
    loop next_bmp
    ret

_start:
    call read_filenames

    mov rcx, [getdents_bytes_read]
  next_img:
    call find_filename
    call read_header
    call read_image_data
    call darken_image
    call create_new_image
    loop next_img

exit:
    mov rax, SYS_EXIT
    mov rdi, EXIT_SUCCESS
    syscall
