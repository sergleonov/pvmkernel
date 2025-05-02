	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0_zmmul1p0"
	.file	"kernel.c"
	.globl	int_to_hex                      # -- Begin function int_to_hex
	.p2align	2
	.type	int_to_hex,@function
int_to_hex:                             # @int_to_hex
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	li	a0, 28
	sw	a0, -20(s0)
	j	kernel_LBB0_1
kernel_LBB0_1:                                # =>This Innerkernel_Loop Header: Depth=1
	lw	a0, -20(s0)
	bltz	a0, kernel_LBB0_4
	j	kernel_LBB0_2
kernel_LBB0_2:                                #   inkernel_Loop: Header=BB0_1 Depth=1
	lw	a0, -12(s0)
	lw	a1, -20(s0)
	srl	a0, a0, a1
	andi	a0, a0, 15
	sw	a0, -24(s0)
	lw	a1, -24(s0)
	lui	a0, %hi(hex_digits)
	addi	a0, a0, %lo(hex_digits)
	add	a0, a0, a1
	lbu	a0, 0(a0)
	lw	a1, -16(s0)
	addi	a2, a1, 1
	sw	a2, -16(s0)
	sb	a0, 0(a1)
	j	kernel_LBB0_3
kernel_LBB0_3:                                #   inkernel_Loop: Header=BB0_1 Depth=1
	lw	a0, -20(s0)
	addi	a0, a0, -4
	sw	a0, -20(s0)
	j	kernel_LBB0_1
kernel_LBB0_4:
	lw	a1, -16(s0)
	li	a0, 0
	sb	a0, 0(a1)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
kernel_Lfunc_end0:
	.size	int_to_hex, kernel_Lfunc_end0-int_to_hex
                                        # -- End function
	.globl	heap_init                       # -- Begin function heap_init
	.p2align	2
	.type	heap_init,@function
heap_init:                              # @heap_init
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	lui	a0, %hi(heap_limit)
	lw	a0, %lo(heap_limit)(a0)
	beqz	a0, kernel_LBB1_2
	j	kernel_LBB1_1
kernel_LBB1_1:
	j	kernel_LBB1_3
kernel_LBB1_2:
	lui	a0, %hi(statics_limit)
	lw	a0, %lo(statics_limit)(a0)
	lui	a1, %hi(heap_limit)
	sw	a0, %lo(heap_limit)(a1)
	lui	a0, %hi(free_head)
	addi	a0, a0, %lo(free_head)
	lui	a1, %hi(free_tail)
	addi	a1, a1, %lo(free_tail)
	sw	a1, 4(a0)
	sw	a0, 8(a1)
	j	kernel_LBB1_3
kernel_LBB1_3:
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end1:
	.size	heap_init, kernel_Lfunc_end1-heap_init
                                        # -- End function
	.globl	heap_alloc                      # -- Begin function heap_alloc
	.p2align	2
	.type	heap_alloc,@function
heap_alloc:                             # @heap_alloc
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	call	heap_init
	lbu	a0, -12(s0)
	andi	a0, a0, 3
	bnez	a0, kernel_LBB2_2
	j	kernel_LBB2_1
kernel_LBB2_1:
	lw	a0, -12(s0)
	sw	a0, -32(s0)                     # 4-byte Folded Spill
	j	kernel_LBB2_3
kernel_LBB2_2:
	lw	a0, -12(s0)
	addi	a0, a0, 4
	andi	a0, a0, 3
	sw	a0, -32(s0)                     # 4-byte Folded Spill
	j	kernel_LBB2_3
kernel_LBB2_3:
	lw	a0, -32(s0)                     # 4-byte Folded Reload
	sw	a0, -12(s0)
	lui	a0, %hi(free_head)
	addi	a0, a0, %lo(free_head)
	lw	a0, 4(a0)
	sw	a0, -16(s0)
	j	kernel_LBB2_4
kernel_LBB2_4:                                # =>This Innerkernel_Loop Header: Depth=1
	lw	a0, -16(s0)
	lui	a1, %hi(free_tail)
	addi	a1, a1, %lo(free_tail)
	beq	a0, a1, kernel_LBB2_9
	j	kernel_LBB2_5
kernel_LBB2_5:                                #   inkernel_Loop: Header=BB2_4 Depth=1
	lw	a0, -16(s0)
	lw	a0, 0(a0)
	lw	a1, -12(s0)
	bltu	a0, a1, kernel_LBB2_7
	j	kernel_LBB2_6
kernel_LBB2_6:
	lw	a1, -16(s0)
	lw	a0, 4(a1)
	lw	a1, 8(a1)
	sw	a0, 4(a1)
	lw	a1, -16(s0)
	lw	a0, 8(a1)
	lw	a1, 4(a1)
	sw	a0, 8(a1)
	lw	a1, -16(s0)
	li	a0, 0
	sw	a0, 4(a1)
	lw	a1, -16(s0)
	sw	a0, 8(a1)
	j	kernel_LBB2_9
kernel_LBB2_7:                                #   inkernel_Loop: Header=BB2_4 Depth=1
	lw	a0, -16(s0)
	lw	a0, 4(a0)
	sw	a0, -16(s0)
	j	kernel_LBB2_8
kernel_LBB2_8:                                #   inkernel_Loop: Header=BB2_4 Depth=1
	j	kernel_LBB2_4
kernel_LBB2_9:
	lw	a0, -16(s0)
	lui	a1, %hi(free_tail)
	addi	a1, a1, %lo(free_tail)
	bne	a0, a1, kernel_LBB2_14
	j	kernel_LBB2_10
