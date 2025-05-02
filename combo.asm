### ================================================================================================================================
### kernel-stub.asm
### Scott F. Kaplan -- sfkaplan@amherst.edu
###
### The assembly core that perform the basic initialization of the kernel, bootstrapping the installation of trap handlers and
### configuring the kernel's memory space.
###
### v.2025-02-11 : Load and execute a sequence of processes.
### v.2025-02-18 : Just the stub code, leaving other functions to be written in C.
### ================================================================================================================================


### ================================================================================================================================
	.Code
### ================================================================================================================================



### ================================================================================================================================
### Entry point.

__start:	
	## Find RAM.  Start the search at the beginning of the device table.
	lw		t0,		device_table_base			# [t0] dt_current = &device_table[0]
	lw		s0,		none_device_code			# [s0] none_device_code
	lw		s1,		RAM_device_code				# [s1] RAM_device_code
	
RAM_search_loop_top:

	## End the search with failure if we've reached the end of the table without finding RAM.
	lw		t1,		0(t0) 					# [t1] device_code = dt_current->type_code
	beq		t1,		s0,		RAM_search_failure 	# if (device_code == none_device_code)

	## If this entry is RAM, then end the loop successfully.
	beq		t1,		s1,		RAM_found 		# if (device_code == RAM_device_code)

	## This entry is not RAM, so advance to the next entry.
	addi		t0,		t0,		12 			# [t0] dt_current += dt_entry_size
	j		RAM_search_loop_top

RAM_search_failure:

	## Record a code to indicate the error, and then halt.
	lw		a0,		kernel_error_RAM_not_found
	halt

RAM_found:
	
	## RAM has been found.  If it is big enough, create a stack.
	lw		t1,		4(t0) 					# [t1] RAM_base  = dt_RAM->base
	lw		t2,		8(t0)					# [t2] RAM_limit = dt_RAM->limit
	sub		t0,		t2,		t1			# [t0] |RAM| = RAM_limit - RAM_base
	lw		t3,		min_RAM					# [t3] min_RAM
	blt		t0,		t3,		RAM_too_small		# if (|RAM| < min_RAM) ...
	lw		t3,		kernel_size				# [t3] ksize
	add		sp,		t1,		t3			# [sp] klimit = RAM_base + ksize : new stack
	mv		fp,		sp					# Initialize fp

	## Copy the RAM and kernel bases and limits to statically allocated spaces.
	sw		t1,		RAM_base,	t6
	sw		t2,		RAM_limit,	t6
	sw		t1,		kernel_base,	t6	
	sw		sp,		kernel_limit,	t6
	la		t3,		end_of_statics				# Load the address of the end_of_statics label into t3
	sw		t3,		statics_limit,	t6			# Store the t3 label into the statics_limit statically allocated variable

	## Grab the DMA portal's address for later.
	lw		t0,		device_table_base			# [t0] device_table_base
	lw		t0,		8(t0)					# [t0] device_table_limit
	addi		t0,		t0,		-12			# [t0] DMA_portal_ptr
	sw		t0,		DMA_portal_ptr,	t6

	## With the stack initialized, call main() to begin booting proper.
	call		main

	## End the kernel.  Termination code has already been returned by main() in a0.
	halt

RAM_too_small:
	## Set an error code and halt.
	lw		a0,		kernel_error_small_RAM
	halt
### ================================================================================================================================



### ================================================================================================================================	
### Procedure: find_device
### Parameters:
###   [a0]: type     -- The device type to find.
###   [a1]: instance -- The instance of the given device type to find (e.g., the 3rd ROM).
### Caller preserved registers:
###   [s0/fp + 0]: pfp
### Return address (preserved if needed):
###   [s0/fp + 4]: pra
### Return value:
###   [a0]: If found, a pointer to the correct device table entry, otherwise, null.
### Locals:
###   [t0]: current_ptr  -- The current pointer into the device table.
###   [t1]: current_type -- The current entry's device type.
###   [t2]: none_type    -- The null device type code.

find_device:

	## No calls nor values pushed onto the stack, so no prologue needed.
	
	##   Initialize the locals.
	lw		t0,		device_table_base				# current_ptr = dt_base
	lw		t2,		none_device_code				# none_type
	
find_device_loop_top:

	## End the search with failure if we've reached the end of the table without finding the device.
	lw		t1,		0(t0)						# current_type = current_ptr->type
	beq		t1,		t2,		find_device_loop_failure	# while (current_type == none_type) {

	## If this entry matches the device type we seek, then decrement the instance count.  If the instance count hits zero, then
	## the search ends successfully.
	bne		t1,		a0,		find_device_continue_loop	#   if (current_type == type) {
	addi		a1,		a1,		-1				#     instance--
	beqz		a1,		find_device_loop_success			#     if (instance == 0) break }
	
find_device_continue_loop:	

	## Advance to the next entry.
	addi		t0,		t0,		12				#   current_ptr++
	j		find_device_loop_top						# }

find_device_loop_failure:

	## Set the return value to a null pointer.
	li		a0,		0						# rv = null
	j		find_device_return

find_device_loop_success:

	## Set the return pointer into the device table that currently points to the given iteration of the given type.
	mv		a0,		t0						# rv = current_ptr
	## Fall through...
	
find_device_return:

	## Epilogue: Return.
	ret
### ================================================================================================================================



### ================================================================================================================================
### Procedure: print
### Preserved registers:
###   [fp + 0]: pfp
### Parameters:
###   [a0]: str_ptr -- A pointer to the beginning of a null-terminated string.
### Return address:
###   [ra / fp + 4]
### Return value:
###   <none>
### Preserved registers:
###   [fp -  4]: a0
###   [fp -  8]: s1
###   [fp - 12]: s2
###   [fp - 16]: s3
###   [fp - 20]: s4
###   [fp - 24]: s5
###   [fp - 28]: s6
### Locals:
###   [s1]: current_ptr        -- Pointer to the current position in the string.
###   [s2]: console_buffer_end -- The console buffer's limit.
###   [s3]: cursor_column      -- The current cursor column (always on the bottom row).
###   [s4]: newline_char       -- A copy of the newline character.
###   [s5]: cursor_char        -- A copy of the cursor character.
###   [s6]: console_width      -- The console's width.
	
