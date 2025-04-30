# ===================================================================================================================================
# syscall_wrappers.asm
#
# Small assmebly functions to set up and perform system calls.  These allow regular user-level code to perform system calls as
# though they were regular functions.
# ===================================================================================================================================



# ===================================================================================================================================
	.Code
	li	t0,	13
	la 	t1, msg	
	addi	sp,	sp,	-4
	sw	t0,	0(sp)
	lw	a1,	0(sp)

	# run 4
	addi a0, zero, 4
	mv	a1,	a0			# Move the ROM number into a1 (arg[1])
	lw	a0,	SYSCALL_RUN_CODE	# Load the run syscall code into a0 (arg[0])
	ecall

	# print msg
	add a0, zero, t1
	mv	a1,	a0			# Move the string pointer into a1 (arg[1])
	lw	a0,	SYSCALL_PRINT_CODE	# Load the print syscall code into a0 (arg[0])
	ecall

	# run 5
	addi a0, zero, 5
	mv	a1,	a0			# Move the ROM number into a1 (arg[1])
	lw	a0,	SYSCALL_RUN_CODE	# Load the run syscall code into a0 (arg[0])
	ecall

	# run 6
	addi a0, zero, 6
	mv	a1,	a0			# Move the ROM number into a1 (arg[1])
	lw	a0,	SYSCALL_RUN_CODE	# Load the run syscall code into a0 (arg[0])
	ecall

	# exit
	mv	a1,	a0			# Move the exit status into a1 (arg[1])
	lw	a0,	SYSCALL_EXIT_CODE	# Load the exit syscall code into a0 (arg[0])
	ecall
	ebreak					# If we reach here, something is terribly wrong.

# step========================================================================================================
	


# ===================================================================================================================================
	.Numeric

## The system call codes.
SYSCALL_EXIT_CODE:	0xca110001
SYSCALL_RUN_CODE:	0xca110002
SYSCALL_PRINT_CODE:	0xca110003
# ===================================================================================================================================
	.Text
msg: "hello from program\n"