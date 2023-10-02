.data
	i:	.word	0
	N:	.word	100
	sum:	.word	0
	prompt:	.asciiz "Input element #"

.text
main:
loop:
	lw $t0, i
	beq $t0, 10, end_loop

	jal input_and_process_A_i

	lw $t0, i
	addi $t0, $t0, 1
	sw $t0, i
	j loop

end_loop:
	li $v0, 1
	lw $a0, sum
	syscall

	li $v0, 11
	li $a0, 10 # linefeed
	syscall

end_main:
	li $v0, 10
	syscall

# Functions

input_and_process_A_i:
	# Print: Input element #{i}:
	li $v0, 4
	la $a0, prompt
	syscall

	li $v0, 1
	lw $a0, i
	syscall

	li $v0, 11
	li $a0, 58 # colon ':'
	syscall

	li $v0, 11
	li $a0, 32 # space ' '
	syscall

	# Read A[i]
	li $v0, 5
	syscall

	# Accumulate to sum
	lw $t0, sum
	add $t0, $t0, $v0
	sw $t0, sum

	jr $ra
