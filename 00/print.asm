print:
	mov ecx, msg 
	mov edx, msglen 
	mov eax, 4
	mov ebx, 1
	int 80h
	ret

section .data
	msg db 'Hello World!',10 
	msglen equ $-msg 

section .text
	global _start

_start:
	call print

exit:
	mov eax,1
	mov ebx,0
	int 80h