print:

	## Callee prologue: Push preserved registers.
	addi		sp,		sp,		-32
	sw		ra,		28(sp)					# Preserve ra
	sw		fp,		24(sp)					# Preserve fp
	sw		s1,		20(sp)
	sw		s2,		16(sp)
	sw		s3,		12(sp)
	sw		s4,		8(sp)
	sw		s5,		4(sp)
	sw		s6,		0(sp)
	addi		fp,		sp,		32

	## Initialize locals.
	mv		s1,		a0					# current_ptr = str_ptr
	lw		s2,		console_limit				# console_limit
	addi		s2,		s2,		-4			# console_buffer_end = console_limit - |word|
										#   (offset portal)
	lw		s3,		cursor_column				# cursor_column
	lb		s4,		newline_char
	lb		s5,		cursor_char
	lw		s6,		console_width

	## Loop through the characters of the given string until the terminating null character is found.
loop_top:
	lb		t0,		0(s1)					# [t0] current_char = *current_ptr

	## The loop should end if this is a null character
	beqz		t0,		loop_end

	## Scroll without copying the character if this is a newline.
	beq		t0,		s4,		_print_scroll_call

	## Assume that the cursor is in a valid location.  Copy the current character into it.
	sub		t1,		s2,		s6			# [t0] = console[limit] - width
	add		t1,		t1,		s3			#      = console[limit] - width + cursor_column
	sb		t0,		0(t1)					# Display current char @t1.
	
	## Advance the cursor, scrolling if necessary.
	addi		s3,		s3,		1			# cursor_column++
	blt		s3,		s6,		_print_scroll_end       # Skip scrolling if cursor_column < width

_print_scroll_call:
	sw		s3,		cursor_column,	t6			# Copy back global used by scroll_console()
	call		scroll_console
	lw		s3,		cursor_column				# Reload global updated by scroll_console()

_print_scroll_end:
	## Place the cursor character in its new position.
	sub		t1,		s2,		s6			# [t1] = console[limit] - width
	add		t1,		t1,		s3			#      = console[limit] - width + cursor_column
	sb		s5,		0(t1)					# Display cursor char @t1.
	
	## Iterate by advancing to the next character in the string.
	addi		s1,		s1,		1
	j		loop_top

loop_end:
	## Callee Epilogue...
	
	##   Store cursor_column back into statics for the next call.
	sw		s3,		cursor_column,	t6			# Store cursor_column (static)
	
	##   Pop and restore preserved registers, then return.
	addi		sp,		fp,		-32			# Pop extras that may have been added to the stack.
	lw		s6,		0(sp)					# Restore s[1-6]
	lw		s5,		4(sp)
	lw		s4,		8(sp)
	lw		s3,		12(sp)
	lw		s2,		16(sp)
	lw		s1,		20(sp)
	lw		fp,		24(sp)					# Restore fp
	lw		ra,		28(sp)					# Restore ra
	addi		sp,		sp,		32
	ret
### ================================================================================================================================

	

### ================================================================================================================================
### Procedure: scroll_console
### Description: Scroll the console and reset the cursor at the 0th column.
### Preserved frame pointer:
###   [fp + 0]: pfp
### Parameters:
###   <none>
### Return address:
###   [fp + 4]
### Return value:
###   <none>
### Locals:
###   [t0]: console_buffer_end / console_offset_ptr
###   [t1]: console_width
###   [t2]: console_buffer_begin
###   [t3]: cursor_column
###   [t4]: screen_size	
	
scroll_console:

	## No calls performed, no values pushed onto the stack, so no frame created.
	
	## Initialize locals.
	lw		t2,		console_base				# console_buffer_begin = console_base
	lw		t0,		console_limit				# console_limit
	addi		t0,		t0,		-4			# console_buffer_end = console_limit - |word|
	                                                                        #   (offset portal)
	lw		t1,		console_width				# console_width
	lw		t3,		cursor_column				# cursor_column
	lw		t4,		console_height				# t4 = console_height
	mul		t4,		t1,		t4			# screen_size = console_width * console_height
	
	## Blank the top line.
	lw		t5,		device_table_base       	        # t5 = dt_controller_ptr
	lw		t5,		8(t5)					#    = dt_controller_ptr->limit
	addi		t5,		t5,		-12			# DMA_portal_ptr = dt_controller_ptr->limit - 3*|word|
	la		t6,		blank_line				# t6 = &blank_line
	sw		t6,		0(t5)					# DMA_portal_ptr->src = &blank_line
	sw		t2,		4(t5)					# DMA_portal_ptr->dst = console_buffer_begin
	sw		t1,		8(t5)					# DMA_portal_ptr->len = console_width

	## Clear the cursor if it isn't off the end of the line.
	beq		t1,		t3,		_scroll_console_update_offset	# Skip if width == cursor_column
	sub		t5,		t0,		t1			# t5 = console_buffer_end - width
	add		t5,		t5,		t3			#    = console_buffer_end - width + cursor_column
	lb		t6,		space_char
	sb		t6,		0(t5)

	## Update the offset, wrapping around if needed.
_scroll_console_update_offset:
	lw		t6,		0(t0)					# [t6] offset
	add		t6,		t6,		t1			# offset += column_width
	rem		t6,		t6,		t4			# offset %= screen_size
	sw		t6,		0(t0)					# Set offset in console
	
	## Reset the cursor at the start of the new line.
	li		t3,		0					# cursor_column = 0
	sw		t3,		cursor_column,	t6			# Store cursor_column
	lb		t6,		cursor_char				# cursor_char
	sub		t5,		t0,		t1			# t5 = console_buffer_end - width (cursor_column == 0)	
	sb		t6,		0(t5)
	
	## Return.
	ret
### ================================================================================================================================



### ================================================================================================================================
### Procedure: do_exit

do_exit:

	## Prologue.
	addi		sp,		sp,		-8
	sw		ra,		4(sp)						# Preserve ra
	sw		fp,		0(sp)						# Preserve fp
	addi		fp,		sp,		8				# Set fp
	
	## Show that we got here.
	la		a0,		exit_msg					# Print EXIT occurrence.
	call	print

	## Remove process from the process table and free RAM space
	call 	end_process

	## Epilogue: If we are here, no program ran, so restore and return.
	lw		ra,		4(sp)						# Restore ra
	lw		fp,		0(sp)						# Restore fp
	addi		sp,		sp,		8
	ret
### ================================================================================================================================


	
### ================================================================================================================================
### Procedure: syscall_handler

