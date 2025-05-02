	.Code
int_to_hex:
	#	%bb.0: 
	addi	sp, sp, -32 
	sw	ra, 28(sp) # 4-byte Folded Spill 
	sw	s0, 24(sp) # 4-byte Folded Spill 
	addi	s0, sp, 32 
	sw	a0, -12(s0) 
	sw	a1, -16(s0) 
	li	a0, 28 
	sw	a0, -20(s0) 
	j	kernel_LBB0_1 
kernel_LBB0_1:
	lw	a0, -20(s0) 
	bltz	a0, kernel_LBB0_4 
	j	kernel_LBB0_2 
kernel_LBB0_2:
	lw	a0, -12(s0) 
	lw	a1, -20(s0) 
	srl	a0, a0, a1 
	andi	a0, a0, 15 
	sw	a0, -24(s0) 
	lw	a1, -24(s0) 
kernel_autoL0:
	auipc	a0, %hi(%pcrel(hex_digits))
	addi	a0, a0, %lo(%larel(hex_digits,kernel_autoL0))
	add	a0, a0, a1 
	lbu	a0, 0(a0) 
	lw	a1, -16(s0) 
	addi	a2, a1, 1 
	sw	a2, -16(s0) 
	sb	a0, 0(a1) 
	j	kernel_LBB0_3 
kernel_LBB0_3:
	lw	a0, -20(s0) 
	addi	a0, a0, -4 
	sw	a0, -20(s0) 
	j	kernel_LBB0_1 
kernel_LBB0_4:
	lw	a1, -16(s0) 
	li	a0, 0 
	sb	a0, 0(a1) 
	lw	ra, 28(sp) # 4-byte Folded Reload 
	lw	s0, 24(sp) # 4-byte Folded Reload 
	addi	sp, sp, 32 
	ret	
kernel_Lfunc_end0:
	#	-- End function 
heap_init:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL1:
	auipc	a0, %hi(%pcrel(heap_limit))
	lw	a0, %lo(%larel(heap_limit,kernel_autoL1))(a0)
	beqz	a0, kernel_LBB1_2 
	j	kernel_LBB1_1 
kernel_LBB1_1:
	j	kernel_LBB1_3 
kernel_LBB1_2:
kernel_autoL2:
	auipc	a0, %hi(%pcrel(statics_limit))
	lw	a0, %lo(%larel(statics_limit,kernel_autoL2))(a0)
kernel_autoL3:
	auipc	a1, %hi(%pcrel(heap_limit))
	sw	a0, %lo(%larel(heap_limit,kernel_autoL3))(a1)
kernel_autoL4:
	auipc	a0, %hi(%pcrel(free_head))
	addi	a0, a0, %lo(%larel(free_head,kernel_autoL4))
kernel_autoL5:
	auipc	a1, %hi(%pcrel(free_tail))
	addi	a1, a1, %lo(%larel(free_tail,kernel_autoL5))
	sw	a1, 4(a0) 
	sw	a0, 8(a1) 
	j	kernel_LBB1_3 
kernel_LBB1_3:
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end1:
	#	-- End function 
heap_alloc:
	#	%bb.0: 
	addi	sp, sp, -32 
	sw	ra, 28(sp) # 4-byte Folded Spill 
	sw	s0, 24(sp) # 4-byte Folded Spill 
	addi	s0, sp, 32 
	sw	a0, -12(s0) 
	call	heap_init 
	lbu	a0, -12(s0) 
	andi	a0, a0, 3 
	bnez	a0, kernel_LBB2_2 
	j	kernel_LBB2_1 
kernel_LBB2_1:
	lw	a0, -12(s0) 
	sw	a0, -32(s0) # 4-byte Folded Spill 
	j	kernel_LBB2_3 
kernel_LBB2_2:
	lw	a0, -12(s0) 
	addi	a0, a0, 4 
	andi	a0, a0, 3 
	sw	a0, -32(s0) # 4-byte Folded Spill 
	j	kernel_LBB2_3 
kernel_LBB2_3:
	lw	a0, -32(s0) # 4-byte Folded Reload 
	sw	a0, -12(s0) 
kernel_autoL6:
	auipc	a0, %hi(%pcrel(free_head))
	addi	a0, a0, %lo(%larel(free_head,kernel_autoL6))
	lw	a0, 4(a0) 
	sw	a0, -16(s0) 
	j	kernel_LBB2_4 
kernel_LBB2_4:
	lw	a0, -16(s0) 
kernel_autoL7:
	auipc	a1, %hi(%pcrel(free_tail))
	addi	a1, a1, %lo(%larel(free_tail,kernel_autoL7))
	beq	a0, a1, kernel_LBB2_9 
	j	kernel_LBB2_5 
