.data
	prompt:		.asciiz	"Input element #"
	prompt2:		.asciiz ": "
	N:		.word	100 # 100 integers
	A:		.space	400 # 4 bytes * 100 integers
	response:	.asciiz "The sum of the inputted elements are: "

.text
#################
## ENTRY POINT ##
#################

_start:
	jal input
	jal output
	
	li $v0, 10
	syscall

######################
## FUNCTION: output ##
######################

output:
	li $s0, 0	# i
	li $s2, 0	# sum
	la $t0, A
	la $s3, N
	lw $s3, 0($s3)	# N

output_loop:
	lw $s1, 0($t0)
	add $s2, $s2, $s1
	
	addi $t0, $t0, 4
	addi $s0, $s0, 1
	bne $s0, $s3, output_loop
	
output_loop_end:
	li $v0, 4
	la $a0, response
	syscall
	
	li $v0, 1
	move $a0, $s2
	syscall
	
	jr $ra

#####################
## FUNCTION: input ##
#####################

input:
	li $s0, 0
	la $t0, A
	la $s3, N
	lw $s3, 0($s3)

input_loop:
	# Print the prompt
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 4
	la $a0, prompt2
	syscall
	
	li $v0, 5
	syscall
	
	sw $v0, 0($t0)
	
	addi $t0, $t0, 4
	addi $s0, $s0, 1
	bne $s0, $s3, input_loop

input_loop_end:
	jr $ra