syscall_handler:	
	
	# reset mode register
	addi  	t0, zero,	12
	csrw 	md,		t0
	# keep the sp and fp of the process to be used as arguments
	add 	t0, 	sp, 	zero
	csrr 	t1, 	epc
	addi 	t1, 	t1, 	4

	# restore kernel stack and kernel frame
	lw 		sp, 	kernel_limit
	lw		fp,		kernel_limit

	addi 	sp, 	sp,		-8
	sw 		a0,		0(sp)
	sw 		a1, 	4(sp)

	add 	a0,		t0, 	zero
	add 	a1, 	t1,		zero

	call 	update_curr_process

	lw 		a0,		0(sp)
	lw		a1,		4(sp)

	## Dispatch on the requested syscall.
	lw		t0,		syscall_EXIT
	beq		a0,		t0,		handle_exit			# Is it an EXIT request?

	lw      t0,     syscall_RUN
	beq     a0,     t0,     handle_run          # Is it a RUN request?

	lw		t0, 	syscall_PRINT
	beq 	a0,		t0,		handle_print		# Is it a PRINT request?
	## The syscall code is invalid, so print an error message and halt.
	la		a0,		invalid_syscall_code_msg			# Print failure.
	call		print
	j		syscall_handler_halt



handle_run:
	
	mv 		a0, 	a1
	call 	run_ROM
	j 		syscall_handler_halt

handle_print:

	mv 		a0, 	a1

	# preserve address of string
	addi 	sp, 	sp, 	-4
	sw 		a0,		0(sp)   

	# convert string address into physical
	call 	get_base
	lw 		t0,   	0(sp)
	add 	a0, 	t0, 	a0
	# restore stack
	addi 	sp, 	sp,  	4

	call print
	lw		a0,		curr_process
	call 	jump_to_next_ROM

	j syscall_handler_halt

handle_exit:

	## An exit was requested.  Move onto the next ROM.
	call		do_exit

	## If we are here, then the end of the ROMs was reached.
	la		a0,		all_programs_run_msg
	call		print

	## Fall through...

syscall_handler_halt:
	
	## Halt.  No need to preserve/restore state, because we're halting.
	la		a0,		halting_msg					# Print halting.
	call		print
	halt
	
### ================================================================================================================================

alarm_handler:

	# reset mode register
	addi  	t0, 	zero,	12
	csrw 	md,		t0
	# keep the sp and fp of the process to be used as arguments
	add 	t0, 	sp, 	zero
	csrr 	t1, 	epc
	addi 	t1, 	t1, 	4

	# restore kernel stack and kernel frame
	lw 		sp, 	kernel_limit
	lw		fp,		kernel_limit

	addi 	sp, 	sp,		-8
	sw 		a0,		0(sp)
	sw 		a1, 	4(sp)

	add 	a0,		t0, 	zero
	add 	a1, 	t1,		zero

	call 	update_curr_process

	lw 		a0,		0(sp)
	lw		a1,		4(sp)

	# adjusting quanta + calling next program
	call alarm_next_program

	
### ================================================================================================================================
### Procedure: default_handler

default_handler:

	# reset mode register
	addi  	t0, zero, 	12
	csrw 	md,		t0
	# If we are here, we probably want to look around.
	ebreak
	
	# restore kernel stack and kernel frame
	lw 		sp, 	kernel_limit
	lw		fp,		kernel_limit
	
	## Print a message to show that we got here.
	la		a0,		default_handler_msg
	call		print
	
	## Then halt, because we don't know what to do next.
	la		a0,		halting_msg
	call		print
	lw		a0,		kernel_error_unmanaged_interrupt
	halt
### ================================================================================================================================


	
### ================================================================================================================================
### Procedure: init_trap_table
### Caller preserved registers:	
###   [fp + 0]:      pfp
###   [ra / fp + 4]: pra
### Parameters:
###   [a0]: trap_base -- The address of the trap table to initialize and enable.
### Return value:
###   <none>
### Callee preserved registers:
###   <none>
### Locals:
###   [t0]: default_handler_ptr -- A pointer to the default interrupt handler

init_trap_table:

	## Set the 13 entries to point to some interrupt handler.
	la		t0,		default_handler				# t0 = default_handler()
	la		t1,		syscall_handler				# t1 = syscall_handler()
	la      t2,		alarm_handler
	sw		t0,		0x00(a0)				# tt[INVALID_ADDRESS]      = default_handler()
	sw		t0,		0x04(a0)				# tt[INVALID_REGISTER]     = default_handler()
	sw		t0,		0x08(a0)				# tt[BUS_ERROR]            = default_handler()
	sw		t2,		0x0c(a0)				# tt[CLOCK_ALARM]          = default_handler()
	sw		t0,		0x10(a0)				# tt[DIVIDE_BY_ZERO]       = default_handler()
	sw		t0,		0x14(a0)				# tt[OVERFLOW]             = default_handler()
	sw		t0,		0x18(a0)				# tt[INVALID_INSTRUCTION]  = default_handler()
	sw		t0,		0x1c(a0)				# tt[PERMISSION_VIOLATION] = default_handler()
	sw		t0,		0x20(a0)				# tt[INVALID_SHIFT_AMOUNT] = default_handler()
	sw		t1,		0x24(a0)				# tt[SYSTEM_CALL]          = syscall_handler()
	sw		t0,		0x28(a0)				# tt[SYSTEM_BREAK]         = default_handler()
	sw		t0,		0x2c(a0)				# tt[INVALID_DEVICE_VALUE] = default_handler()
	sw		t0,		0x30(a0)				# tt[DEVICE_FAILURE]       = default_handler()

	## Set the TBR to point to the trap table, and the IBR to point to the interrupt buffer.
	csrw		tb,		a0					# tb = trap_base
	ret
### ================================================================================================================================



### ================================================================================================================================
### Procedure: userspace_jump

userspace_jump:
	addi		sp,		sp,		-4
	sw			a0,		0(sp)

	lw		t0,		0(sp)
	sub		a0,		t0,		a0
	csrw		epc,		a0
	
	call restore_sp
	add		sp,			zero, 			a0
	call	get_base

	sub		sp,			sp,				a0

	# set quanta
	csrr 	t0,		ck
	lw 		t1,		alarm_quanta
	add 	t0, 	t1,		t0
	csrw 	al,		t0

	# enable alarm and virtual addressing
	addi 	t0,		zero, 	28
	csrw 	md,		t0
	#load base and limit values to bs and lm, for mmu
	#activate virtual addressing and alarm and then jump
	eret
