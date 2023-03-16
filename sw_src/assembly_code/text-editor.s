.eqv BG_COLOR, 0x0F	 # light blue (0/7 red, 3/7 green, 3/3 blue)
.eqv MMIO, 0x11000000 
.eqv VG_ADDR, 0x11000120
.eqv VG_COLOR, 0x11000140

.eqv CHAR_A, 		0x0000f9f9
.eqv CHAR_B, 		0x0000ef9f
.eqv CHAR_C, 		0x0000f88f
.eqv CHAR_D, 		0x0000e99e
.eqv CHAR_E, 		0x0000fe8f
.eqv CHAR_F, 		0x0000f8e8
.eqv CHAR_G, 		0x0000f89f
.eqv CHAR_H, 		0x000099f9
.eqv CHAR_I, 		0x0000e44e
.eqv CHAR_J, 		0x000072ae

.eqv CHAR_0, 		0x0000fb9f
.eqv CHAR_1, 		0x0000c44e
.eqv CHAR_2,		0x0000f3cf
.eqv CHAR_3,		0x0000f71f
.eqv CHAR_4,		0x000099f1
.eqv CHAR_5,		0x0000f8f7
.eqv CHAR_6,		0x00008f9f
.eqv CHAR_7,		0x0000f111
.eqv CHAR_8,		0x0000f9ff
.eqv CHAR_9,		0x0000f9f1

.eqv CHAR_PLUS, 	0x000004e4
.eqv CHAR_MINUS, 	0x000000e0
.eqv CHAR_MULT		0X00000a4a
.eqv CHAR_DIV,		0X00002448
.eqv CHAR_SQRT, 	0x000074d4
.eqv CHAR_EQUALS,	0x00000e0e
.eqv CHAR_DOT, 		0x00000004
.eqv CHAR_OPENPAREN, 	0x00002442
.eqv CHAR_CLOSEPAREN,	0x00004224
.eqv CHAR_BLOCK,	0x0000ffff

.data 
SCANCODE: 

# =================================================================================================
# MAIN
# =================================================================================================

.text
main:
	li sp, 0x10000     	# initialize stack pointer
    	li s0, MMIO        	# pointer for MMIO
        la s1, SCANCODE    	# pointer to scancode
	li s2, VG_ADDR     	# load MMIO addresses 
	li s3, VG_COLOR
	li s4, 4		# cursor x
	li s5, 25		# cursor y
	li s6, 0		# interrupt flag

	# fill screen using default color (BG_COLOR)
	call draw_background
	
	la    t0, ISR         # register the interrupt handler
        csrrw x0, mtvec, t0
        li    t0, 8           # enable interrupts
        csrrw x0, mstatus, t0

main_loop:
	beq   s6, x0, main_loop	# check for interrupt flag (loop this line if not)
	# TODO: check/adjust coordinates
	# TODO: draw letter based on scan code
	call process_input
	addi  s4, s4, 6		# move x coord over
	addi  s6, x0, 0       	# clear interrupt flag
	j     main_loop
	
# =================================================================================================
# Process keyboard input
# =================================================================================================