kernel_LBB2_5:
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
kernel_LBB2_7:
	lw	a0, -16(s0) 
	lw	a0, 4(a0) 
	sw	a0, -16(s0) 
	j	kernel_LBB2_8 
kernel_LBB2_8:
	j	kernel_LBB2_4 
kernel_LBB2_9:
	lw	a0, -16(s0) 
kernel_autoL8:
	auipc	a1, %hi(%pcrel(free_tail))
	addi	a1, a1, %lo(%larel(free_tail,kernel_autoL8))
	bne	a0, a1, kernel_LBB2_14 
	j	kernel_LBB2_10 
kernel_LBB2_10:
	lw	a0, -12(s0) 
	addi	a0, a0, 12 
	sw	a0, -20(s0) 
kernel_autoL9:
	auipc	a0, %hi(%pcrel(heap_limit))
	lw	a1, %lo(%larel(heap_limit,kernel_autoL9))(a0)
	sw	a1, -16(s0) 
	lw	a1, -12(s0) 
	lw	a2, -16(s0) 
	sw	a1, 0(a2) 
	li	a1, 0 
	sw	a1, -24(s0) 
	addi	a1, s0, -24 
	sw	a1, -28(s0) 
	lw	a0, %lo(%larel(heap_limit,kernel_autoL9))(a0)
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
kernel_autoL10:
	auipc	a1, %hi(%pcrel(heap_limit))
	lw	a0, %lo(%larel(heap_limit,kernel_autoL10))(a1)
	add	a0, a0, a2 
	sw	a0, %lo(%larel(heap_limit,kernel_autoL10))(a1)
	j	kernel_LBB2_13 
kernel_LBB2_13:
	j	kernel_LBB2_14 
kernel_LBB2_14:
	lw	a0, -16(s0) 
	addi	a0, a0, 12 
	lw	ra, 28(sp) # 4-byte Folded Reload 
	lw	s0, 24(sp) # 4-byte Folded Reload 
	addi	sp, sp, 32 
	ret	
kernel_Lfunc_end2:
	#	-- End function 
heap_free:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
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
kernel_autoL11:
	auipc	a1, %hi(%pcrel(free_head))
	addi	a1, a1, %lo(%larel(free_head,kernel_autoL11))
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
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end3:
	#	-- End function 
ram_init:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
	li	a0, 12 
	call	heap_alloc 
kernel_autoL12:
	auipc	a2, %hi(%pcrel(RAM_head))
	sw	a0, %lo(%larel(RAM_head,kernel_autoL12))(a2)
kernel_autoL13:
	auipc	a0, %hi(%pcrel(kernel_limit))
	lw	a1, %lo(%larel(kernel_limit,kernel_autoL13))(a0)
	lw	a3, %lo(%larel(RAM_head,kernel_autoL12))(a2)
	sw	a1, 8(a3) 
	lw	a3, %lo(%larel(RAM_head,kernel_autoL12))(a2)
	li	a1, 0 
	sw	a1, 0(a3) 
	lw	a2, %lo(%larel(RAM_head,kernel_autoL12))(a2)
	sw	a1, 4(a2) 
	lw	a0, %lo(%larel(kernel_limit,kernel_autoL13))(a0)
kernel_autoL14:
	auipc	a1, %hi(%pcrel(page_size))
	lw	a1, %lo(%larel(page_size,kernel_autoL14))(a1)
	add	a0, a0, a1 
	sw	a0, -12(s0) 
	j	kernel_LBB4_1 
kernel_LBB4_1:
	lw	a0, -12(s0) 
kernel_autoL15:
	auipc	a1, %hi(%pcrel(RAM_limit))
	lw	a1, %lo(%larel(RAM_limit,kernel_autoL15))(a1)
	bgeu	a0, a1, kernel_LBB4_6 
	j	kernel_LBB4_2 
kernel_LBB4_2:
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
kernel_autoL16:
	auipc	a0, %hi(%pcrel(RAM_head))
	lw	a2, %lo(%larel(RAM_head,kernel_autoL16))(a0)
	lw	a3, -16(s0) 
	sw	a2, 0(a3) 
	lw	a2, -16(s0) 
	sw	a1, 4(a2) 
	lw	a0, %lo(%larel(RAM_head,kernel_autoL16))(a0)
	beqz	a0, kernel_LBB4_4 
	j	kernel_LBB4_3 
kernel_LBB4_3:
	lw	a0, -16(s0) 
kernel_autoL17:
	auipc	a1, %hi(%pcrel(RAM_head))
	lw	a1, %lo(%larel(RAM_head,kernel_autoL17))(a1)
	sw	a0, 4(a1) 
	j	kernel_LBB4_4 
kernel_LBB4_4:
	lw	a0, -16(s0) 
