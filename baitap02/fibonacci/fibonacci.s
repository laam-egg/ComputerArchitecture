.section .data
	prompt:
	.asciz "Program to output the first N Fibonacci numbers\nEnter n: "
	
	inputFormat:
	.asciz	"%d"

	outputOneNumberFormat:
	.asciz	"%d "
	
	N:
	.int	0

	prev2:
	.int	0

	prev1:
	.int	1

.section .text
	.globl _start
_start:
	mov $prompt, %rsi
	mov stderr, %rdi
	call fprintf

	mov $inputFormat, %rdi
	mov $N, %rsi
	call scanf

	cmpl $0, N
	jle _exit

	# The next 4 lines: output "0 " (0 with a space)
	mov $48, %rdi
	call putchar
	mov $32, %rdi
	call putchar

	cmpl $1, N
	jne case_N_greater_than_or_equal_2
	jmp _exit

case_N_greater_than_or_equal_2:
	mov N, %r10
	sub $2, %r10
	mov %r10, N
while_N_greater_than_or_equal_0:
	cmpl $0, N
	jl _exit
	mov prev1, %rsi
	mov $outputOneNumberFormat, %rdi
	call printf
	
	# t = prev2; prev2 = prev1; prev1 += t
	mov prev2, %r8
	mov prev1, %r9
	mov %r9, prev2
	add %r8, %r9
	mov %r9, prev1

	decl N
	jmp while_N_greater_than_or_equal_0

_exit:
	# Print out a newline
	mov $10, %rdi
	call putchar
	# Exit gracefully
	xor %rdi, %rdi
	call exit