# draws a letter based on scan code
# modifies t0, t1, a0, a1, a2, a3, (s4 for backspace)
process_input:
	addi  sp, sp, -4	# store ra on stack
	sw    ra, 0(sp)
	# load arguments
	mv    a0, s4		# cursor x -> arg
	mv    a1, s5		# cursor y -> arg
	li    a3, 0x00		# color black 
	lw    t0, 0(s1)       	# read saved scancode
	# check scancode and draw char
	li    t1, 0x1c		# load A code
	beq   t0, t1, pi_a	# check if A
	li    t1, 0x32		# load B code
	beq   t0, t1, pi_b	# check if B
	li    t1, 0x21		# C
	beq   t0, t1, pi_c
	li    t1, 0x23		# D
	beq   t0, t1, pi_d
	li    t1, 0x24		# E
	beq   t0, t1, pi_e
	li    t1, 0x2b		# F
	beq   t0, t1, pi_f
	li    t1, 0x34		# G
	beq   t0, t1, pi_g
	li    t1, 0x33		# H
	beq   t0, t1, pi_h
	li    t1, 0x43		# I
	beq   t0, t1, pi_i
	li    t1, 0x3b		# J
	beq   t0, t1, pi_j
	
	li    t1, 0x45		# 0
	beq   t0, t1, pi_0
	li    t1, 0x16		# 1
	beq   t0, t1, pi_1
	li    t1, 0x1e		# 2
	beq   t0, t1, pi_2
	li    t1, 0x26		# 3
	beq   t0, t1, pi_3
	li    t1, 0x25		# 4
	beq   t0, t1, pi_4
	li    t1, 0x2e		# 5
	beq   t0, t1, pi_5
	li    t1, 0x36		# 6
	beq   t0, t1, pi_6
	li    t1, 0x3d		# 7
	beq   t0, t1, pi_7
	li    t1, 0x3e		# 8
	beq   t0, t1, pi_8
	li    t1, 0x46		# 9
	beq   t0, t1, pi_9
	
	li    t1, 0x29		# SPACE
	beq   t0, t1, pi_space
	li    t1, 0x66		# BACKSPACE
	beq   t0, t1, pi_backspace
	
	li    a2, CHAR_MULT	# DEFAULT
pi_draw:
	call  draw_char		# draw letter
	lw    ra, 0(sp)		# restore ra from stack
	addi  sp, sp, 4
	ret
pi_a:
	li    a2, CHAR_A	# load letter into arg
	j     pi_draw		# jump up to draw and return
pi_b:
	li    a2, CHAR_B
	j     pi_draw
pi_c:
	li    a2, CHAR_C
	j     pi_draw
pi_d:
	li    a2, CHAR_D
	j     pi_draw
pi_e:
	li    a2, CHAR_E
	j     pi_draw
pi_f:
	li    a2, CHAR_F
	j     pi_draw
pi_g:
	li    a2, CHAR_G
	j     pi_draw
pi_h:
	li    a2, CHAR_H
	j     pi_draw
pi_i:
	li    a2, CHAR_I
	j     pi_draw
pi_j:
	li    a2, CHAR_J
	j     pi_draw
pi_0:
	li    a2, CHAR_0
	j     pi_draw
pi_1:
	li    a2, CHAR_1
	j     pi_draw
pi_2:
	li    a2, CHAR_2
	j     pi_draw
pi_3:
	li    a2, CHAR_3
	j     pi_draw
pi_4:
	li    a2, CHAR_4
	j     pi_draw
pi_5:
	li    a2, CHAR_5
	j     pi_draw
pi_6:
	li    a2, CHAR_6
	j     pi_draw
pi_7:
	li    a2, CHAR_7
	j     pi_draw
pi_8:
	li    a2, CHAR_8
	j     pi_draw
pi_9:
	li    a2, CHAR_9
	j     pi_draw
pi_space:
	lw    ra, 0(sp)		# restore ra from stack
	addi  sp, sp, 4
	ret
pi_backspace:
	# TODO: Check if moving cursor back goes up a line
	addi  s4, s4, -6	# move cursor back
	mv    a0, s4		# cursor x -> arg
	li    a2, CHAR_BLOCK	# load letter into arg
	li    a3, BG_COLOR	# use bg color
	call  draw_char		# draw letter
	addi  s4, s4, -6	# move cursor back again
	lw    ra, 0(sp)		# restore ra from stack
	addi  sp, sp, 4
	ret
	
# =================================================================================================
# ISR
# =================================================================================================

# Interrupt Service Routine for keyboard
ISR:
	addi sp, sp, -4     # push t0 to stack (bc we could be in the middle of a subroutine)
     	sw   t0, 0(sp)
      	lw   t0, 0x100(s0)  # read scancode
      	sw   t0, 0(s1)      # save to SCANCODE
      	addi s6, x0, 1      # set interrupt flag
	lw   t0  0(sp)      # pop t0 from stack
      	addi sp, sp, 4
      	mret
      	
# =================================================================================================
# DRAWING SUBROUTINES
# =================================================================================================