### ================================================================================================================================
	

ebreak_wrap:
	ebreak
	ret

	
### ================================================================================================================================
### Procedure: main
### Preserved registers:
###   [fp + 0]:      pfp
###   [ra / fp + 4]: pra
### Parameters:
###   <none>
### Return value:
###   [a0]: exit_code
### Preserved registers:
###   <none>
### Locals:
###   <none>

main:

	## Prologue.
	addi		sp,		sp,		-8
	sw		ra,		4(sp)						# Preserve ra
	sw		fp,		0(sp)						# Preserve fp
	addi		fp,		sp,		8				# Set fp

	## Call find_device() to get console info.
	lw		a0,		console_device_code				# arg[0] = console_device_code
	li		a1,		1						# arg[1] = 1 (first instance)
	call		find_device							# [a0] rv = dt_console_ptr
	bnez		a0,		main_with_console				# if (dt_console_ptr == NULL) ...
	lw		a0,		kernel_error_console_not_found			# Return with failure code
	halt

main_with_console:
	## Copy the console base and limit into statics for later use.
	lw		t0,		4(a0)						# [t0] dt_console_ptr->base
	sw		t0,		console_base,		t6
	lw		t0,		8(a0)						# [t0] dt_console_ptr->limit
	sw		t0,		console_limit,		t6
	
	## Call print() on the banner and attribution.
	la		a0,		banner_msg					# arg[0] = banner_msg
	call		print
	la		a0,		attribution_msg					# arg[0] = attribution_msg
	call		print


	## Call init_trap_table(), then finally restore the frame.
	la		a0,		initializing_tt_msg				# arg[0] = initializing_tt_msg
	call		print
	la		a0,		trap_table
	call		init_trap_table
	la		a0,		done_msg					# arg[0] = done_msg
	call		print



	## Call ram_init()
	la 		a0, 	initializing_ram_list_msg
	call 	print
	call 	ram_init
	la 		a0, 	done_msg
	call 	print

		## Transition into virtual addressing 
	la 		a0, 	initialzing_kernel_pt_msg
	call 	print
	call 	create_kernel_upt
	csrw 	pt, 	a0
	sw		a0, 	kernel_upt_ptr,	t6
	addi 	t0, 	zero, 	12
	csrw 	md, 	t0
	la 		a0, 	done_msg
	call 	print

	## Call process_head_init()
	la 		a0, 	initializing_process_head_msg
	call 	print
	call 	process_head_init
	la 		a0, 	done_msg
	call 	print

	## Call run_programs() to invoke each program ROM in turn.
	call		run_programs
	
	## Epilogue: If we reach here, there were no ROMs, so use the frame to emit an error message and halt.
	la		a0,		no_programs_msg
	call		print
	la		a0,		halting_msg
	call		print
	lw		a0,		kernel_normal_exit				# Set the result code
	halt
### ================================================================================================================================
	

	
### ================================================================================================================================
	.Numeric

	## A special marker that indicates the beginning of the statics.  The value is just a magic cookie, in case any code wants
	## to check that this is the correct location (with high probability).
statics_start_marker:	0xdeadcafe

	## The trap table.  An array of 13 function pointers, to be initialized at runtime.
trap_table:             0
			0
			0
			0
			0
			0
			0
			0
			0
			0
			0
			0
			0

	## The interrupt buffer, used to store auxiliary information at the moment of an interrupt.
interrupt_buffer:	0 0 
	
	## Device table location and codes.
device_table_base:	0x00001000
none_device_code:	0
controller_device_code:	1
ROM_device_code:	2
RAM_device_code:	3
console_device_code:	4
block_device_code:	5

	## Error codes.
kernel_normal_exit:			0xffff0000
kernel_error_RAM_not_found:		0xffff0001
kernel_error_small_RAM:			0xffff0002	
kernel_error_console_not_found:		0xffff0003
kernel_error_unmanaged_interrupt:	0xffff0004

	## Syscall codes
syscall_EXIT:		0xca110001
syscall_RUN:        0xca110002
syscall_PRINT:      0xca110003
	
	## Constants for printing and console management.
console_width:		80
console_height:		24

	## Other constants.
min_RAM:		0x10000 # 64 KB = 0x40 KB * 0x400 B/KB
bytes_per_page:		0x1000	# 4 KB/page
kernel_size:		0x8000	# 32 KB = 0x20 KB * 0x4 B/KB taken by the kernel.

	## Statically allocated variables.
cursor_column:		0	# The column position of the cursor (always on the last row).
RAM_base:		0
RAM_limit:		0
console_base:		0
console_limit:		0
kernel_base:		0
kernel_limit:		0
DMA_portal_ptr:		0
statics_limit:		0	#store the limit of the kernel statics
alarm_quanta:		1000

## project 3
kernel_upt_ptr:		0
### ================================================================================================================================



### ================================================================================================================================
	.Text

space_char:			" "
cursor_char:			"_"
newline_char:			"\n"
banner_msg:			"Fivish kernel v.2025-03-02\n"
attribution_msg:		"COSC-275 : Systems-II\n"
halting_msg:			"Halting kernel..."
initializing_tt_msg:		"Initializing trap table..."
running_program_msg:		"Running next program ROM...\n"
invalid_syscall_code_msg:	"Invalid syscall code provided.\n"
exit_msg:			"EXIT requested.\n"
all_programs_run_msg:		"All programs have been run.\n"
no_programs_msg:		"ERROR: No programs provided.\n"
default_handler_msg:		"Default interrupt handler invoked.\n"
initializing_ram_list_msg:  "Initializing RAM free block..."
initializing_process_head_msg: "Initializing process list head..."
initialzing_kernel_pt_msg:  	"Initializing kernel upper page table..."
done_msg:			"done.\n"
failed_msg:			"failed!\n"
blank_line:			"                                                                                "
### ================================================================================================================================
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
	li	a0, 32 
	call	heap_alloc 
