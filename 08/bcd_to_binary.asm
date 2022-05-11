; Assembly Excersice #2: 3-Digit BCD to Binary conversion
; Pedram Taheri 610395123

section .text
    global _start

_start:
    mov ax, 1347    ; must yield 543

    xor cx, cx
    xor dx, dx

    mov bx, 16      ; first bcd digit
    div bx
    add cx, dx

    xor dx, dx      ; second bcd digit
    div bx
    mov bx, ax
    mov ax, dx
    mov dx, 10
    mul dx
    add cx, ax
    mov ax, bx

    mov dx, 100     ; third bcd digit
    mul dx
    add ax, cx      ; result in ax

exit:
    mov rax, 1
    mov rbx, 0
    int 80h