kernel_autoL18:
	auipc	a1, %hi(%pcrel(RAM_head))
	sw	a0, %lo(%larel(RAM_head,kernel_autoL18))(a1)
	j	kernel_LBB4_5 
kernel_LBB4_5:
kernel_autoL19:
	auipc	a0, %hi(%pcrel(page_size))
	lw	a1, %lo(%larel(page_size,kernel_autoL19))(a0)
	lw	a0, -12(s0) 
	add	a0, a0, a1 
	sw	a0, -12(s0) 
	j	kernel_LBB4_1 
kernel_LBB4_6:
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end4:
	#	-- End function 
page_alloc:
	#	%bb.0: 
	addi	sp, sp, -32 
	sw	ra, 28(sp) # 4-byte Folded Spill 
	sw	s0, 24(sp) # 4-byte Folded Spill 
	addi	s0, sp, 32 
kernel_autoL20:
	auipc	a0, %hi(%pcrel(RAM_head))
	lw	a0, %lo(%larel(RAM_head,kernel_autoL20))(a0)
	beqz	a0, kernel_LBB5_7 
	j	kernel_LBB5_1 
kernel_LBB5_1:
kernel_autoL21:
	auipc	a0, %hi(%pcrel(RAM_head))
	lw	a1, %lo(%larel(RAM_head,kernel_autoL21))(a0)
	lw	a1, 8(a1) 
	sw	a1, -16(s0) 
	lw	a1, %lo(%larel(RAM_head,kernel_autoL21))(a0)
	sw	a1, -20(s0) 
	lw	a0, %lo(%larel(RAM_head,kernel_autoL21))(a0)
	lw	a0, 0(a0) 
	beqz	a0, kernel_LBB5_3 
	j	kernel_LBB5_2 
kernel_LBB5_2:
kernel_autoL22:
	auipc	a0, %hi(%pcrel(RAM_head))
	lw	a1, %lo(%larel(RAM_head,kernel_autoL22))(a0)
	lw	a0, 4(a1) 
	lw	a1, 0(a1) 
	sw	a0, 4(a1) 
	j	kernel_LBB5_3 
kernel_LBB5_3:
kernel_autoL23:
	auipc	a0, %hi(%pcrel(RAM_head))
	lw	a0, %lo(%larel(RAM_head,kernel_autoL23))(a0)
	lw	a0, 4(a0) 
	beqz	a0, kernel_LBB5_5 
	j	kernel_LBB5_4 
kernel_LBB5_4:
kernel_autoL24:
	auipc	a0, %hi(%pcrel(RAM_head))
	lw	a1, %lo(%larel(RAM_head,kernel_autoL24))(a0)
	lw	a0, 0(a1) 
	lw	a1, 4(a1) 
	sw	a0, 0(a1) 
	j	kernel_LBB5_6 
kernel_LBB5_5:
kernel_autoL25:
	auipc	a1, %hi(%pcrel(RAM_head))
	lw	a0, %lo(%larel(RAM_head,kernel_autoL25))(a1)
	lw	a0, 0(a0) 
	sw	a0, %lo(%larel(RAM_head,kernel_autoL25))(a1)
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
	lw	ra, 28(sp) # 4-byte Folded Reload 
	lw	s0, 24(sp) # 4-byte Folded Reload 
	addi	sp, sp, 32 
	ret	
kernel_Lfunc_end5:
	#	-- End function 
ram_free:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
	sw	a0, -12(s0) 
	li	a0, 12 
	call	heap_alloc 
	sw	a0, -16(s0) 
	lw	a0, -12(s0) 
	lw	a1, -16(s0) 
	sw	a0, 8(a1) 
kernel_autoL26:
	auipc	a0, %hi(%pcrel(RAM_head))
	lw	a1, %lo(%larel(RAM_head,kernel_autoL26))(a0)
	lw	a2, -16(s0) 
	sw	a1, 0(a2) 
	lw	a2, -16(s0) 
	li	a1, 0 
	sw	a1, 4(a2) 
	lw	a0, %lo(%larel(RAM_head,kernel_autoL26))(a0)
	beqz	a0, kernel_LBB6_2 
	j	kernel_LBB6_1 
kernel_LBB6_1:
	lw	a0, -16(s0) 
kernel_autoL27:
	auipc	a1, %hi(%pcrel(RAM_head))
	lw	a1, %lo(%larel(RAM_head,kernel_autoL27))(a1)
	sw	a0, 4(a1) 
	j	kernel_LBB6_2 
kernel_LBB6_2:
	lw	a0, -16(s0) 
kernel_autoL28:
	auipc	a1, %hi(%pcrel(RAM_head))
	sw	a0, %lo(%larel(RAM_head,kernel_autoL28))(a1)
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end6:
	#	-- End function 
