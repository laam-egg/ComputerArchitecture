.data
	intro:		.asciiz "Triangle Calculator\n"
	prompt_a:	.asciiz	"Enter side a: "
	prompt_b:	.asciiz "Enter side b: "
	prompt_c:	.asciiz "Enter side c: "
	res_invalid:	.asciiz "ERROR: Not three sides of a triangle !"
	res_perimeter:	.asciiz "Perimeter of this triangle is: "
	res_area:	.asciiz "Area of this triangle is: "
	zero_f:		.float	0
	two_f:		.float	2

.text
_start:
	# a => $f4, b => $f5, c => $f6
	jal input
	jal output
_end:
	li $v0, 10
	syscall

#####################################
# FUNCTION: input
#
# After calling this function,
# $f4, $f5, $f6 contains the
# values of a, b, c respectively.
#####################################

input:
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
	
	li $v0, 4
	la $a0, prompt_c
	syscall
	
	li $v0, 6
	syscall
	mov.s $f6, $f0
	
	jr $ra

#####################################
# FUNCTION: output
# If $f4, $f5, $f6 forms three sides
# of a triangle, outputs its perimeter
# and area.
# Otherwise, claims that they do not
# form a triangle.
#####################################

output:
	# Check a > 0, b > 0, c > 0:
	la $t0, zero_f
	l.s $f0, 0($t0)
	
	c.le.s $f4, $f0
	bc1t output_not_a_triangle
	c.le.s $f5, $f0
	bc1t output_not_a_triangle
	c.le.s $f6, $f0
	bc1t output_not_a_triangle	
	
	# Check a + b > c, a + c > b, b + c > a
	add.s $f12, $f4, $f5
	c.lt.s $f6, $f12
	bc1f output_not_a_triangle
	
	add.s $f12, $f4, $f6
	c.lt.s $f5, $f12
	bc1f output_not_a_triangle
	
	add.s $f12, $f5, $f6 # line (*)
	c.lt.s $f4, $f12
	bc1f output_not_a_triangle
	
	# Perimeter:
	li $v0, 4
	la $a0, res_perimeter
	syscall
	# Now $f12 = $f5 + $f6 (due to line (*)), so we just have to:
	add.s $f12, $f12, $f4
	li $v0, 2
	syscall
	
	li $v0, 11
	li $a0, 10 # \n
	syscall

	# Area:
	# Use Heron formula
	# p = (a + b + c) / 2
	# S = sqrt(  p(p-a)(p-b)(p-c)  )
	
	la $t0, two_f
	l.s $f2, 0($t0)
	# $f7 = p
	div.s $f7, $f12, $f2
	# $f8 = p-a
	sub.s $f8, $f7, $f4
	# $f9 = p-b
	sub.s $f9, $f7, $f5
	# $f10 = p-c
	sub.s $f10, $f7, $f6
	
	mul.s $f12, $f7, $f8
	mul.s $f12, $f12, $f9
	mul.s $f12, $f12, $f10
	sqrt.s $f12, $f12
	
	li $v0, 4
	la $a0, res_area
	syscall
	
	li $v0, 2
	syscall
	
	jr $ra

output_not_a_triangle:
	li $v0, 4
	la $a0, res_invalid
	syscall
	jr $ra
