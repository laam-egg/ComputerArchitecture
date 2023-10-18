.data
	intro:		.asciiz "ax + b = 0 Equation Solver\n"
	prompt_a:	.asciiz "Enter a: "
	prompt_b:	.asciiz "Enter b: "
	res_infinite:	.asciiz	"Equation has infinite solutions"
	res_none:	.asciiz "Equation has no solution"
	res_one:		.asciiz "Equation has one solution: "
	zerof:		.float	0
	minus1f:		.float	-1
	
.text
#################
## ENTRY POINT ##
#################

_start:
	# ax + b = 0
	# a => $f4, b => $f5, 0.0f => $f10, -1.0f => $f11
	la $t0, zerof
	l.s $f10, 0($t0)
	la $t0, minus1f
	l.s $f11, 0($t0)
	
	jal input_a_and_b
	
	c.eq.s $f4, $f10
	bc1f one_solution
	
	c.eq.s $f5, $f10
	bc1t infinite_solutions
	
no_solution:
	li $v0, 4
	la $a0, res_none
	syscall
	j _end

one_solution:
	li $v0, 4
	la $a0, res_one
	syscall
	
	div.s $f12, $f5, $f4
	mul.s $f12, $f12, $f11
	jal print_f12
	j _end

infinite_solutions:
	li $v0, 4
	la $a0, res_infinite
	syscall
	j _end

_end:
	li $v0, 10
	syscall

#########################
## FUNCTION: print_f12 ##
#########################

print_f12:
	li $v0, 2
	syscall
	jr $ra

#############################
## FUNCTION: input_a_and_b ##
#############################

input_a_and_b:
	li $v0, 4
	la $a0, intro
	syscall
	
	li $v0, 4
	la $a0, prompt_a
	syscall
	
	li $v0, 6
	syscall
	mov.s $f4, $f0
	
	li $v0, 4
	la $a0, prompt_b
	syscall
	
	li $v0, 6
	syscall
	mov.s $f5, $f0

	jr $ra