process_head_init:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
	li	a0, 28 
	call	heap_alloc 
kernel_autoL29:
	auipc	a1, %hi(%pcrel(process_head))
	sw	a0, %lo(%larel(process_head,kernel_autoL29))(a1)
	lw	a0, %lo(%larel(process_head,kernel_autoL29))(a1)
	sw	a0, 4(a0) 
	lw	a0, %lo(%larel(process_head,kernel_autoL29))(a1)
	sw	a0, 0(a0) 
	lw	a2, %lo(%larel(process_head,kernel_autoL29))(a1)
	li	a0, 0 
	sw	a0, 20(a2) 
	lw	a2, %lo(%larel(process_head,kernel_autoL29))(a1)
	sw	a0, 16(a2) 
	lw	a2, %lo(%larel(process_head,kernel_autoL29))(a1)
	sw	a0, 8(a2) 
	lw	a1, %lo(%larel(process_head,kernel_autoL29))(a1)
	sw	a0, 24(a1) 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end7:
	#	-- End function 
jump_to_next_ROM:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
	sw	a0, -12(s0) 
	lw	a0, -12(s0) 
	lw	a0, 16(a0) 
	call	userspace_jump 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end8:
	#	-- End function 
run_ROM:
	#	%bb.0: 
	addi	sp, sp, -64 
	sw	ra, 60(sp) # 4-byte Folded Spill 
	sw	s0, 56(sp) # 4-byte Folded Spill 
	addi	s0, sp, 64 
	sw	a0, -12(s0) 
kernel_autoL30:
	auipc	a0, %hi(%pcrel(kernel_L.str))
	addi	a0, a0, %lo(%larel(kernel_L.str,kernel_autoL30))
	call	print 
	lw	a0, -12(s0) 
	addi	a1, s0, -21 
	sw	a1, -52(s0) # 4-byte Folded Spill 
	call	int_to_hex 
	lw	a0, -52(s0) # 4-byte Folded Reload 
	call	print 
kernel_autoL31:
	auipc	a0, %hi(%pcrel(kernel_L.str.1))
	addi	a0, a0, %lo(%larel(kernel_L.str.1,kernel_autoL31))
	call	print 
kernel_autoL32:
	auipc	a0, %hi(%pcrel(ROM_device_code))
	lw	a0, %lo(%larel(ROM_device_code,kernel_autoL32))(a0)
	lw	a1, -12(s0) 
	call	find_device 
	sw	a0, -28(s0) 
	lw	a0, -28(s0) 
	bnez	a0, kernel_LBB9_2 
	j	kernel_LBB9_1 
kernel_LBB9_1:
kernel_autoL33:
	auipc	a0, %hi(%pcrel(kernel_L.str.2))
	addi	a0, a0, %lo(%larel(kernel_L.str.2,kernel_autoL33))
	call	print 
	j	kernel_LBB9_17 
kernel_LBB9_2:
	li	a0, 4 
	call	heap_alloc 
	sw	a0, -32(s0) 
	li	a0, 0 
	sw	a0, -36(s0) 
	j	kernel_LBB9_3 
kernel_LBB9_3:
	lw	a0, -36(s0) 
kernel_autoL34:
	auipc	a1, %hi(%pcrel(program_size))
	lw	a1, %lo(%larel(program_size,kernel_autoL34))(a1)
kernel_autoL35:
	auipc	a2, %hi(%pcrel(page_size))
	lw	a2, %lo(%larel(page_size,kernel_autoL35))(a2)
	divu	a1, a1, a2 
	bge	a0, a1, kernel_LBB9_8 
	j	kernel_LBB9_4 
kernel_LBB9_4:
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
kernel_LBB9_5:
kernel_autoL36:
	auipc	a0, %hi(%pcrel(kernel_L.str.3))
	addi	a0, a0, %lo(%larel(kernel_L.str.3,kernel_autoL36))
	call	print 
	call	syscall_handler_halt 
	j	kernel_LBB9_6 
kernel_LBB9_6:
	j	kernel_LBB9_7 
kernel_LBB9_7:
	lw	a0, -36(s0) 
	addi	a0, a0, 1 
	sw	a0, -36(s0) 
	j	kernel_LBB9_3 
kernel_LBB9_8:
kernel_autoL37:
	auipc	a0, %hi(%pcrel(kernel_L.str.4))
	addi	a0, a0, %lo(%larel(kernel_L.str.4,kernel_autoL37))
	call	print 
	lw	a0, -28(s0) 
	lw	a0, 4(a0) 
	sw	a0, -40(s0) 
	li	a0, 0 
	sw	a0, -44(s0) 
	j	kernel_LBB9_9 
kernel_LBB9_9:
	lw	a0, -44(s0) 
