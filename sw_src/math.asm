# floating point arithmetic stores each value as a decimal number
# 0x12345678
# THe left bit is the signed bit. The next 7 bits are the exponent subtracted by 64
# So the number 100 0011 in 0x12345678 has exponent 67 - 64 = 3
# The remaining bits are used as the decimal number as such:
# -> 012345 (we lose the last 2 hex digits when converting)
.data 

PI: .word 0x413243F6
PI2: .word 0x416487EC
E: .word 0x41297A49

.text

MAIN:
	# Setup Stack pointer
	lui sp, 0x10   # Start sp at 0x10000
	
	la a0, PI
	lw a0, 0(a0)
	call SHIFT_R
	call SHIFT_L
	
END:
	j END      # END forever	
	
# Subroutine: HD_2_FLOAT
# a0 contains our parameter of our normal hexademical digit and outputs a float converted from that. 
# Ex: 0x12345678 -> 0x48123456, 0xFFFFFFFF -> 0x88FFFFFFFF

HD_2_FLOAT:           # Turn a hexadecimal number into its float equivalent. Assumes signed numbers.
	addi a1, a0, 0       # Save a copy in a1 for use
	
	# Mess around with the sign if needed
	lui t1, 0x80000      
	and a1, a1, t1       # Mask the signed bit
	addi t1, x0, 0       # Set signed bit to 0 (0x00000000)
	beqz a1, START_H2DF
	not a0, a0           # Flip all the bits
	addi a0, a0, 1       # Add 1
	lui t1, 0x80000      # Set signed bit to 1 (0x80000000)

START_H2DF:
	addi a1, a0, 0       # a1 = a0;
	addi t0, x0, 0       # Have t0 = 0;
	beqz a1, END_HD2F    # We break when we have a1 == 0
LOOP_HD2F:
	srli a1, a1, 4       # Shift right one hex digit.
	addi t0, t0, 1       # Add one to our exponent count. 
	bnez a1, LOOP_HD2F
END_HD2F:
	mv a2, t1            # have a2 have our signed bit
	addi t2, x0, 3
	blt t0, t2, SKIP_CLIP
	srli a0, a0, 8       # have our value lose the last two hex digits. Skip if our base only has so many integers
SKIP_CLIP:
	addi t0, t0, 64      # Offset by 64 per our format
	slli t0, t0, 24      # Move our exponent to the correct place. 
	add a0, a0, t0       # a0 has our exponent and base
	add a0, a0, a2       # Now we have our signed bit
	ret
	
# End Subroutine HD_2_FLOAT
#---------------------------

# Begin Subroutine GET_MANISSA
# Take float a0 and return the manissa 0.abcdef as 0x00abcdef, converting to signed if needed. 
GET_MANISSA:
	addi sp, sp, -8
	sw a0, 4(sp)
	sw ra, 0(sp)
	call F_IS_SIGNED
	mv a0, t0          # t0 has our function return
	lw ra, 0(sp)
	lw a0, 4(sp)
	addi sp, sp, 8
	beqz t0, NOT_CONVERT
CONVERT_SIGNED:
	not a0, a0
	addi a0, a0, 1
NOT_CONVERT:
	srli a0, a0, 8
	ret
	
# End Subroutine GET_MANISSA
#---------------------------
# Begin Subroutine GET_EXP
# Get the value of the exponent, subbing the 64 offset as required. 
GET_EXP:
	slli a0, a0, 1      # Get rid of the signed bit
	srli a0, a0, 25     # Shift 1 + 24 all the way
	addi a0, a0, -64
	ret
	

# End Subroutine GET_EXP
#---------------------------
# Begin Subroutine F_IS_SIGNED

F_IS_SIGNED:
	lui a1, 0x80000
	and a0, a0, a1
	snez a0, a0
	ret
	

# End Subroutine F_IS_SIGNED
#---------------------------
# Begin Subroutine SLT_FLOATS
# a0 < a1? 1 : 0, where a0, a1 are floating point numbers

SLT_FLOATS:
	# Test signs (1 then 2)
	addi sp, sp, -12
	sw ra, 8(sp)
	sw a0, 4(sp)
	sw a1, 0(sp)
	call F_IS_SIGNED
	mv t0, a0
	lw a0, 0(sp)
	addi sp, sp, -4
	sw t0, 0(sp)
	call F_IS_SIGNED
	mv t1, a0
	lw t0, 0(sp)
	lw a1, 4(sp)
	lw a0, 8(sp)
	lw ra, 12(sp)
	addi sp, sp, 16
	
	beq t0, t1, TEST_EXP
	addi a0, x0, 0
	slt a0, t1, t0
	ret
	
	# Now test exponents
