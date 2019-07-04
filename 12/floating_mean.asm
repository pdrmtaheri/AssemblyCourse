section .data:
    nums times 5 dq 2.1,3.3,4.4,5.5,6.6
    n dq 5.0


section .text:
    global _start


array_fmean:
    enter 0, 0
    mov edx, [ebp + 8]
    mov ecx, [ebp + 12]
    
    fldz
  add_loop:
    fadd qword[edx + ecx*8]
    loop add_loop
    fild qword[n]
    fdivp
    leave
    ret


_start:
    mov ebp, esp; for correct debugging
    push 5
    push nums
    
    call array_fmean; mean on top of stack
 

exit:
    mov eax, 1
    mov ebx, 0
    int 80h