kernel_autoL38:
	auipc	a1, %hi(%pcrel(program_size))
	lw	a1, %lo(%larel(program_size,kernel_autoL38))(a1)
kernel_autoL39:
	auipc	a2, %hi(%pcrel(page_size))
	lw	a2, %lo(%larel(page_size,kernel_autoL39))(a2)
	divu	a1, a1, a2 
	bge	a0, a1, kernel_LBB9_12 
	j	kernel_LBB9_10 
kernel_LBB9_10:
	lw	a1, -40(s0) 
	lw	a2, -44(s0) 
kernel_autoL40:
	auipc	a0, %hi(%pcrel(page_size))
	lw	a3, %lo(%larel(page_size,kernel_autoL40))(a0)
	mul	a2, a2, a3 
	add	a2, a1, a2 
kernel_autoL41:
	auipc	a1, %hi(%pcrel(DMA_portal_ptr))
	lw	a3, %lo(%larel(DMA_portal_ptr,kernel_autoL41))(a1)
	sw	a2, 0(a3) 
	lw	a2, -32(s0) 
	lw	a3, -44(s0) 
	slli	a3, a3, 2 
	add	a2, a2, a3 
	lw	a2, 0(a2) 
	lw	a3, %lo(%larel(DMA_portal_ptr,kernel_autoL41))(a1)
	sw	a2, 4(a3) 
	lw	a0, %lo(%larel(page_size,kernel_autoL40))(a0)
	lw	a1, %lo(%larel(DMA_portal_ptr,kernel_autoL41))(a1)
	sw	a0, 8(a1) 
	j	kernel_LBB9_11 
kernel_LBB9_11:
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
kernel_autoL42:
	auipc	a0, %hi(%pcrel(program_size))
	lw	a0, %lo(%larel(program_size,kernel_autoL42))(a0)
	lw	a1, -48(s0) 
	sw	a0, 20(a1) 
	lw	a1, -48(s0) 
	li	a0, 0 
	sw	a0, 16(a1) 
	lw	a1, -48(s0) 
	sw	a0, 24(a1) 
	lw	a0, -48(s0) 
kernel_autoL43:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL43))(a1)
kernel_autoL44:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a1, %lo(%larel(process_head,kernel_autoL44))(a0)
	lw	a1, 0(a1) 
	lw	a2, -48(s0) 
	sw	a1, 0(a2) 
	lw	a1, %lo(%larel(process_head,kernel_autoL44))(a0)
	lw	a2, -48(s0) 
	sw	a1, 4(a2) 
	lw	a1, %lo(%larel(process_head,kernel_autoL44))(a0)
	lw	a0, 0(a1) 
	beq	a0, a1, kernel_LBB9_14 
	j	kernel_LBB9_13 
kernel_LBB9_13:
	lw	a0, -48(s0) 
kernel_autoL45:
	auipc	a1, %hi(%pcrel(process_head))
	lw	a1, %lo(%larel(process_head,kernel_autoL45))(a1)
	lw	a1, 0(a1) 
	sw	a0, 4(a1) 
	j	kernel_LBB9_14 
kernel_LBB9_14:
	lw	a1, -48(s0) 
kernel_autoL46:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a2, %lo(%larel(process_head,kernel_autoL46))(a0)
	sw	a1, 0(a2) 
	lw	a1, %lo(%larel(process_head,kernel_autoL46))(a0)
	lw	a0, 4(a1) 
	bne	a0, a1, kernel_LBB9_16 
	j	kernel_LBB9_15 
kernel_LBB9_15:
	lw	a0, -48(s0) 
kernel_autoL47:
	auipc	a1, %hi(%pcrel(process_head))
	lw	a1, %lo(%larel(process_head,kernel_autoL47))(a1)
	sw	a0, 4(a1) 
	j	kernel_LBB9_16 
kernel_LBB9_16:
kernel_autoL48:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL48))(a0)
	call	jump_to_next_ROM 
	j	kernel_LBB9_17 
kernel_LBB9_17:
	lw	ra, 60(sp) # 4-byte Folded Reload 
	lw	s0, 56(sp) # 4-byte Folded Reload 
	addi	sp, sp, 64 
	ret	
kernel_Lfunc_end9:
	#	-- End function 
run_programs:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL49:
	auipc	a2, %hi(%pcrel(run_programs.next_program_ROM))
	lw	a0, %lo(%larel(run_programs.next_program_ROM,kernel_autoL49))(a2)
	addi	a1, a0, 1 
	sw	a1, %lo(%larel(run_programs.next_program_ROM,kernel_autoL49))(a2)
	call	run_ROM 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end10:
	#	-- End function 
