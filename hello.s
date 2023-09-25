.section .data
	message: .asciz "Hello World\n"

.section .text
	.global __start

__start:
	li $v0, 4004
	li $a0, 2
	la $a1, message
	li $a2, 13
	syscall

	li $v0, 4001
	li $a0, 13
	syscall