# draws a char (a2: char halfword) at (a0, a1), (a3: color)
# modifies t0-t6, a0, a1
draw_char:
	addi sp, sp, -4	# store ra on stack
	sw ra, 0(sp)
	mv t0, a2	# move letter into t0
	li t1, 0x8000	# load bit mask into t1 (starts at left and moves right)
	li t2, 0	# load x counter into t2
	li t3, 0 	# load y counter into t3
	li t4, 3	# counters increment when they reach 3 (t4)
	mv t5, a0	# save x coord to t5
draw_char1:
	and t6, t0, t1		# letter && bitmask to get just first bit
	beqz t6, draw_char2 	# don't draw anything if pixel is 0 (branch to draw_let2)
	# draw_dot modifies t0, t1, so they must be pushed to stack:
	addi sp, sp, -4
	sw t0, 0(sp)
	addi sp, sp, -4
	sw t1, 0(sp)
	call draw_dot		# draw point
	# restore t1, t0 from stack:
	lw t1, 0(sp)
	addi sp, sp, 4
	lw t0, 0(sp)
	addi sp, sp, 4
draw_char2:
	srli t1, t1, 1		# shift bitmask to right 1
	beq t2, t4, draw_char3	# branch if x counter has reached end
	addi t2, t2, 1		# increment x counter if not
	addi a0, a0, 1		# and increment x coord
	j draw_char1		# loop back
draw_char3:
	add t2, x0, x0		# reset x counter
	mv a0, t5		# reset x coord
	addi t3, t3, 1		# increment y counter
	addi a1, a1, 1		# increment y coord
	ble t3, t4, draw_char1  # loop back if y counter has not reached end (4)
	lw ra, 0(sp)		# restore ra from stack
	addi sp, sp, 4
	ret

# draws a horizontal line from (a0,a1) to (a2,a1) using color in a3
# Modifies (directly or indirectly): t0, t1, a0, a2
draw_horizontal_line:
	addi sp,sp,-4
	sw ra, 0(sp)
	addi a2,a2,1	#go from a0 to a2 inclusive
draw_horiz1:
	call draw_dot  # must not modify: a0, a1, a2, a3
	addi a0,a0,1
	bne a0,a2, draw_horiz1
	lw ra, 0(sp)
	addi sp,sp,4
	ret

# draws a vertical line from (a0,a1) to (a0,a2) using color in a3
# Modifies (directly or indirectly): t0, t1, a1, a2
draw_vertical_line:
	addi sp,sp,-4
	sw ra, 0(sp)
	addi a2,a2,1
draw_vert1:
	call draw_dot  # must not modify: a0, a1, a2, a3
	addi a1,a1,1
	bne a1,a2,draw_vert1
	lw ra, 0(sp)
	addi sp,sp,4
	ret

# Fills the 60x80 grid with one color using successive calls to draw_horizontal_line
# Modifies (directly or indirectly): t0, t1, t4, a0, a1, a2, a3
draw_background:
	addi sp,sp,-4
	sw ra, 0(sp)
	li a3, BG_COLOR	#use default color
	li a1, 0	#a1= row_counter
	li t4, 60 	#max rows
start:	li a0, 0
	li a2, 79 	#total number of columns
	call draw_horizontal_line  # must not modify: t4, a1, a3
	addi a1,a1, 1
	bne t4,a1, start	#branch to draw more rows
	lw ra, 0(sp)
	addi sp,sp,4
	ret

# draws a dot on the display at the given coordinates:
# 	(X,Y) = (a0,a1) with a color stored in a3
# 	(col, row) = (a0,a1)
# Modifies (directly or indirectly): t0, t1
draw_dot:
	andi t0,a0,0x7F	# select bottom 7 bits (col)
	andi t1,a1,0x3F	# select bottom 6 bits  (row)
	slli t1,t1,7	#  {a1[5:0],a0[6:0]} 
	or t0,t1,t0	# 13-bit address
	sw t0, 0(s2)	# write 13 address bits to register
	sw a3, 0(s3)	# write color data to frame buffer
	ret