kernel_LBB2_10:
	lw	a0, -12(s0)
	addi	a0, a0, 12
	sw	a0, -20(s0)
	lui	a0, %hi(heap_limit)
	lw	a1, %lo(heap_limit)(a0)
	sw	a1, -16(s0)
	lw	a1, -12(s0)
	lw	a2, -16(s0)
	sw	a1, 0(a2)
	li	a1, 0
	sw	a1, -24(s0)
	addi	a1, s0, -24
	sw	a1, -28(s0)
	lw	a0, %lo(heap_limit)(a0)
	lw	a1, -20(s0)
	add	a0, a0, a1
	lw	a1, -28(s0)
	bltu	a0, a1, kernel_LBB2_12
	j	kernel_LBB2_11
kernel_LBB2_11:
	call	syscall_handler_halt
	j	kernel_LBB2_13
kernel_LBB2_12:
	lw	a2, -20(s0)
	lui	a1, %hi(heap_limit)
	lw	a0, %lo(heap_limit)(a1)
	add	a0, a0, a2
	sw	a0, %lo(heap_limit)(a1)
	j	kernel_LBB2_13
kernel_LBB2_13:
	j	kernel_LBB2_14
kernel_LBB2_14:
	lw	a0, -16(s0)
	addi	a0, a0, 12
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
kernel_Lfunc_end2:
	.size	heap_alloc, kernel_Lfunc_end2-heap_alloc
                                        # -- End function
	.globl	heap_free                       # -- Begin function heap_free
	.p2align	2
	.type	heap_free,@function
heap_free:                              # @heap_free
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	bnez	a0, kernel_LBB3_2
	j	kernel_LBB3_1
kernel_LBB3_1:
	j	kernel_LBB3_3
kernel_LBB3_2:
	lw	a0, -12(s0)
	addi	a0, a0, -12
	sw	a0, -16(s0)
	lui	a1, %hi(free_head)
	addi	a1, a1, %lo(free_head)
	lw	a0, 4(a1)
	lw	a2, -16(s0)
	sw	a0, 4(a2)
	lw	a0, -16(s0)
	sw	a1, 8(a0)
	lw	a0, -16(s0)
	lw	a2, 4(a1)
	sw	a0, 8(a2)
	lw	a0, -16(s0)
	sw	a0, 4(a1)
	j	kernel_LBB3_3
kernel_LBB3_3:
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end3:
	.size	heap_free, kernel_Lfunc_end3-heap_free
                                        # -- End function
	.globl	ram_init                        # -- Begin function ram_init
	.p2align	2
	.type	ram_init,@function
ram_init:                               # @ram_init
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	li	a0, 12
	call	heap_alloc
	lui	a2, %hi(RAM_head)
	sw	a0, %lo(RAM_head)(a2)
	lui	a0, %hi(kernel_limit)
	lw	a1, %lo(kernel_limit)(a0)
	lw	a3, %lo(RAM_head)(a2)
	sw	a1, 8(a3)
	lw	a3, %lo(RAM_head)(a2)
	li	a1, 0
	sw	a1, 0(a3)
	lw	a2, %lo(RAM_head)(a2)
	sw	a1, 4(a2)
	lw	a0, %lo(kernel_limit)(a0)
	lui	a1, %hi(page_size)
	lw	a1, %lo(page_size)(a1)
	add	a0, a0, a1
	sw	a0, -12(s0)
	j	kernel_LBB4_1
kernel_LBB4_1:                                # =>This Innerkernel_Loop Header: Depth=1
	lw	a0, -12(s0)
	lui	a1, %hi(RAM_limit)
	lw	a1, %lo(RAM_limit)(a1)
	bgeu	a0, a1, kernel_LBB4_6
	j	kernel_LBB4_2