kernel_autoL29:
	auipc	a1, %hi(%pcrel(process_head))
	sw	a1, -12(s0) # 4-byte Folded Spill 
	sw	a0, %lo(%larel(process_head,kernel_autoL29))(a1)
	lw	a0, %lo(%larel(process_head,kernel_autoL29))(a1)
	sw	a0, 4(a0) 
	lw	a0, %lo(%larel(process_head,kernel_autoL29))(a1)
	sw	a0, 0(a0) 
	lw	a2, %lo(%larel(process_head,kernel_autoL29))(a1)
	li	a0, 0 
	sw	a0, 24(a2) 
	lw	a2, %lo(%larel(process_head,kernel_autoL29))(a1)
	sw	a0, 20(a2) 
	lw	a2, %lo(%larel(process_head,kernel_autoL29))(a1)
	sw	a0, 8(a2) 
	lw	a1, %lo(%larel(process_head,kernel_autoL29))(a1)
	sw	a0, 28(a1) 
kernel_autoL30:
	auipc	a0, %hi(%pcrel(kernel_upt_ptr))
	lw	a0, %lo(%larel(kernel_upt_ptr,kernel_autoL30))(a0)
	call	create_process_upt 
	mv	a1, a0 
	lw	a0, -12(s0) # 4-byte Folded Reload 
	lw	a2, %lo(%larel(process_head,kernel_autoL29))(a0)
	sw	a1, 16(a2) 
	lw	a0, %lo(%larel(process_head,kernel_autoL29))(a0)
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end7:
	#	-- End function 
create_process_upt:
	#	%bb.0: 
	addi	sp, sp, -32 
	sw	ra, 28(sp) # 4-byte Folded Spill 
	sw	s0, 24(sp) # 4-byte Folded Spill 
	addi	s0, sp, 32 
	sw	a0, -12(s0) 
	call	create_upt 
	sw	a0, -16(s0) 
	li	a0, 0 
	sw	a0, -20(s0) 
	j	kernel_LBB8_1 
kernel_LBB8_1:
	lw	a1, -20(s0) 
	li	a0, 511 
	blt	a0, a1, kernel_LBB8_4 
	j	kernel_LBB8_2 
kernel_LBB8_2:
	lw	a0, -12(s0) 
	lw	a1, -20(s0) 
	slli	a2, a1, 2 
	add	a0, a0, a2 
	lw	a0, 0(a0) 
	lw	a1, -16(s0) 
	add	a1, a1, a2 
	sw	a0, 0(a1) 
	j	kernel_LBB8_3 
kernel_LBB8_3:
	lw	a0, -20(s0) 
	addi	a0, a0, 4 
	sw	a0, -20(s0) 
	j	kernel_LBB8_1 
kernel_LBB8_4:
	lw	a0, -16(s0) 
	lw	ra, 28(sp) # 4-byte Folded Reload 
	lw	s0, 24(sp) # 4-byte Folded Reload 
	addi	sp, sp, 32 
	ret	
kernel_Lfunc_end8:
	#	-- End function 
jump_to_next_ROM:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
	sw	a0, -12(s0) 
	lw	a0, -12(s0) 
	lw	a0, 20(a0) 
	call	userspace_jump 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end9:
	#	-- End function 
run_ROM:
	#	%bb.0: 
	addi	sp, sp, -64 
	sw	ra, 60(sp) # 4-byte Folded Spill 
	sw	s0, 56(sp) # 4-byte Folded Spill 
	addi	s0, sp, 64 
	sw	a0, -12(s0) 
kernel_autoL31:
	auipc	a0, %hi(%pcrel(kernel_L.str))
	addi	a0, a0, %lo(%larel(kernel_L.str,kernel_autoL31))
	call	print 
	lw	a0, -12(s0) 
	addi	a1, s0, -21 
	sw	a1, -52(s0) # 4-byte Folded Spill 
	call	int_to_hex 
	lw	a0, -52(s0) # 4-byte Folded Reload 
	call	print 
kernel_autoL32:
	auipc	a0, %hi(%pcrel(kernel_L.str.1))
	addi	a0, a0, %lo(%larel(kernel_L.str.1,kernel_autoL32))
	call	print 
kernel_autoL33:
	auipc	a0, %hi(%pcrel(ROM_device_code))
	lw	a0, %lo(%larel(ROM_device_code,kernel_autoL33))(a0)
	lw	a1, -12(s0) 
	call	find_device 
	sw	a0, -28(s0) 
	lw	a0, -28(s0) 
	bnez	a0, kernel_LBB10_2 
	j	kernel_LBB10_1 
kernel_LBB10_1:
kernel_autoL34:
	auipc	a0, %hi(%pcrel(kernel_L.str.2))
	addi	a0, a0, %lo(%larel(kernel_L.str.2,kernel_autoL34))
	call	print 
	j	kernel_LBB10_17 
kernel_LBB10_2:
	li	a0, 4 
	call	heap_alloc 
	sw	a0, -32(s0) 
	li	a0, 0 
	sw	a0, -36(s0) 
	j	kernel_LBB10_3 
kernel_LBB10_3:
	lw	a0, -36(s0) 
kernel_autoL35:
	auipc	a1, %hi(%pcrel(program_size))
	lw	a1, %lo(%larel(program_size,kernel_autoL35))(a1)
kernel_autoL36:
	auipc	a2, %hi(%pcrel(page_size))
	lw	a2, %lo(%larel(page_size,kernel_autoL36))(a2)
	divu	a1, a1, a2 
	bge	a0, a1, kernel_LBB10_8 
	j	kernel_LBB10_4 
kernel_LBB10_4:
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
	bnez	a0, kernel_LBB10_6 
	j	kernel_LBB10_5 
kernel_LBB10_5:
kernel_autoL37:
	auipc	a0, %hi(%pcrel(kernel_L.str.3))
	addi	a0, a0, %lo(%larel(kernel_L.str.3,kernel_autoL37))
	call	print 
	call	syscall_handler_halt 
	j	kernel_LBB10_6 
kernel_LBB10_6:
	j	kernel_LBB10_7 
kernel_LBB10_7:
	lw	a0, -36(s0) 
	addi	a0, a0, 1 
	sw	a0, -36(s0) 
	j	kernel_LBB10_3 
kernel_LBB10_8:
kernel_autoL38:
	auipc	a0, %hi(%pcrel(kernel_L.str.4))
	addi	a0, a0, %lo(%larel(kernel_L.str.4,kernel_autoL38))
	call	print 
	li	a0, 32 
	call	heap_alloc 
	sw	a0, -40(s0) 
	call	ebreak_wrap 
kernel_autoL39:
	auipc	a0, %hi(%pcrel(kernel_upt_ptr))
	lw	a0, %lo(%larel(kernel_upt_ptr,kernel_autoL39))(a0)
	call	create_process_upt 