end_process:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL50:
	auipc	a0, %hi(%pcrel(kernel_L.str.5))
	addi	a0, a0, %lo(%larel(kernel_L.str.5,kernel_autoL50))
	call	print 
	li	a0, 0 
	sw	a0, -12(s0) 
	j	kernel_LBB11_1 
kernel_LBB11_1:
	lw	a0, -12(s0) 
kernel_autoL51:
	auipc	a1, %hi(%pcrel(program_size))
	lw	a1, %lo(%larel(program_size,kernel_autoL51))(a1)
kernel_autoL52:
	auipc	a2, %hi(%pcrel(page_size))
	lw	a2, %lo(%larel(page_size,kernel_autoL52))(a2)
	divu	a1, a1, a2 
	bge	a0, a1, kernel_LBB11_4 
	j	kernel_LBB11_2 
kernel_LBB11_2:
kernel_autoL53:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL53))(a0)
	lw	a0, 12(a0) 
	lw	a1, -12(s0) 
	slli	a1, a1, 2 
	add	a0, a0, a1 
	lw	a0, 0(a0) 
	call	ram_free 
	j	kernel_LBB11_3 
kernel_LBB11_3:
	lw	a0, -12(s0) 
	addi	a0, a0, 1 
	sw	a0, -12(s0) 
	j	kernel_LBB11_1 
kernel_LBB11_4:
kernel_autoL54:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a1, %lo(%larel(curr_process,kernel_autoL54))(a0)
	sw	a1, -16(s0) 
	lw	a1, %lo(%larel(curr_process,kernel_autoL54))(a0)
	lw	a1, 0(a1) 
	sw	a1, %lo(%larel(curr_process,kernel_autoL54))(a0)
	lw	a1, %lo(%larel(curr_process,kernel_autoL54))(a0)
	lw	a0, 0(a1) 
	lw	a1, 4(a1) 
	bne	a0, a1, kernel_LBB11_6 
	j	kernel_LBB11_5 
kernel_LBB11_5:
kernel_autoL55:
	auipc	a1, %hi(%pcrel(process_head))
	li	a0, 0 
	sw	a0, %lo(%larel(process_head,kernel_autoL55))(a1)
kernel_autoL56:
	auipc	a0, %hi(%pcrel(kernel_L.str.6))
	addi	a0, a0, %lo(%larel(kernel_L.str.6,kernel_autoL56))
	call	print 
kernel_autoL57:
	auipc	a0, %hi(%pcrel(kernel_L.str.7))
	addi	a0, a0, %lo(%larel(kernel_L.str.7,kernel_autoL57))
	call	print 
	call	syscall_handler_halt 
	j	kernel_LBB11_13 
kernel_LBB11_6:
kernel_autoL58:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL58))(a0)
	lw	a1, -16(s0) 
	bne	a0, a1, kernel_LBB11_11 
	j	kernel_LBB11_7 
kernel_LBB11_7:
	lw	a1, -16(s0) 
	lw	a0, 0(a1) 
	bne	a0, a1, kernel_LBB11_9 
	j	kernel_LBB11_8 
kernel_LBB11_8:
kernel_autoL59:
	auipc	a1, %hi(%pcrel(process_head))
	li	a0, 0 
	sw	a0, %lo(%larel(process_head,kernel_autoL59))(a1)
	j	kernel_LBB11_10 
kernel_LBB11_9:
	lw	a0, -16(s0) 
	lw	a1, 0(a0) 
kernel_autoL60:
	auipc	a0, %hi(%pcrel(process_head))
	sw	a1, %lo(%larel(process_head,kernel_autoL60))(a0)
	lw	a1, -16(s0) 
	lw	a1, 4(a1) 
	lw	a2, %lo(%larel(process_head,kernel_autoL60))(a0)
	sw	a1, 4(a2) 
	lw	a0, %lo(%larel(process_head,kernel_autoL60))(a0)
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
kernel_autoL61:
	auipc	a0, %hi(%pcrel(kernel_L.str.7))
	addi	a0, a0, %lo(%larel(kernel_L.str.7,kernel_autoL61))
	call	print 
kernel_autoL62:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL62))(a0)
	lw	a0, 16(a0) 
	bnez	a0, kernel_LBB11_15 
	j	kernel_LBB11_14 
kernel_LBB11_14:
kernel_autoL63:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL63))(a0)
	lw	a0, 0(a0) 
kernel_autoL64:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL64))(a1)
	j	kernel_LBB11_15 
kernel_LBB11_15:
kernel_autoL65:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL65))(a0)
	call	jump_to_next_ROM 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end11:
	#	-- End function 
update_curr_process:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
	sw	a0, -12(s0) 
	sw	a1, -16(s0) 
	lw	a0, -16(s0) 
