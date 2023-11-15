.section .data
	prompt:
	.asciz	"Program to calculate Greatest Common Divisor (GCD) of two integers.\nEnter two integers:\n"

	A:
	.int	0

	B:
	.int	0

	input_A_B:
	.asciz	"%d %d"

	output_gcd:
	.asciz	"%d"

.section .text
	.globl _start
_start:
	mov $prompt, %rsi
	mov stderr, %rdi
	call fprintf

	mov $B, %rdx
	mov $A, %rsi
	mov $input_A_B, %rdi
	call scanf

check_A_negative:
	cmpl $0, A
	jge check_B_negative
	negl A

check_B_negative:
	cmpl $0, B
	jge done_negative_checks
	negl B

done_negative_checks:
while_B_is_not_zero:
	cmpl $0, B
	je _done

	# t = b; b = a % b; a = t
	mov B, %r8d
	mov A, %eax
	# https://stackoverflow.com/a/36465045/13680015
	cdq
	idiv %r8d
	mov %edx, B
	mov %r8d, A

	jmp while_B_is_not_zero

_done:
	mov A, %rsi
	mov $output_gcd, %rdi
	call printf

_exit:
	# Write a newline and exit.
	mov $10, %rdi
	call putchar
	xor %rdi, %rdi
	call exit