kernel_autoL40:
	auipc	a1, %hi(%pcrel(process_head))
	lw	a1, %lo(%larel(process_head,kernel_autoL40))(a1)
	sw	a0, 16(a1) 
	call	ebreak_wrap 
	lw	a0, -28(s0) 
	lw	a0, 4(a0) 
	sw	a0, -44(s0) 
	li	a0, 0 
	sw	a0, -48(s0) 
	j	kernel_LBB10_9 
kernel_LBB10_9:
	lw	a0, -48(s0) 
kernel_autoL41:
	auipc	a1, %hi(%pcrel(program_size))
	lw	a1, %lo(%larel(program_size,kernel_autoL41))(a1)
kernel_autoL42:
	auipc	a2, %hi(%pcrel(page_size))
	lw	a2, %lo(%larel(page_size,kernel_autoL42))(a2)
	divu	a1, a1, a2 
	bge	a0, a1, kernel_LBB10_12 
	j	kernel_LBB10_10 
kernel_LBB10_10:
	lw	a1, -44(s0) 
	lw	a2, -48(s0) 
kernel_autoL43:
	auipc	a0, %hi(%pcrel(page_size))
	lw	a3, %lo(%larel(page_size,kernel_autoL43))(a0)
	mul	a2, a2, a3 
	add	a2, a1, a2 
kernel_autoL44:
	auipc	a1, %hi(%pcrel(DMA_portal_ptr))
	lw	a3, %lo(%larel(DMA_portal_ptr,kernel_autoL44))(a1)
	sw	a2, 0(a3) 
	lw	a2, -32(s0) 
	lw	a3, -48(s0) 
	slli	a3, a3, 2 
	add	a2, a2, a3 
	lw	a2, 0(a2) 
	lw	a3, %lo(%larel(DMA_portal_ptr,kernel_autoL44))(a1)
	sw	a2, 4(a3) 
	lw	a0, %lo(%larel(page_size,kernel_autoL43))(a0)
	lw	a1, %lo(%larel(DMA_portal_ptr,kernel_autoL44))(a1)
	sw	a0, 8(a1) 
	j	kernel_LBB10_11 
kernel_LBB10_11:
	lw	a0, -48(s0) 
	addi	a0, a0, 1 
	sw	a0, -48(s0) 
	j	kernel_LBB10_9 
kernel_LBB10_12:
	lw	a0, -12(s0) 
	lw	a1, -40(s0) 
	sw	a0, 8(a1) 
	lw	a0, -32(s0) 
	lw	a1, -40(s0) 
	sw	a0, 12(a1) 
kernel_autoL45:
	auipc	a0, %hi(%pcrel(program_size))
	lw	a0, %lo(%larel(program_size,kernel_autoL45))(a0)
	lw	a1, -40(s0) 
	sw	a0, 24(a1) 
	lw	a1, -40(s0) 
	li	a0, 0 
	sw	a0, 20(a1) 
	lw	a1, -40(s0) 
	sw	a0, 28(a1) 
	lw	a0, -40(s0) 
kernel_autoL46:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL46))(a1)
kernel_autoL47:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a1, %lo(%larel(process_head,kernel_autoL47))(a0)
	lw	a1, 0(a1) 
	lw	a2, -40(s0) 
	sw	a1, 0(a2) 
	lw	a1, %lo(%larel(process_head,kernel_autoL47))(a0)
	lw	a2, -40(s0) 
	sw	a1, 4(a2) 
	lw	a1, %lo(%larel(process_head,kernel_autoL47))(a0)
	lw	a0, 0(a1) 
	beq	a0, a1, kernel_LBB10_14 
	j	kernel_LBB10_13 
kernel_LBB10_13:
	lw	a0, -40(s0) 
kernel_autoL48:
	auipc	a1, %hi(%pcrel(process_head))
	lw	a1, %lo(%larel(process_head,kernel_autoL48))(a1)
	lw	a1, 0(a1) 
	sw	a0, 4(a1) 
	j	kernel_LBB10_14 
kernel_LBB10_14:
	lw	a1, -40(s0) 
kernel_autoL49:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a2, %lo(%larel(process_head,kernel_autoL49))(a0)
	sw	a1, 0(a2) 
	lw	a1, %lo(%larel(process_head,kernel_autoL49))(a0)
	lw	a0, 4(a1) 
	bne	a0, a1, kernel_LBB10_16 
	j	kernel_LBB10_15 
kernel_LBB10_15:
	lw	a0, -40(s0) 
kernel_autoL50:
	auipc	a1, %hi(%pcrel(process_head))
	lw	a1, %lo(%larel(process_head,kernel_autoL50))(a1)
	sw	a0, 4(a1) 
	j	kernel_LBB10_16 
kernel_LBB10_16:
kernel_autoL51:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL51))(a0)
	call	jump_to_next_ROM 
	j	kernel_LBB10_17 
kernel_LBB10_17:
	lw	ra, 60(sp) # 4-byte Folded Reload 
	lw	s0, 56(sp) # 4-byte Folded Reload 
	addi	sp, sp, 64 
	ret	
kernel_Lfunc_end10:
	#	-- End function 
run_programs:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL52:
	auipc	a2, %hi(%pcrel(run_programs.next_program_ROM))
	lw	a0, %lo(%larel(run_programs.next_program_ROM,kernel_autoL52))(a2)
	addi	a1, a0, 1 
	sw	a1, %lo(%larel(run_programs.next_program_ROM,kernel_autoL52))(a2)
	call	run_ROM 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end11:
	#	-- End function 
end_process:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL53:
	auipc	a0, %hi(%pcrel(kernel_L.str.5))
	addi	a0, a0, %lo(%larel(kernel_L.str.5,kernel_autoL53))
	call	print 
	li	a0, 0 
	sw	a0, -12(s0) 
	j	kernel_LBB12_1 
kernel_LBB12_1:
	lw	a0, -12(s0) 
kernel_autoL54:
	auipc	a1, %hi(%pcrel(program_size))
	lw	a1, %lo(%larel(program_size,kernel_autoL54))(a1)
kernel_autoL55:
	auipc	a2, %hi(%pcrel(page_size))
	lw	a2, %lo(%larel(page_size,kernel_autoL55))(a2)
	divu	a1, a1, a2 
	bge	a0, a1, kernel_LBB12_4 
	j	kernel_LBB12_2 