kernel_autoL66:
	auipc	a1, %hi(%pcrel(page_size))
	lw	a1, %lo(%larel(page_size,kernel_autoL66))(a1)
	divu	a0, a0, a1 
kernel_autoL67:
	auipc	a1, %hi(%pcrel(curr_process))
	lw	a2, %lo(%larel(curr_process,kernel_autoL67))(a1)
	sw	a0, 24(a2) 
	lw	a0, -12(s0) 
	lw	a2, %lo(%larel(curr_process,kernel_autoL67))(a1)
	lw	a3, 12(a2) 
	lw	a4, 24(a2) 
	slli	a4, a4, 2 
	add	a3, a3, a4 
	lw	a3, 0(a3) 
	add	a0, a0, a3 
	sw	a0, 20(a2) 
	lw	a0, -16(s0) 
	lw	a1, %lo(%larel(curr_process,kernel_autoL67))(a1)
	lw	a2, 12(a1) 
	lw	a3, 24(a1) 
	slli	a3, a3, 2 
	add	a2, a2, a3 
	lw	a2, 0(a2) 
	add	a0, a0, a2 
	sw	a0, 16(a1) 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end12:
	#	-- End function 
alarm_next_program:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL68:
	auipc	a0, %hi(%pcrel(kernel_L.str.8))
	addi	a0, a0, %lo(%larel(kernel_L.str.8,kernel_autoL68))
	call	print 
kernel_autoL69:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a1, %lo(%larel(curr_process,kernel_autoL69))(a0)
	lw	a1, 0(a1) 
	sw	a1, %lo(%larel(curr_process,kernel_autoL69))(a0)
	lw	a0, %lo(%larel(curr_process,kernel_autoL69))(a0)
	lw	a0, 16(a0) 
	bnez	a0, kernel_LBB13_2 
	j	kernel_LBB13_1 
kernel_LBB13_1:
kernel_autoL70:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL70))(a0)
	lw	a0, 0(a0) 
kernel_autoL71:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL71))(a1)
	j	kernel_LBB13_2 
kernel_LBB13_2:
kernel_autoL72:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL72))(a0)
	call	jump_to_next_ROM 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end13:
	#	-- End function 
restore_sp:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL73:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL73))(a0)
	lw	a0, 16(a0) 
	bnez	a0, kernel_LBB14_2 
	j	kernel_LBB14_1 
kernel_LBB14_1:
kernel_autoL74:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL74))(a0)
	lw	a0, 0(a0) 
kernel_autoL75:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL75))(a1)
	j	kernel_LBB14_2 
kernel_LBB14_2:
kernel_autoL76:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL76))(a0)
	lw	a0, 20(a0) 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end14:
	#	-- End function 
get_base:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL77:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL77))(a0)
	lw	a0, 16(a0) 
	bnez	a0, kernel_LBB15_2 
	j	kernel_LBB15_1 
kernel_LBB15_1:
kernel_autoL78:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL78))(a0)
	lw	a0, 0(a0) 
kernel_autoL79:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL79))(a1)
	j	kernel_LBB15_2 
kernel_LBB15_2:
kernel_autoL80:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a1, %lo(%larel(curr_process,kernel_autoL80))(a0)
	lw	a0, 12(a1) 
	lw	a1, 24(a1) 
	slli	a1, a1, 2 
	add	a0, a0, a1 
	lw	a0, 0(a0) 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end15:
	#	-- End function 
get_limit:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL81:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL81))(a0)
	lw	a0, 16(a0) 
	bnez	a0, kernel_LBB16_2 
	j	kernel_LBB16_1 
kernel_LBB16_1:
kernel_autoL82:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL82))(a0)
	lw	a0, 0(a0) 
kernel_autoL83:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL83))(a1)
	j	kernel_LBB16_2 
kernel_LBB16_2:
kernel_autoL84:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a1, %lo(%larel(curr_process,kernel_autoL84))(a0)
	lw	a0, 12(a1) 
	lw	a1, 24(a1) 
	slli	a1, a1, 2 
	add	a0, a0, a1 
	lw	a0, 0(a0) 
kernel_autoL85:
	auipc	a1, %hi(%pcrel(page_size))
	lw	a1, %lo(%larel(page_size,kernel_autoL85))(a1)
	add	a0, a0, a1 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end16:
	#	-- End function 
zero_page:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
	sw	a0, -12(s0) 
	lw	a0, -12(s0) 
	sw	a0, -16(s0) 
	j	kernel_LBB17_1 
kernel_LBB17_1:
	lw	a0, -16(s0) 
	lw	a1, -12(s0) 
	addi	a1, a1, 1024 
	bgeu	a0, a1, kernel_LBB17_4 
	j	kernel_LBB17_2 
