.data
	message:	.ascii	"Hello World\n"
	message_len:	.word	12
	name:		.space	40
	name_len:	.word	40

.text
main:
	li $v0, 1
	li $a0, 1234
	syscall
	
	li $v0, 11
	li $a0, 0xA
	syscall

	; li $v0, 10
	li $v0, 17
	li $a0, 5
	syscall
