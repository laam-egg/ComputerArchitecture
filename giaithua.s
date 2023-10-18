.data
	intro:		.asciiz "Factorial Calculator (n!)\n"
	prompt:		.asciiz	"Enter n: "
	res:		.asciiz "! = "

.text
_start:
	jal input
	move $a0, $v0
	move $s0, $v0 # n
	jal frac
	move $a0, $v0 # n!
	move $a1, $s0 # n
	jal output

_end:
	li $v0, 10
	syscall

frac:
	slti $t1, $a0, 2
	beq $t1, $zero, frac_recursive
	li $v0, 1
	jr $ra

frac_recursive:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	
	addi $a0, $a0, -1
	jal frac
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	mul $v0, $a0, $v0
	
	addi $sp, $sp, 8	
	jr $ra

input:
	li $v0, 4
	la $a0, intro
	syscall
	
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 5
	syscall
	
	jr $ra

output:
	move $s0, $a0 # n!
	
	li $v0, 1
	move $a0, $a1 # n
	syscall
	
	li $v0, 4
	la $a0, res
	syscall
	
	li $v0, 1
	move $a0, $s0 # n!
	syscall
	
	jr $ra
