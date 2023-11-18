.section .data
	N:
	.int	0

	A:
	.zero	8	# 64-bit pointer

	prompt:
	.asciz	"Program to sort an array of N real-number elements.\nInput N and the elements:\n"

	input_N:
	.asciz	"%d"

	input_one_double:
	.asciz	"%lf"

	output_one_double:
	.asciz	"%.17g "

	error_cannot_malloc:
	.asciz	"ERROR: malloc failed !\n"

.section .text
	.globl _start

_start:
	call input
	call sort
	call output

_end:
	# Write a newline and exit
	mov $10, %rdi
	call putchar
	xor %rdi, %rdi
	call exit

# Function: void input(void);
# Reads integer N and subsequent N double numbers
# as the elements of the array A.
# Also allocates A using malloc.
input:
	push %rbp
	mov %rsp, %rbp
	sub $16, %rsp

	mov $prompt, %rsi
	mov stderr, %rdi
	xor %rax, %rax
	call fprintf

	mov $N, %rsi
	mov $input_N, %rdi
	xor %rax, %rax
	call scanf

	# Allocate A
	movl N, %edi
	movsx %edi, %rdi
	shlq $3, %rdi	# %edi = N * sizeof(double) = N * 8 = N << 3
	xor %rax, %rax
	call malloc

	testq %rax, %rax
	jz input_malloc_error
	movq %rax, A

	movl $0, 0(%rsp)
	# 0(%rsp): int i
input_while_i_less_than_N:
	movl N, %eax
	movl 0(%rsp), %esi
	cmpl %eax, %esi
	jge input_end

	movsx %esi, %rsi
	shlq $3, %rsi	# multiply i by 8 = sizeof(double)
	addq A, %rsi
	mov $input_one_double, %rdi
	xor %rax, %rax
	call scanf

	incl 0(%rsp)
	jmp input_while_i_less_than_N

input_end:
	add $16, %rsp
	leave
	ret

input_malloc_error:
	mov $error_cannot_malloc, %rdi
	call printf
	mov $1, %rdi
	call exit


# Function: void output(void);
# Outputs the array A of N elements,
# then also deallocates the array.
output:
	push %rbp
	mov %rsp, %rbp
	sub $16, %rsp

	movl $0, 0(%rsp)
	# 0(%rsp): int i;

output_while_i_less_than_N:
	movl N, %eax
	cmpl %eax, 0(%rsp)
	jge output_end

	movl 0(%rsp), %edi
	movsx %edi, %rdi
	shl $3, %rdi	# multiply i by 8 = sizeof(double)
	addq A,  %rdi
	movsd 0(%rdi), %xmm0
	mov $output_one_double, %rdi
	mov $1, %rax
	call printf

	incl 0(%rsp)
	jmp output_while_i_less_than_N

output_end:
	mov A, %rdi
	call free

	add $16, %rsp
	leave
	ret


# Function: void sort(void);
# Sorts the array A containing N double elements.
sort:
# SELECTION SORT
	push %rbp
	mov %rsp, %rbp
	sub $16, %rsp

	# 0(%rsp): int i
	# 4(%rsp): int j

	movl $0, 0(%rsp)
sort_for_i_less_than_N:
	movl N, %eax
	movl 0(%rsp), %ecx
	cmpl %eax, %ecx
	jge sort_end_for_i

	incl %ecx
	movl %ecx, 4(%rsp)
sort_for_j_less_than_N:
	movl N, %eax
	cmpl %eax, 4(%rsp)
	jge sort_end_for_j

	# Load address of A[i] into %rbx
	movl 0(%rsp), %ebx
	movsx %ebx, %rbx
	shlq $3, %rbx	# multiply i by 8 = sizeof(double)
	addq A, %rbx
	# Read A[i] into %xmm0
	movsd 0(%rbx), %xmm0

	# Load address of A[j] into %rdx
	movl 4(%rsp), %edx
	movsx %edx, %rdx
	shlq $3, %rdx
	addq A, %rdx
	# Read A[j] into %xmm1
	movsd 0(%rdx), %xmm1

	comisd %xmm1, %xmm0
	ja sort_if_A_i_greater_than_A_j

sort_for_j_loop_epilogue:
	incl 4(%rsp)
	jmp sort_for_j_less_than_N

sort_if_A_i_greater_than_A_j:
	# Previously: A[i] = %xmm0, A[j] = %xmm1
	# Now:        A[i] = %xmm1, A[j] = %xmm0
	movsd %xmm1, 0(%rbx)
	movsd %xmm0, 0(%rdx)
	jmp sort_for_j_loop_epilogue

sort_end_for_j:
	incl 0(%rsp)
	jmp sort_for_i_less_than_N

sort_end_for_i:
	add $16, %rsp
	leave
	ret