kernel_LBB4_2:                                #   inkernel_Loop: Header=BB4_1 Depth=1
	li	a0, 12
	call	heap_alloc
	sw	a0, -16(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	sw	a0, 8(a1)
	lw	a0, -16(s0)
	li	a1, 0
	sw	a1, 0(a0)
	lw	a0, -16(s0)
	sw	a1, 4(a0)
	lui	a0, %hi(RAM_head)
	lw	a2, %lo(RAM_head)(a0)
	lw	a3, -16(s0)
	sw	a2, 0(a3)
	lw	a2, -16(s0)
	sw	a1, 4(a2)
	lw	a0, %lo(RAM_head)(a0)
	beqz	a0, kernel_LBB4_4
	j	kernel_LBB4_3
kernel_LBB4_3:                                #   inkernel_Loop: Header=BB4_1 Depth=1
	lw	a0, -16(s0)
	lui	a1, %hi(RAM_head)
	lw	a1, %lo(RAM_head)(a1)
	sw	a0, 4(a1)
	j	kernel_LBB4_4
kernel_LBB4_4:                                #   inkernel_Loop: Header=BB4_1 Depth=1
	lw	a0, -16(s0)
	lui	a1, %hi(RAM_head)
	sw	a0, %lo(RAM_head)(a1)
	j	kernel_LBB4_5
kernel_LBB4_5:                                #   inkernel_Loop: Header=BB4_1 Depth=1
	lui	a0, %hi(page_size)
	lw	a1, %lo(page_size)(a0)
	lw	a0, -12(s0)
	add	a0, a0, a1
	sw	a0, -12(s0)
	j	kernel_LBB4_1
kernel_LBB4_6:
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end4:
	.size	ram_init, kernel_Lfunc_end4-ram_init
                                        # -- End function
	.globl	page_alloc                      # -- Begin function page_alloc
	.p2align	2
	.type	page_alloc,@function
page_alloc:                             # @page_alloc
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	lui	a0, %hi(RAM_head)
	lw	a0, %lo(RAM_head)(a0)
	beqz	a0, kernel_LBB5_7
	j	kernel_LBB5_1
kernel_LBB5_1:
	lui	a0, %hi(RAM_head)
	lw	a1, %lo(RAM_head)(a0)
	lw	a1, 8(a1)
	sw	a1, -16(s0)
	lw	a1, %lo(RAM_head)(a0)
	sw	a1, -20(s0)
	lw	a0, %lo(RAM_head)(a0)
	lw	a0, 0(a0)
	beqz	a0, kernel_LBB5_3
	j	kernel_LBB5_2
kernel_LBB5_2:
	lui	a0, %hi(RAM_head)
	lw	a1, %lo(RAM_head)(a0)
	lw	a0, 4(a1)
	lw	a1, 0(a1)
	sw	a0, 4(a1)
	j	kernel_LBB5_3
kernel_LBB5_3:
	lui	a0, %hi(RAM_head)
	lw	a0, %lo(RAM_head)(a0)
	lw	a0, 4(a0)
	beqz	a0, kernel_LBB5_5
	j	kernel_LBB5_4
kernel_LBB5_4:
	lui	a0, %hi(RAM_head)
	lw	a1, %lo(RAM_head)(a0)
	lw	a0, 0(a1)
	lw	a1, 4(a1)
	sw	a0, 0(a1)
	j	kernel_LBB5_6
kernel_LBB5_5:
	lui	a1, %hi(RAM_head)
	lw	a0, %lo(RAM_head)(a1)
	lw	a0, 0(a0)
	sw	a0, %lo(RAM_head)(a1)
	j	kernel_LBB5_6
kernel_LBB5_6:
	lw	a0, -20(s0)
	call	heap_free
	lw	a0, -16(s0)
	sw	a0, -12(s0)
	j	kernel_LBB5_8
kernel_LBB5_7:
	li	a0, 0
	sw	a0, -12(s0)
	j	kernel_LBB5_8
kernel_LBB5_8:
	lw	a0, -12(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
kernel_Lfunc_end5:
	.size	page_alloc, kernel_Lfunc_end5-page_alloc
                                        # -- End function
	.globl	ram_free                        # -- Begin function ram_free
	.p2align	2
	.type	ram_free,@function
ram_free:                               # @ram_free
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	li	a0, 12
	call	heap_alloc
	sw	a0, -16(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	sw	a0, 8(a1)
	lui	a0, %hi(RAM_head)
	lw	a1, %lo(RAM_head)(a0)
	lw	a2, -16(s0)
	sw	a1, 0(a2)
	lw	a2, -16(s0)
	li	a1, 0
	sw	a1, 4(a2)
	lw	a0, %lo(RAM_head)(a0)
	beqz	a0, kernel_LBB6_2
	j	kernel_LBB6_1
kernel_LBB6_1:
	lw	a0, -16(s0)
	lui	a1, %hi(RAM_head)
	lw	a1, %lo(RAM_head)(a1)
	sw	a0, 4(a1)
	j	kernel_LBB6_2
kernel_LBB6_2:
	lw	a0, -16(s0)
	lui	a1, %hi(RAM_head)
	sw	a0, %lo(RAM_head)(a1)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end6:
	.size	ram_free, kernel_Lfunc_end6-ram_free
                                        # -- End function
	.globl	process_head_init               # -- Begin function process_head_init
	.p2align	2
	.type	process_head_init,@function
process_head_init:                      # @process_head_init
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	li	a0, 28
	call	heap_alloc
	lui	a1, %hi(process_head)
	sw	a0, %lo(process_head)(a1)
	lw	a0, %lo(process_head)(a1)
	sw	a0, 4(a0)
	lw	a0, %lo(process_head)(a1)
	sw	a0, 0(a0)
	lw	a2, %lo(process_head)(a1)
	li	a0, 0
	sw	a0, 20(a2)
	lw	a2, %lo(process_head)(a1)
	sw	a0, 16(a2)
	lw	a2, %lo(process_head)(a1)
	sw	a0, 8(a2)
	lw	a1, %lo(process_head)(a1)
	sw	a0, 24(a1)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end7:
	.size	process_head_init, kernel_Lfunc_end7-process_head_init
                                        # -- End function
	.globl	jump_to_next_ROM                # -- Begin function jump_to_next_ROM
	.p2align	2
	.type	jump_to_next_ROM,@function
jump_to_next_ROM:                       # @jump_to_next_ROM
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	lw	a0, 16(a0)
	call	userspace_jump
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end8:
	.size	jump_to_next_ROM, kernel_Lfunc_end8-jump_to_next_ROM
                                        # -- End function
	.globl	run_ROM                         # -- Begin function run_ROM
	.p2align	2
	.type	run_ROM,@function
run_ROM:                                # @run_ROM
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -12(s0)
	lui	a0, %hi(kernel_L.str)
	addi	a0, a0, %lo(kernel_L.str)
	call	print
	lw	a0, -12(s0)
	addi	a1, s0, -21
	sw	a1, -52(s0)                     # 4-byte Folded Spill
	call	int_to_hex
	lw	a0, -52(s0)                     # 4-byte Folded Reload
	call	print
	lui	a0, %hi(kernel_L.str.1)
	addi	a0, a0, %lo(kernel_L.str.1)
	call	print
	lui	a0, %hi(ROM_device_code)
	lw	a0, %lo(ROM_device_code)(a0)
	lw	a1, -12(s0)
	call	find_device
	sw	a0, -28(s0)
	lw	a0, -28(s0)
	bnez	a0, kernel_LBB9_2
	j	kernel_LBB9_1
kernel_LBB9_1:
	lui	a0, %hi(kernel_L.str.2)
	addi	a0, a0, %lo(kernel_L.str.2)
	call	print
	j	kernel_LBB9_17
kernel_LBB9_2:
	li	a0, 4
	call	heap_alloc
	sw	a0, -32(s0)
	li	a0, 0
	sw	a0, -36(s0)
	j	kernel_LBB9_3
kernel_LBB9_3:                                # =>This Innerkernel_Loop Header: Depth=1
	lw	a0, -36(s0)
	lui	a1, %hi(program_size)
	lw	a1, %lo(program_size)(a1)
	lui	a2, %hi(page_size)
	lw	a2, %lo(page_size)(a2)
	divu	a1, a1, a2
	bge	a0, a1, kernel_LBB9_8
	j	kernel_LBB9_4
kernel_LBB9_4:                                #   inkernel_Loop: Header=BB9_3 Depth=1
	call	page_alloc
	lw	a1, -32(s0)
	lw	a2, -36(s0)
	slli	a2, a2, 2
	add	a1, a1, a2
	sw	a0, 0(a1)
	lw	a0, -32(s0)
	lw	a1, -36(s0)
	slli	a1, a1, 2
	add	a0, a0, a1
	lw	a0, 0(a0)
	bnez	a0, kernel_LBB9_6
	j	kernel_LBB9_5
kernel_LBB9_5:                                #   inkernel_Loop: Header=BB9_3 Depth=1
	lui	a0, %hi(kernel_L.str.3)
	addi	a0, a0, %lo(kernel_L.str.3)
	call	print
	call	syscall_handler_halt
	j	kernel_LBB9_6
kernel_LBB9_6:                                #   inkernel_Loop: Header=BB9_3 Depth=1
	j	kernel_LBB9_7
kernel_LBB9_7:                                #   inkernel_Loop: Header=BB9_3 Depth=1
	lw	a0, -36(s0)
	addi	a0, a0, 1
	sw	a0, -36(s0)
	j	kernel_LBB9_3
kernel_LBB9_8:
	lui	a0, %hi(kernel_L.str.4)
	addi	a0, a0, %lo(kernel_L.str.4)
	call	print
	lw	a0, -28(s0)
	lw	a0, 4(a0)
	sw	a0, -40(s0)
	li	a0, 0
	sw	a0, -44(s0)
	j	kernel_LBB9_9
kernel_LBB9_9:                                # =>This Innerkernel_Loop Header: Depth=1
	lw	a0, -44(s0)
	lui	a1, %hi(program_size)
	lw	a1, %lo(program_size)(a1)
	lui	a2, %hi(page_size)
	lw	a2, %lo(page_size)(a2)
	divu	a1, a1, a2
	bge	a0, a1, kernel_LBB9_12
	j	kernel_LBB9_10
kernel_LBB9_10:                               #   inkernel_Loop: Header=BB9_9 Depth=1
	lw	a1, -40(s0)
	lw	a2, -44(s0)
	lui	a0, %hi(page_size)
	lw	a3, %lo(page_size)(a0)
	mul	a2, a2, a3
	add	a2, a1, a2
	lui	a1, %hi(DMA_portal_ptr)
	lw	a3, %lo(DMA_portal_ptr)(a1)
	sw	a2, 0(a3)
	lw	a2, -32(s0)
	lw	a3, -44(s0)
	slli	a3, a3, 2
	add	a2, a2, a3
	lw	a2, 0(a2)
	lw	a3, %lo(DMA_portal_ptr)(a1)
	sw	a2, 4(a3)
	lw	a0, %lo(page_size)(a0)
	lw	a1, %lo(DMA_portal_ptr)(a1)
	sw	a0, 8(a1)
	j	kernel_LBB9_11
kernel_LBB9_11:                               #   inkernel_Loop: Header=BB9_9 Depth=1
	lw	a0, -44(s0)
	addi	a0, a0, 1
	sw	a0, -44(s0)
	j	kernel_LBB9_9
kernel_LBB9_12:
	li	a0, 28
	call	heap_alloc
	sw	a0, -48(s0)
	lw	a0, -12(s0)
	lw	a1, -48(s0)
	sw	a0, 8(a1)
	lw	a0, -32(s0)
	lw	a1, -48(s0)
	sw	a0, 12(a1)
	lui	a0, %hi(program_size)
	lw	a0, %lo(program_size)(a0)
	lw	a1, -48(s0)
	sw	a0, 20(a1)
	lw	a1, -48(s0)
	li	a0, 0
	sw	a0, 16(a1)
	lw	a1, -48(s0)
	sw	a0, 24(a1)
	lw	a0, -48(s0)
	lui	a1, %hi(curr_process)
	sw	a0, %lo(curr_process)(a1)
	lui	a0, %hi(process_head)
	lw	a1, %lo(process_head)(a0)
	lw	a1, 0(a1)
	lw	a2, -48(s0)
	sw	a1, 0(a2)
	lw	a1, %lo(process_head)(a0)
	lw	a2, -48(s0)
	sw	a1, 4(a2)
	lw	a1, %lo(process_head)(a0)
	lw	a0, 0(a1)
	beq	a0, a1, kernel_LBB9_14
	j	kernel_LBB9_13
kernel_LBB9_13:
	lw	a0, -48(s0)
	lui	a1, %hi(process_head)
	lw	a1, %lo(process_head)(a1)
	lw	a1, 0(a1)
	sw	a0, 4(a1)
	j	kernel_LBB9_14
kernel_LBB9_14:
	lw	a1, -48(s0)
	lui	a0, %hi(process_head)
	lw	a2, %lo(process_head)(a0)
	sw	a1, 0(a2)
	lw	a1, %lo(process_head)(a0)
	lw	a0, 4(a1)
	bne	a0, a1, kernel_LBB9_16
	j	kernel_LBB9_15
kernel_LBB9_15:
	lw	a0, -48(s0)
	lui	a1, %hi(process_head)
	lw	a1, %lo(process_head)(a1)
	sw	a0, 4(a1)
	j	kernel_LBB9_16
kernel_LBB9_16:
	lui	a0, %hi(curr_process)
	lw	a0, %lo(curr_process)(a0)
	call	jump_to_next_ROM
	j	kernel_LBB9_17
kernel_LBB9_17:
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	ret
kernel_Lfunc_end9:
	.size	run_ROM, kernel_Lfunc_end9-run_ROM
                                        # -- End function
	.globl	run_programs                    # -- Begin function run_programs
	.p2align	2
	.type	run_programs,@function
run_programs:                           # @run_programs
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	lui	a2, %hi(run_programs.next_program_ROM)
	lw	a0, %lo(run_programs.next_program_ROM)(a2)
	addi	a1, a0, 1
	sw	a1, %lo(run_programs.next_program_ROM)(a2)
	call	run_ROM
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end10:
	.size	run_programs, kernel_Lfunc_end10-run_programs
                                        # -- End function
	.globl	end_process                     # -- Begin function end_process
	.p2align	2
	.type	end_process,@function
end_process:                            # @end_process
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	lui	a0, %hi(kernel_L.str.5)
	addi	a0, a0, %lo(kernel_L.str.5)
	call	print
	li	a0, 0
	sw	a0, -12(s0)
	j	kernel_LBB11_1
kernel_LBB11_1:                               # =>This Innerkernel_Loop Header: Depth=1
	lw	a0, -12(s0)
	lui	a1, %hi(program_size)
	lw	a1, %lo(program_size)(a1)
	lui	a2, %hi(page_size)
	lw	a2, %lo(page_size)(a2)
	divu	a1, a1, a2
	bge	a0, a1, kernel_LBB11_4
	j	kernel_LBB11_2
kernel_LBB11_2:                               #   inkernel_Loop: Header=BB11_1 Depth=1
	lui	a0, %hi(curr_process)
	lw	a0, %lo(curr_process)(a0)
	lw	a0, 12(a0)
	lw	a1, -12(s0)
	slli	a1, a1, 2
	add	a0, a0, a1
	lw	a0, 0(a0)
	call	ram_free
	j	kernel_LBB11_3
kernel_LBB11_3:                               #   inkernel_Loop: Header=BB11_1 Depth=1
	lw	a0, -12(s0)
	addi	a0, a0, 1
	sw	a0, -12(s0)
	j	kernel_LBB11_1
kernel_LBB11_4:
	lui	a0, %hi(curr_process)
	lw	a1, %lo(curr_process)(a0)
	sw	a1, -16(s0)
	lw	a1, %lo(curr_process)(a0)
	lw	a1, 0(a1)
	sw	a1, %lo(curr_process)(a0)
	lw	a1, %lo(curr_process)(a0)
	lw	a0, 0(a1)
	lw	a1, 4(a1)
	bne	a0, a1, kernel_LBB11_6
	j	kernel_LBB11_5
kernel_LBB11_5:
	lui	a1, %hi(process_head)
	li	a0, 0
	sw	a0, %lo(process_head)(a1)
	lui	a0, %hi(kernel_L.str.6)
	addi	a0, a0, %lo(kernel_L.str.6)
	call	print
	lui	a0, %hi(kernel_L.str.7)
	addi	a0, a0, %lo(kernel_L.str.7)
	call	print
	call	syscall_handler_halt
	j	kernel_LBB11_13
kernel_LBB11_6:
	lui	a0, %hi(process_head)
	lw	a0, %lo(process_head)(a0)
	lw	a1, -16(s0)
	bne	a0, a1, kernel_LBB11_11
	j	kernel_LBB11_7
kernel_LBB11_7:
	lw	a1, -16(s0)
	lw	a0, 0(a1)
	bne	a0, a1, kernel_LBB11_9
	j	kernel_LBB11_8
kernel_LBB11_8:
	lui	a1, %hi(process_head)
	li	a0, 0
	sw	a0, %lo(process_head)(a1)
	j	kernel_LBB11_10
kernel_LBB11_9:
	lw	a0, -16(s0)
	lw	a1, 0(a0)
	lui	a0, %hi(process_head)
	sw	a1, %lo(process_head)(a0)
	lw	a1, -16(s0)
	lw	a1, 4(a1)
	lw	a2, %lo(process_head)(a0)
	sw	a1, 4(a2)
	lw	a0, %lo(process_head)(a0)
	lw	a1, -16(s0)
	lw	a1, 4(a1)
	sw	a0, 0(a1)
	j	kernel_LBB11_10
kernel_LBB11_10:
	j	kernel_LBB11_12
kernel_LBB11_11:
	lw	a1, -16(s0)
	lw	a0, 0(a1)
	lw	a1, 4(a1)
	sw	a0, 0(a1)
	lw	a1, -16(s0)
	lw	a0, 4(a1)
	lw	a1, 0(a1)
	sw	a0, 4(a1)
	j	kernel_LBB11_12
kernel_LBB11_12:
	lw	a0, -16(s0)
	call	heap_free
	j	kernel_LBB11_13
kernel_LBB11_13:
	lui	a0, %hi(kernel_L.str.7)
	addi	a0, a0, %lo(kernel_L.str.7)
	call	print
	lui	a0, %hi(curr_process)
	lw	a0, %lo(curr_process)(a0)
	lw	a0, 16(a0)
	bnez	a0, kernel_LBB11_15
	j	kernel_LBB11_14
kernel_LBB11_14:
	lui	a0, %hi(process_head)
	lw	a0, %lo(process_head)(a0)
	lw	a0, 0(a0)
	lui	a1, %hi(curr_process)
	sw	a0, %lo(curr_process)(a1)
	j	kernel_LBB11_15
kernel_LBB11_15:
	lui	a0, %hi(curr_process)
	lw	a0, %lo(curr_process)(a0)
	call	jump_to_next_ROM
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end11:
	.size	end_process, kernel_Lfunc_end11-end_process
                                        # -- End function
	.globl	update_curr_process             # -- Begin function update_curr_process
	.p2align	2
	.type	update_curr_process,@function
update_curr_process:                    # @update_curr_process
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	lw	a0, -16(s0)
	lui	a1, %hi(page_size)
	lw	a1, %lo(page_size)(a1)
	divu	a0, a0, a1
	lui	a1, %hi(curr_process)
	lw	a2, %lo(curr_process)(a1)
	sw	a0, 24(a2)
	lw	a0, -12(s0)
	lw	a2, %lo(curr_process)(a1)
	lw	a3, 12(a2)
	lw	a4, 24(a2)
	slli	a4, a4, 2
	add	a3, a3, a4
	lw	a3, 0(a3)
	add	a0, a0, a3
	sw	a0, 20(a2)
	lw	a0, -16(s0)
	lw	a1, %lo(curr_process)(a1)
	lw	a2, 12(a1)
	lw	a3, 24(a1)
	slli	a3, a3, 2
	add	a2, a2, a3
	lw	a2, 0(a2)
	add	a0, a0, a2
	sw	a0, 16(a1)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end12:
	.size	update_curr_process, kernel_Lfunc_end12-update_curr_process
                                        # -- End function
	.globl	alarm_next_program              # -- Begin function alarm_next_program
	.p2align	2
	.type	alarm_next_program,@function
alarm_next_program:                     # @alarm_next_program
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	lui	a0, %hi(kernel_L.str.8)
	addi	a0, a0, %lo(kernel_L.str.8)
	call	print
	lui	a0, %hi(curr_process)
	lw	a1, %lo(curr_process)(a0)
	lw	a1, 0(a1)
	sw	a1, %lo(curr_process)(a0)
	lw	a0, %lo(curr_process)(a0)
	lw	a0, 16(a0)
	bnez	a0, kernel_LBB13_2
	j	kernel_LBB13_1
kernel_LBB13_1:
	lui	a0, %hi(process_head)
	lw	a0, %lo(process_head)(a0)
	lw	a0, 0(a0)
	lui	a1, %hi(curr_process)
	sw	a0, %lo(curr_process)(a1)
	j	kernel_LBB13_2
kernel_LBB13_2:
	lui	a0, %hi(curr_process)
	lw	a0, %lo(curr_process)(a0)
	call	jump_to_next_ROM
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end13:
	.size	alarm_next_program, kernel_Lfunc_end13-alarm_next_program
                                        # -- End function
	.globl	restore_sp                      # -- Begin function restore_sp
	.p2align	2
	.type	restore_sp,@function
restore_sp:                             # @restore_sp
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	lui	a0, %hi(curr_process)
	lw	a0, %lo(curr_process)(a0)
	lw	a0, 16(a0)
	bnez	a0, kernel_LBB14_2
	j	kernel_LBB14_1
kernel_LBB14_1:
	lui	a0, %hi(process_head)
	lw	a0, %lo(process_head)(a0)
	lw	a0, 0(a0)
	lui	a1, %hi(curr_process)
	sw	a0, %lo(curr_process)(a1)
	j	kernel_LBB14_2
kernel_LBB14_2:
	lui	a0, %hi(curr_process)
	lw	a0, %lo(curr_process)(a0)
	lw	a0, 20(a0)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end14:
	.size	restore_sp, kernel_Lfunc_end14-restore_sp
                                        # -- End function
	.globl	get_base                        # -- Begin function get_base
	.p2align	2
	.type	get_base,@function
get_base:                               # @get_base
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	lui	a0, %hi(curr_process)
	lw	a0, %lo(curr_process)(a0)
	lw	a0, 16(a0)
	bnez	a0, kernel_LBB15_2
	j	kernel_LBB15_1
kernel_LBB15_1:
	lui	a0, %hi(process_head)
	lw	a0, %lo(process_head)(a0)
	lw	a0, 0(a0)
	lui	a1, %hi(curr_process)
	sw	a0, %lo(curr_process)(a1)
	j	kernel_LBB15_2
kernel_LBB15_2:
	lui	a0, %hi(curr_process)
	lw	a1, %lo(curr_process)(a0)
	lw	a0, 12(a1)
	lw	a1, 24(a1)
	slli	a1, a1, 2
	add	a0, a0, a1
	lw	a0, 0(a0)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end15:
	.size	get_base, kernel_Lfunc_end15-get_base
                                        # -- End function
	.globl	get_limit                       # -- Begin function get_limit
	.p2align	2
	.type	get_limit,@function
get_limit:                              # @get_limit
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	lui	a0, %hi(curr_process)
	lw	a0, %lo(curr_process)(a0)
	lw	a0, 16(a0)
	bnez	a0, kernel_LBB16_2
	j	kernel_LBB16_1
kernel_LBB16_1:
	lui	a0, %hi(process_head)
	lw	a0, %lo(process_head)(a0)
	lw	a0, 0(a0)
	lui	a1, %hi(curr_process)
	sw	a0, %lo(curr_process)(a1)
	j	kernel_LBB16_2
kernel_LBB16_2:
	lui	a0, %hi(curr_process)
	lw	a1, %lo(curr_process)(a0)
	lw	a0, 12(a1)
	lw	a1, 24(a1)
	slli	a1, a1, 2
	add	a0, a0, a1
	lw	a0, 0(a0)
	lui	a1, %hi(page_size)
	lw	a1, %lo(page_size)(a1)
	add	a0, a0, a1
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end16:
	.size	get_limit, kernel_Lfunc_end16-get_limit
                                        # -- End function
	.globl	zero_page                       # -- Begin function zero_page
	.p2align	2
	.type	zero_page,@function
zero_page:                              # @zero_page
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	sw	a0, -16(s0)
	j	kernel_LBB17_1
kernel_LBB17_1:                               # =>This Innerkernel_Loop Header: Depth=1
	lw	a0, -16(s0)
	lw	a1, -12(s0)
	addi	a1, a1, 1024
	bgeu	a0, a1, kernel_LBB17_4
	j	kernel_LBB17_2
kernel_LBB17_2:                               #   inkernel_Loop: Header=BB17_1 Depth=1
	lw	a1, -16(s0)
	li	a0, 0
	sw	a0, 0(a1)
	j	kernel_LBB17_3
kernel_LBB17_3:                               #   inkernel_Loop: Header=BB17_1 Depth=1
	lw	a0, -16(s0)
	addi	a0, a0, 4
	sw	a0, -16(s0)
	j	kernel_LBB17_1
kernel_LBB17_4:
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end17:
	.size	zero_page, kernel_Lfunc_end17-zero_page
                                        # -- End function
	.globl	create_upt                      # -- Begin function create_upt
	.p2align	2
	.type	create_upt,@function
create_upt:                             # @create_upt
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	call	page_alloc
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	call	zero_page
	lw	a0, -12(s0)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end18:
	.size	create_upt, kernel_Lfunc_end18-create_upt
                                        # -- End function
	.globl	set_pte                         # -- Begin function set_pte
	.p2align	2
	.type	set_pte,@function
set_pte:                                # @set_pte
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	lw	a0, -16(s0)
	srli	a0, a0, 22
	sw	a0, -24(s0)
	lw	a0, -12(s0)
	lw	a1, -24(s0)
	slli	a1, a1, 2
	add	a0, a0, a1
	lw	a0, 0(a0)
	bnez	a0, kernel_LBB19_2
	j	kernel_LBB19_1
kernel_LBB19_1:
	call	page_alloc
	sw	a0, -28(s0)
	lw	a0, -28(s0)
	call	zero_page
	lw	a0, -28(s0)
	lw	a1, -12(s0)
	lw	a2, -24(s0)
	slli	a2, a2, 2
	add	a1, a1, a2
	sw	a0, 0(a1)
	j	kernel_LBB19_2
kernel_LBB19_2:
	lw	a0, -12(s0)
	lw	a1, -24(s0)
	slli	a1, a1, 2
	add	a0, a0, a1
	lw	a0, 0(a0)
	sw	a0, -32(s0)
	lw	a0, -16(s0)
	slli	a0, a0, 10
	srli	a0, a0, 22
	sw	a0, -36(s0)
	lw	a0, -20(s0)
	lw	a1, -32(s0)
	lw	a2, -36(s0)
	slli	a2, a2, 2
	add	a1, a1, a2
	sw	a0, 0(a1)
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	ret
kernel_Lfunc_end19:
	.size	set_pte, kernel_Lfunc_end19-set_pte
                                        # -- End function
	.globl	find_last_device                # -- Begin function find_last_device
	.p2align	2
	.type	find_last_device,@function
find_last_device:                       # @find_last_device
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	lui	a0, %hi(device_table_base)
	lw	a0, %lo(device_table_base)(a0)
	sw	a0, -12(s0)
	li	a0, 0
	sw	a0, -16(s0)
	j	kernel_LBB20_1
kernel_LBB20_1:                               # =>This Innerkernel_Loop Header: Depth=1
	lw	a0, -12(s0)
	lw	a0, 0(a0)
	lui	a1, %hi(none_device_code)
	lw	a1, %lo(none_device_code)(a1)
	beq	a0, a1, kernel_LBB20_3
	j	kernel_LBB20_2
kernel_LBB20_2:                               #   inkernel_Loop: Header=BB20_1 Depth=1
	lw	a0, -12(s0)
	sw	a0, -16(s0)
	lw	a0, -12(s0)
	addi	a0, a0, 12
	sw	a0, -12(s0)
	j	kernel_LBB20_1
kernel_LBB20_3:
	lw	a0, -16(s0)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
kernel_Lfunc_end20:
	.size	find_last_device, kernel_Lfunc_end20-find_last_device
                                        # -- End function
	.globl	create_kernel_upt               # -- Begin function create_kernel_upt
	.p2align	2
	.type	create_kernel_upt,@function
create_kernel_upt:                      # @create_kernel_upt
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	call	create_upt
	sw	a0, -12(s0)
	lui	a0, 1
	sw	a0, -16(s0)
	call	find_last_device
	lw	a0, 8(a0)
	sw	a0, -20(s0)
	li	a0, 7
	sw	a0, -24(s0)
	lw	a0, -16(s0)
	sw	a0, -28(s0)
	j	kernel_LBB21_1
kernel_LBB21_1:                               # =>This Innerkernel_Loop Header: Depth=1
	lw	a0, -28(s0)
	lw	a1, -20(s0)
	bgeu	a0, a1, kernel_LBB21_4
	j	kernel_LBB21_2
kernel_LBB21_2:                               #   inkernel_Loop: Header=BB21_1 Depth=1
	lw	a0, -28(s0)
	lw	a1, -24(s0)
	or	a0, a0, a1
	sw	a0, -32(s0)
	lw	a0, -12(s0)
	lw	a1, -28(s0)
	lw	a2, -32(s0)
	call	set_pte
	j	kernel_LBB21_3
kernel_LBB21_3:                               #   inkernel_Loop: Header=BB21_1 Depth=1
	lw	a0, -28(s0)
	lui	a1, 1
	add	a0, a0, a1
	sw	a0, -28(s0)
	j	kernel_LBB21_1
kernel_LBB21_4:
	lw	a0, -12(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
kernel_Lfunc_end21:
	.size	create_kernel_upt, kernel_Lfunc_end21-create_kernel_upt
                                        # -- End function
	.type	free_head,@object               # @free_head
	.bss
	.globl	free_head
	.p2align	2, 0x0
free_head:
	.zero	12
	.size	free_head, 12

	.type	free_tail,@object               # @free_tail
	.globl	free_tail
	.p2align	2, 0x0
free_tail:
	.zero	12
	.size	free_tail, 12

	.type	hex_digits,@object              # @hex_digits
	.data
hex_digits:
	.ascii	"0123456789abcdef"
	.size	hex_digits, 16

	.type	heap_limit,@object              # @heap_limit
	.section	.sbss,"aw",@nobits
	.p2align	2, 0x0
heap_limit:
	.word	0                               # 0x0
	.size	heap_limit, 4

	.type	RAM_head,@object                # @RAM_head
	.p2align	2, 0x0
RAM_head:
	.word	0
	.size	RAM_head, 4

	.type	page_size,@object               # @page_size
	.section	.sdata,"aw",@progbits
	.p2align	2, 0x0
page_size:
	.word	4096                            # 0x1000
	.size	page_size, 4

	.type	process_head,@object            # @process_head
	.section	.sbss,"aw",@nobits
	.p2align	2, 0x0
process_head:
	.word	0
	.size	process_head, 4

	.type	kernel_L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
kernel_L.str:
	.asciz	"Searching for ROM #"
	.size	kernel_L.str, 20

	.type	kernel_L.str.1,@object                # @.str.1
kernel_L.str.1:
	.asciz	"\n"
	.size	kernel_L.str.1, 2

	.type	kernel_L.str.2,@object                # @.str.2
kernel_L.str.2:
	.asciz	"Process not found\n"
	.size	kernel_L.str.2, 19

	.type	program_size,@object            # @program_size
	.section	.sdata,"aw",@progbits
	.p2align	2, 0x0
program_size:
	.word	32768                           # 0x8000
	.size	program_size, 4

	.type	kernel_L.str.3,@object                # @.str.3
	.section	.rodata.str1.1,"aMS",@progbits,1
kernel_L.str.3:
	.asciz	"No more RAM space.\n"
	.size	kernel_L.str.3, 20

	.type	kernel_L.str.4,@object                # @.str.4
kernel_L.str.4:
	.asciz	"Running program...\n"
	.size	kernel_L.str.4, 20

	.type	curr_process,@object            # @curr_process
	.section	.sbss,"aw",@nobits
	.p2align	2, 0x0
curr_process:
	.word	0
	.size	curr_process, 4

	.type	run_programs.next_program_ROM,@object # @run_programs.next_program_ROM
	.section	.sdata,"aw",@progbits
	.p2align	2, 0x0
run_programs.next_program_ROM:
	.word	3                               # 0x3
	.size	run_programs.next_program_ROM, 4

	.type	kernel_L.str.5,@object                # @.str.5
	.section	.rodata.str1.1,"aMS",@progbits,1
kernel_L.str.5:
	.asciz	"Ending current process..."
	.size	kernel_L.str.5, 26

	.type	kernel_L.str.6,@object                # @.str.6
kernel_L.str.6:
	.asciz	"(last one)"
	.size	kernel_L.str.6, 11

	.type	kernel_L.str.7,@object                # @.str.7
kernel_L.str.7:
	.asciz	"done.\n"
	.size	kernel_L.str.7, 7

	.type	kernel_L.str.8,@object                # @.str.8
kernel_L.str.8:
	.asciz	"Alarm interrupt invoked...\nJumping to next program...\n"
	.size	kernel_L.str.8, 55

	.type	end_of_statics,@object          # @end_of_statics
	.data
	.globl	end_of_statics
end_of_statics:
	.asciz	"end of statics"
	.size	end_of_statics, 15

	.ident	"clang version 19.1.6 (https://github.com/conda-forge/clangdev-feedstock a097c63bb6a9919682224023383a143d482c552e)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym int_to_hex
	.addrsig_sym heap_init
	.addrsig_sym heap_alloc
	.addrsig_sym syscall_handler_halt
	.addrsig_sym heap_free
	.addrsig_sym page_alloc
	.addrsig_sym ram_free
	.addrsig_sym jump_to_next_ROM
	.addrsig_sym userspace_jump
	.addrsig_sym run_ROM
	.addrsig_sym print
	.addrsig_sym find_device
	.addrsig_sym zero_page
	.addrsig_sym create_upt
	.addrsig_sym set_pte
	.addrsig_sym find_last_device
	.addrsig_sym free_head
	.addrsig_sym free_tail
	.addrsig_sym hex_digits
	.addrsig_sym heap_limit
	.addrsig_sym statics_limit
	.addrsig_sym RAM_head
	.addrsig_sym kernel_limit
	.addrsig_sym page_size
	.addrsig_sym RAM_limit
	.addrsig_sym process_head
	.addrsig_sym ROM_device_code
	.addrsig_sym program_size
	.addrsig_sym DMA_portal_ptr
	.addrsig_sym curr_process
	.addrsig_sym run_programs.next_program_ROM
	.addrsig_sym device_table_base
	.addrsig_sym none_device_code
