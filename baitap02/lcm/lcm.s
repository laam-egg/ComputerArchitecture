.section .data
	prompt:
	.asciz	"Program to calculate Lowest Common Multiple (LCM) of two integers.\nEnter two integers:\n"

	A:
	.int	0

	B:
	.int	0

	input_A_B:
	.asciz	"%d %d"

	output_lcm:
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

	mov A, %edi
	mov B, %esi
_check_A_zero_or_negative:
	cmpl $0, %edi
	je _case_A_or_B_is_zero
	jg _check_B_zero_or_negative
	neg %edi

_check_B_zero_or_negative:
	cmpl $0, %esi
	je _case_A_or_B_is_zero
	jg _done_A_and_B_checks
	neg %esi

_done_A_and_B_checks:
	mov %edi, %eax
	mul %esi
	mov %eax, %ebx
	# Now, %ebx holds the result of A * B,
	# %edi holds A, %esi holds B
	xor %rax, %rax
	call gcd
	# and %eax holds gcd(A, B)

	mov %eax, %r8d
	mov %ebx, %eax
	cdq
	idiv %r8d

	# Now %eax holds lcm(A, B)
	xor %rsi, %rsi
	mov %eax, %esi
	mov $output_lcm, %rdi
	call printf

_exit:
	# Write a newline and exit.
	mov $10, %rdi
	call putchar
	xor %rdi, %rdi
	call exit
	# At this point, the program has terminated.

_case_A_or_B_is_zero:
	# Print zero as the result
	mov $48, %rdi
	call putchar
	jmp _exit

# Function: gcd(int %edi, int %esi) => int %eax
# Returns the Greatest Common Divisor of two given integers,
# which must both be positive !!!
gcd:
	push %rbp
	mov %rsp, %rbp
	sub $8, %rsp
	movl %esi, 4(%rsp)
	movl %edi, 0(%rsp)
	# We call %edi the X, %esi the Y.

gcd_while_Y_is_not_zero:
	cmpl $0, 4(%rsp)
	je gcd_Y_is_finally_zero

	# t = Y; Y = X % Y; X = t
	movl 4(%rsp), %r8d
	movl 0(%rsp), %eax
	cdq
	idiv %r8d
	mov %edx, 4(%rsp)
	mov %r8d, 0(%rsp)

	jmp gcd_while_Y_is_not_zero

gcd_Y_is_finally_zero:
	movl 0(%rsp), %eax
	add $8, %rsp
	pop %rbp
	ret