kernel_LBB12_2:
kernel_autoL56:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL56))(a0)
	lw	a0, 12(a0) 
	lw	a1, -12(s0) 
	slli	a1, a1, 2 
	add	a0, a0, a1 
	lw	a0, 0(a0) 
	call	ram_free 
	j	kernel_LBB12_3 
kernel_LBB12_3:
	lw	a0, -12(s0) 
	addi	a0, a0, 1 
	sw	a0, -12(s0) 
	j	kernel_LBB12_1 
kernel_LBB12_4:
kernel_autoL57:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a1, %lo(%larel(curr_process,kernel_autoL57))(a0)
	sw	a1, -16(s0) 
	lw	a1, %lo(%larel(curr_process,kernel_autoL57))(a0)
	lw	a1, 0(a1) 
	sw	a1, %lo(%larel(curr_process,kernel_autoL57))(a0)
	lw	a1, %lo(%larel(curr_process,kernel_autoL57))(a0)
	lw	a0, 0(a1) 
	lw	a1, 4(a1) 
	bne	a0, a1, kernel_LBB12_6 
	j	kernel_LBB12_5 
kernel_LBB12_5:
kernel_autoL58:
	auipc	a1, %hi(%pcrel(process_head))
	li	a0, 0 
	sw	a0, %lo(%larel(process_head,kernel_autoL58))(a1)
kernel_autoL59:
	auipc	a0, %hi(%pcrel(kernel_L.str.6))
	addi	a0, a0, %lo(%larel(kernel_L.str.6,kernel_autoL59))
	call	print 
kernel_autoL60:
	auipc	a0, %hi(%pcrel(kernel_L.str.7))
	addi	a0, a0, %lo(%larel(kernel_L.str.7,kernel_autoL60))
	call	print 
	call	syscall_handler_halt 
	j	kernel_LBB12_13 
kernel_LBB12_6:
kernel_autoL61:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL61))(a0)
	lw	a1, -16(s0) 
	bne	a0, a1, kernel_LBB12_11 
	j	kernel_LBB12_7 
kernel_LBB12_7:
	lw	a1, -16(s0) 
	lw	a0, 0(a1) 
	bne	a0, a1, kernel_LBB12_9 
	j	kernel_LBB12_8 
kernel_LBB12_8:
kernel_autoL62:
	auipc	a1, %hi(%pcrel(process_head))
	li	a0, 0 
	sw	a0, %lo(%larel(process_head,kernel_autoL62))(a1)
	j	kernel_LBB12_10 
kernel_LBB12_9:
	lw	a0, -16(s0) 
	lw	a1, 0(a0) 
kernel_autoL63:
	auipc	a0, %hi(%pcrel(process_head))
	sw	a1, %lo(%larel(process_head,kernel_autoL63))(a0)
	lw	a1, -16(s0) 
	lw	a1, 4(a1) 
	lw	a2, %lo(%larel(process_head,kernel_autoL63))(a0)
	sw	a1, 4(a2) 
	lw	a0, %lo(%larel(process_head,kernel_autoL63))(a0)
	lw	a1, -16(s0) 
	lw	a1, 4(a1) 
	sw	a0, 0(a1) 
	j	kernel_LBB12_10 
kernel_LBB12_10:
	j	kernel_LBB12_12 
kernel_LBB12_11:
	lw	a1, -16(s0) 
	lw	a0, 0(a1) 
	lw	a1, 4(a1) 
	sw	a0, 0(a1) 
	lw	a1, -16(s0) 
	lw	a0, 4(a1) 
	lw	a1, 0(a1) 
	sw	a0, 4(a1) 
	j	kernel_LBB12_12 
kernel_LBB12_12:
	lw	a0, -16(s0) 
	call	heap_free 
	j	kernel_LBB12_13 
kernel_LBB12_13:
kernel_autoL64:
	auipc	a0, %hi(%pcrel(kernel_L.str.7))
	addi	a0, a0, %lo(%larel(kernel_L.str.7,kernel_autoL64))
	call	print 
kernel_autoL65:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL65))(a0)
	lw	a0, 20(a0) 
	bnez	a0, kernel_LBB12_15 
	j	kernel_LBB12_14 
kernel_LBB12_14:
kernel_autoL66:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL66))(a0)
	lw	a0, 0(a0) 
kernel_autoL67:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL67))(a1)
	j	kernel_LBB12_15 
kernel_LBB12_15:
kernel_autoL68:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL68))(a0)
	call	jump_to_next_ROM 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end12:
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
kernel_autoL69:
	auipc	a1, %hi(%pcrel(page_size))
	lw	a1, %lo(%larel(page_size,kernel_autoL69))(a1)
	divu	a0, a0, a1 
kernel_autoL70:
	auipc	a1, %hi(%pcrel(curr_process))
	lw	a2, %lo(%larel(curr_process,kernel_autoL70))(a1)
	sw	a0, 28(a2) 
	lw	a0, -12(s0) 
	lw	a2, %lo(%larel(curr_process,kernel_autoL70))(a1)
	lw	a3, 12(a2) 
	lw	a4, 28(a2) 
	slli	a4, a4, 2 
	add	a3, a3, a4 
	lw	a3, 0(a3) 
	add	a0, a0, a3 
	sw	a0, 24(a2) 
	lw	a0, -16(s0) 
	lw	a1, %lo(%larel(curr_process,kernel_autoL70))(a1)
	lw	a2, 12(a1) 
	lw	a3, 28(a1) 
	slli	a3, a3, 2 
	add	a2, a2, a3 
	lw	a2, 0(a2) 
	add	a0, a0, a2 
	sw	a0, 20(a1) 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end13:
	#	-- End function 
alarm_next_program:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL71:
	auipc	a0, %hi(%pcrel(kernel_L.str.8))
	addi	a0, a0, %lo(%larel(kernel_L.str.8,kernel_autoL71))
	call	print 
kernel_autoL72:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a1, %lo(%larel(curr_process,kernel_autoL72))(a0)
	lw	a1, 0(a1) 
	sw	a1, %lo(%larel(curr_process,kernel_autoL72))(a0)
	lw	a0, %lo(%larel(curr_process,kernel_autoL72))(a0)
	lw	a0, 20(a0) 
	bnez	a0, kernel_LBB14_2 
	j	kernel_LBB14_1 
kernel_LBB14_1:
kernel_autoL73:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL73))(a0)
	lw	a0, 0(a0) 