TEST_EXP:
	# Get exp of 1
	addi sp, sp, -12
	sw ra, 8(sp)
	sw a0, 4(sp)
	sw a1, 0(sp)
	call GET_EXP
	mv t0, a0         # t0 has our function return
	
	# Get exp of 2
	lw a0, 0(sp)      # Load new parameter
	addi sp, sp, -4
	sw t0, 0(sp)
	call GET_EXP
	mv t1, a0         # t1 has our other function return
	lw t0, 0(sp)
	lw a1, 4(sp)
	lw a0, 8(sp)
	lw ra, 12(sp)
	addi sp, sp, 16
	
	beq t0, t1, TEST_MANISSA
	
	# Here we are certain to mess with a0 and a1 as we don't need manissa now. 
	addi a0, x0, 0
	slt a0, t0, t1
	ret
	
TEST_MANISSA:
	# Get manissa of 1
	addi sp, sp, -12
	sw a0, 8(sp)
	sw a1, 4(sp)
	sw ra, 0(sp)
	call GET_MANISSA
	mv t0, a0         # t0 has our function return
	
	# Get manissa of 2
	addi sp, sp, -4
	sw t0, 0(sp)
	call GET_MANISSA
	mv t1, a0         # t1 has our other function return
	lw t0, 0(sp)
	lw ra, 4(sp)
	lw a1, 8(sp)
	lw a0, 12(sp)
	addi sp, sp, 16
	
	addi a0, x0, 0
	slt a0, t0, t1
	ret
	
	
# End Subroutine SLT_FLOAT
#--------------------------
# Begin Subroutine ADD_FLOATS
# a0 + a1 in terms of floating point arithmetic

ADD_FLOATS:

	# Get exp of 1
	addi sp, sp, -12
	sw ra, 8(sp)
	sw a0, 4(sp)
	sw a1, 0(sp)
	call GET_EXP
	mv t0, a0         # t0 has our function return
	
	# Get exp of 2
	lw a0, 0(sp)      # Load new parameter
	addi sp, sp, -4
	sw t0, 0(sp)
	call GET_EXP
	mv t1, a0         # t1 has our other function return
	lw t0, 0(sp)
	lw a1, 4(sp)
	lw a0, 8(sp)
	lw ra, 12(sp)
	addi sp, sp, 16
	
	
	# If our exponents are the same, add as normal. Else, modify one of them to make the exponents equal.
	beq t0, t1, OFFSET
	blt t0, t1, INC_LEFT
INC_RIGHT:
	# Continue from here young padawan
	
INC_LEFT:

OFFSET:
	
	

# End Subroutine ADD_FLOATS
#--------------------------
# Begin Subroutine MULT_16
# Multiply the float a0 by 16, or just add one to the exponent. If the exponent wraps around it'll just do that lol.

MULT_16:
	lui t0, 0x01000
	add a0, a0, t0
	ret	

# End Subroutine MULT_16
#-------------------------
# Begin Subroutine DIV_16
# Divide the float a0 by 16, or just subtract one from the exponent. If the exponents wraps around it'll do that. 

DIV_16:
	lui t0, 0x01000
	sub a0, a0, t0
	ret

# End Subroutine DIV_16
#------------------------
# Begin Subroutine SHIFT_R
# Shifts the manissa to the right, making sure the exponent also changes accordingly.

SHIFT_R:
	li t0, 0x00FFFFFF
	and t0, t0, a0       # Isolate just the last 6 hex bits
	srli t0, t0, 4       # Shift one hex digit right
	
	# call DIV_16
	addi sp, sp, -8
	sw ra, 4(sp)
	sw t0, 0(sp)
	call DIV_16
	lw t0, 0(sp)
	lw ra, 4(sp)
	addi sp, sp, 4
	
	# Clean up
	lui t1, 0xFF000
	and a0, a0, t1       # a0 should just have the left 2 hex digits
	add a0, a0, t0       # add in the right 6 digits
	
	ret
# End Subroutine SHIFT_R
#------------------------
# Begin Subroutine SHIFT_L
# Shifts the manissa to the left, making sure the exponent also changes accordingly.

SHIFT_L:
	li t0, 0x00FFFFFF
	and t0, t0, a0      # Isolate just last 6 hex digits
	slli t0, t0, 4      # Shift one digit left
	
	# call MULT_16
	addi sp, sp, -8
	sw ra, 4(sp)
	sw t0, 0(sp)
	call MULT_16
	lw t0, 0(sp)
	lw ra, 4(sp)
	addi sp, sp, 4
	
	# Clean up
	lui t1, 0xFF000
	and a0, a0, t1       # a0 should just have the left 2 hex digits
	add a0, a0, t0       # add in the right 6 digits

# End Subroutine SHIFTF_L
#------------------------