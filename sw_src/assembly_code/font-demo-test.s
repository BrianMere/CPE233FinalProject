.eqv BG_COLOR, 0x0F	 # light blue (0/7 red, 3/7 green, 3/3 blue)
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
.eqv CHAR_5,		0x0000f9f7
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

.text
main:
    	li sp, 0x10000     	#initialize stack pointer
	li s2, VG_ADDR     	#load MMIO addresses 
	li s3, VG_COLOR

	# fill screen using default color
	call draw_background  # must not modify s2, s3
	
	li a0, 33		# X coordinate
	li a1, 25		# Y coordinate
	li a2, CHAR_A
	li a3, 0xE0		# color red 
	call draw_char
	
	li a0, 38		# X coordinate
	li a1, 25		# Y coordinate
	li a2, CHAR_B
	li a3, 0x1c		# color green
	call draw_char
	
	li a0, 43		# X coordinate
	li a1, 25		# Y coordinate
	li a2, CHAR_C
	li a3, 0x03		# color blue
	call draw_char

    	# li a0, 10		# X coordinate
	# li a1, 20		# Y coordinate
	# li a3, 0xE0		# color red (7/7 red, 0/7 green, 0/3 blue)
	# call draw_dot  # must not modify s2, s3

	# li a0, 50		# X coordinate
	# li a1, 20		# Y coordinate
	# li a3, 0xE0		# color red (7/7 red, 0/7 green, 0/3 blue)
	# call draw_dot  # must not modify s2, s3

	# li a0, 5		# X coordinate
	# li a1, 5		# Y coordinate
	# li a3, 0xE5		# color off-red (7/7 red, 1/7 green, 1/3 blue)
	# call draw_dot  # must not modify s2, s3

	# li a3, 0xE0		# color red (7/7 red, 0/7 green, 0/3 blue)
	# li a3, 0xFF
	# li a0, 4		# start X coordinate
	# li a1, 1		# Y coordinate
	# li a2, 70		# ending X coordinate
	# call draw_horizontal_line  # must not modify: a3, s2, s3

	# li a0, 4		# X coordinate
	# li a1, 8		# starting Y coordinate
	# li a2, 55		# ending Y coordinate
	# call draw_vertical_line  # must not modify s2, s3

done:	j done # continuous loop

# draws a char (a2: char halfword) at (a0, a1)
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
