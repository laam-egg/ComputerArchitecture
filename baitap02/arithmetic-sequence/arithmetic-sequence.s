.section .data
	prompt:
	.asciz	"Program to output the first N numbers of arithmetic sequence\nwith initial element U and the common difference D.\nEnter N, U, D:\n"

	N:
	.int	0

	U:
	.double	0.0

	D:
	.double 0.0

	output_one_double:
	.asciz	"%.17g "

	input_N_U_D:
	.asciz	"%d %lf %lf"

	S:
	.double	0.0

.section .text
	.globl _start
_start:
	mov $prompt, %rsi
	mov stderr, %rdi
	call fprintf

	mov $D, %rcx
	mov $U, %rdx
	mov $N, %rsi
	mov $input_N_U_D, %rdi
	call scanf

	movsd U, %xmm0
	movsd %xmm0, S

while_N_greater_than_zero:
	cmpl $0, N
	jle _exit

	movsd S, %xmm0
	mov $output_one_double, %rdi
	call printf

	movsd S, %xmm0
	addsd D, %xmm0
	movsd %xmm0, S

	decl N
	jmp while_N_greater_than_zero

_exit:
	# Print one newline and exit
	mov $10, %rdi
	call putchar
	xor %rdi, %rdi
	call exit

