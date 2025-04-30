# A test assembly program that does not much.

	.Code

	li	t0,	13
	addi	sp,	sp,	-4
	sw	t0,	0(sp)
	lw	a1,	0(sp)

	lw	a0,	SYSCALL_EXIT_CODE	# Load the run syscall code into a0 (arg[0])
	ecall
	


	.Numeric

SYSCALL_EXIT_CODE:	0xca110001
SYSCALL_RUN_CODE:	0xca110002
SYSCALL_PRINT_CODE:	0xca110003

