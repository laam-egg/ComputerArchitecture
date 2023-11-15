.section .data
	prompt:
	.asciz	"Program to output first N numbers of a geometric sequence\nwith starting value A and common ratio R.\n\nEnter N, A, R:\n"

	input_N_A_R:
	.asciz	"%d %lf %lf"

	output_one_double:
	.asciz	"%.17g "
	# https://stackoverflow.com/a/21162120/13680015

	N:
	.int	0

	A:
	.double	0.0

	R:
	.double	0.0

	S:
	.double	0.0


.section .text
	.globl _start

_start:
	mov $prompt, %rsi
	mov stderr, %rdi
	call fprintf

	mov $R, %rcx
	mov $A, %rdx
	mov $N, %rsi
	mov $input_N_A_R, %rdi
	call scanf

	movsd A, %xmm0
	movsd %xmm0, S
while_N_greater_than_zero:
	cmpl $0, N
	jle _exit

	movsd S, %xmm0
	mov $output_one_double, %rdi
	call printf

	movsd S, %xmm0
	mulsd R, %xmm0
	movsd %xmm0, S

	decl N
	jmp while_N_greater_than_zero

_exit:
	# Output a newline and exit
	mov $10, %rdi
	call putchar
	xor %rdi, %rdi
	call exit