kernel_autoL74:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL74))(a1)
	j	kernel_LBB14_2 
kernel_LBB14_2:
kernel_autoL75:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL75))(a0)
	call	jump_to_next_ROM 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end14:
	#	-- End function 
restore_sp:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL76:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL76))(a0)
	lw	a0, 20(a0) 
	bnez	a0, kernel_LBB15_2 
	j	kernel_LBB15_1 
kernel_LBB15_1:
kernel_autoL77:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL77))(a0)
	lw	a0, 0(a0) 
kernel_autoL78:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL78))(a1)
	j	kernel_LBB15_2 
kernel_LBB15_2:
kernel_autoL79:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL79))(a0)
	lw	a0, 24(a0) 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end15:
	#	-- End function 
get_base:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL80:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL80))(a0)
	lw	a0, 20(a0) 
	bnez	a0, kernel_LBB16_2 
	j	kernel_LBB16_1 
kernel_LBB16_1:
kernel_autoL81:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL81))(a0)
	lw	a0, 0(a0) 
kernel_autoL82:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL82))(a1)
	j	kernel_LBB16_2 
kernel_LBB16_2:
kernel_autoL83:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a1, %lo(%larel(curr_process,kernel_autoL83))(a0)
	lw	a0, 12(a1) 
	lw	a1, 28(a1) 
	slli	a1, a1, 2 
	add	a0, a0, a1 
	lw	a0, 0(a0) 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end16:
	#	-- End function 
get_limit:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL84:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a0, %lo(%larel(curr_process,kernel_autoL84))(a0)
	lw	a0, 20(a0) 
	bnez	a0, kernel_LBB17_2 
	j	kernel_LBB17_1 
kernel_LBB17_1:
kernel_autoL85:
	auipc	a0, %hi(%pcrel(process_head))
	lw	a0, %lo(%larel(process_head,kernel_autoL85))(a0)
	lw	a0, 0(a0) 
kernel_autoL86:
	auipc	a1, %hi(%pcrel(curr_process))
	sw	a0, %lo(%larel(curr_process,kernel_autoL86))(a1)
	j	kernel_LBB17_2 
kernel_LBB17_2:
kernel_autoL87:
	auipc	a0, %hi(%pcrel(curr_process))
	lw	a1, %lo(%larel(curr_process,kernel_autoL87))(a0)
	lw	a0, 12(a1) 
	lw	a1, 28(a1) 
	slli	a1, a1, 2 
	add	a0, a0, a1 
	lw	a0, 0(a0) 
kernel_autoL88:
	auipc	a1, %hi(%pcrel(page_size))
	lw	a1, %lo(%larel(page_size,kernel_autoL88))(a1)
	add	a0, a0, a1 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end17:
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
	j	kernel_LBB18_1 
kernel_LBB18_1:
	lw	a0, -16(s0) 
	lw	a1, -12(s0) 
	addi	a1, a1, 1024 
	bgeu	a0, a1, kernel_LBB18_4 
	j	kernel_LBB18_2 
kernel_LBB18_2:
	lw	a1, -16(s0) 
	li	a0, 0 
	sw	a0, 0(a1) 
	j	kernel_LBB18_3 
kernel_LBB18_3:
	lw	a0, -16(s0) 
	addi	a0, a0, 4 
	sw	a0, -16(s0) 
	j	kernel_LBB18_1 
kernel_LBB18_4:
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end18:
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
kernel_Lfunc_end19:
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
	bnez	a0, kernel_LBB20_2 
	j	kernel_LBB20_1 
kernel_LBB20_1:
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
	j	kernel_LBB20_2 
kernel_LBB20_2:
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
kernel_Lfunc_end20:
	#	-- End function 
find_last_device:
	#	%bb.0: 
	addi	sp, sp, -16 
	sw	ra, 12(sp) # 4-byte Folded Spill 
	sw	s0, 8(sp) # 4-byte Folded Spill 
	addi	s0, sp, 16 
kernel_autoL89:
	auipc	a0, %hi(%pcrel(device_table_base))
	lw	a0, %lo(%larel(device_table_base,kernel_autoL89))(a0)
	sw	a0, -12(s0) 
	li	a0, 0 
	sw	a0, -16(s0) 
	j	kernel_LBB21_1 
kernel_LBB21_1:
	lw	a0, -12(s0) 
	lw	a0, 0(a0) 
kernel_autoL90:
	auipc	a1, %hi(%pcrel(none_device_code))
	lw	a1, %lo(%larel(none_device_code,kernel_autoL90))(a1)
	beq	a0, a1, kernel_LBB21_3 
	j	kernel_LBB21_2 
kernel_LBB21_2:
	lw	a0, -12(s0) 
	sw	a0, -16(s0) 
	lw	a0, -12(s0) 
	addi	a0, a0, 12 
	sw	a0, -12(s0) 
	j	kernel_LBB21_1 
kernel_LBB21_3:
	lw	a0, -16(s0) 
	lw	ra, 12(sp) # 4-byte Folded Reload 
	lw	s0, 8(sp) # 4-byte Folded Reload 
	addi	sp, sp, 16 
	ret	
kernel_Lfunc_end21:
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
	li	a0, 31 
	sw	a0, -24(s0) 
	lw	a0, -16(s0) 
	sw	a0, -28(s0) 
	j	kernel_LBB22_1 
kernel_LBB22_1:
	lw	a0, -28(s0) 
	lw	a1, -20(s0) 
	bgeu	a0, a1, kernel_LBB22_4 
	j	kernel_LBB22_2 
kernel_LBB22_2:
	lw	a0, -28(s0) 
	lw	a1, -24(s0) 
	or	a0, a0, a1 
	sw	a0, -32(s0) 
	lw	a0, -12(s0) 
	lw	a1, -28(s0) 
	lw	a2, -32(s0) 
	call	set_pte 
	j	kernel_LBB22_3 
kernel_LBB22_3:
	lw	a0, -28(s0) 
	lui	a1, 1 
	add	a0, a0, a1 
	sw	a0, -28(s0) 
	j	kernel_LBB22_1 
kernel_LBB22_4:
	lw	a0, -12(s0) 
	lw	ra, 28(sp) # 4-byte Folded Reload 
	lw	s0, 24(sp) # 4-byte Folded Reload 
	addi	sp, sp, 32 
	ret	
kernel_Lfunc_end22:
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