kernel_LBB17_2:
	lw	a1, -16(s0) 
	li	a0, 0 
	sw	a0, 0(a1) 
	j	kernel_LBB17_3 
kernel_LBB17_3:
	lw	a0, -16(s0) 
	addi	a0, a0, 4 
	sw	a0, -16(s0) 
	j	kernel_LBB17_1 
kernel_LBB17_4:
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end17:
	#	-- End function 
create_upt:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
	call	page_alloc 
	sw	a0, -12(s0) 
	lw	a0, -12(s0) 
	call	zero_page 
	lw	a0, -12(s0) 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end18:
	#	-- End function 
set_pte:
	#	%bb.0: 
	addi	sp, sp, -48 
	sw	ra, 44(sp) # 4-byte Folded Spill 
	sw	s0, 40(sp) # 4-byte Folded Spill 
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
	lw	ra, 44(sp) # 4-byte Folded Reload 
	lw	s0, 40(sp) # 4-byte Folded Reload 
	addi	sp, sp, 48 
	ret	
kernel_Lfunc_end19:
	#	-- End function 
find_last_device:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL86:
	auipc	a0, %hi(%pcrel(device_table_base))
	lw	a0, %lo(%larel(device_table_base,kernel_autoL86))(a0)
	sw	a0, -12(s0) 
	li	a0, 0 
	sw	a0, -16(s0) 
	j	kernel_LBB20_1 
kernel_LBB20_1:
	lw	a0, -12(s0) 
	lw	a0, 0(a0) 
kernel_autoL87:
	auipc	a1, %hi(%pcrel(none_device_code))
	lw	a1, %lo(%larel(none_device_code,kernel_autoL87))(a1)
	beq	a0, a1, kernel_LBB20_3 
	j	kernel_LBB20_2 
kernel_LBB20_2:
	lw	a0, -12(s0) 
	sw	a0, -16(s0) 
	lw	a0, -12(s0) 
	addi	a0, a0, 12 
	sw	a0, -12(s0) 
	j	kernel_LBB20_1 
kernel_LBB20_3:
	lw	a0, -16(s0) 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end20:
	#	-- End function 
create_kernel_upt:
	#	%bb.0: 
	addi	sp, sp, -32 
	sw	ra, 28(sp) # 4-byte Folded Spill 
	sw	s0, 24(sp) # 4-byte Folded Spill 
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
kernel_LBB21_1:
	lw	a0, -28(s0) 
	lw	a1, -20(s0) 
	bgeu	a0, a1, kernel_LBB21_4 
	j	kernel_LBB21_2 
kernel_LBB21_2:
	lw	a0, -28(s0) 
	lw	a1, -24(s0) 
	or	a0, a0, a1 
	sw	a0, -32(s0) 
	lw	a0, -12(s0) 
	lw	a1, -28(s0) 
	lw	a2, -32(s0) 
	call	set_pte 
	j	kernel_LBB21_3 
kernel_LBB21_3:
	lw	a0, -28(s0) 
	lui	a1, 1 
	add	a0, a0, a1 
	sw	a0, -28(s0) 
	j	kernel_LBB21_1 
kernel_LBB21_4:
	lw	a0, -12(s0) 
	lw	ra, 28(sp) # 4-byte Folded Reload 
	lw	s0, 24(sp) # 4-byte Folded Reload 
	addi	sp, sp, 32 
	ret	
kernel_Lfunc_end21:
	#	-- End function 
free_head:
	.Numeric
	.byte 0 0 0 0 0 0 0 0 0 0 0 0 
free_tail:
	.byte 0 0 0 0 0 0 0 0 0 0 0 0 
hex_digits:
	.Text
	.ascii	"0123456789abcdef"
heap_limit:
	.Numeric
	.word	0                               # 0x0
RAM_head:
	.word	0
page_size:
	.word	4096                            # 0x1000
process_head:
	.word	0
kernel_L.str:
	.Text
	.asciz	"Searching for ROM #"
kernel_L.str.1:
	.asciz	"\n"
kernel_L.str.2:
	.asciz	"Process not found\n"
program_size:
	.Numeric
	.word	32768                           # 0x8000
kernel_L.str.3:
	.Text
	.asciz	"No more RAM space.\n"
kernel_L.str.4:
	.asciz	"Running program...\n"
curr_process:
	.Numeric
	.word	0
run_programs.next_program_ROM:
	.word	3                               # 0x3
kernel_L.str.5:
	.Text
	.asciz	"Ending current process..."
kernel_L.str.6:
	.asciz	"(last one)"
kernel_L.str.7:
	.asciz	"done.\n"
kernel_L.str.8:
	.asciz	"Alarm interrupt invoked...\nJumping to next program...\n"
	.Numeric
end_of_statics:
	.Text
	.asciz	"end of statics"
