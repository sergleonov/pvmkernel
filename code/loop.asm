.Code
_start:
    li t0, 0          # t0 = loop counter = 0
    addi sp, sp, -4
    li t1, 10000      # t1 = loop limit = 10000
    li t2, 0          # t2 = accumulator (some dummy work inside loop)

loop_start:
    bge t0, t1, loop_end  # if t0 >= t1, exit loop

    addi t2, t2, 1        # example operation: increment t2

    addi t0, t0, 1        # increment loop counter
    j loop_start          # jump back to loop_start

loop_end:
    # End of loop — could add syscall to exit, etc.
    li a7, 10             # syscall for exit
	li  a0, 0xca110001
    ebreak
	ecall
	



