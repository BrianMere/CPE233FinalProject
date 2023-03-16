# --------------------------------------------------------------------
# LED MMIO    0x11000020
# 7 Seg MMIO  0x11000040
# Keyboard    0x11000100
# --------------------------------------------------------------------

.eqv MMIO,0x11000000 

main: li   s0, MMIO         # pointer for MMIO
    
      la    t0, ISR         # register the interrupt handler
      csrrw x0, mtvec, t0
      li    t0, 8           # enable interrupts
      csrrw x0, mstatus, t0

      add   s1, x0, x0      # initialize interrupt count
      sw    x0, 0x40(s0)    # clear 7Seg
      sw    x0, 0x20(s0)    # clear LEDs
      
loop: nop
      j loop

# Interrupt Service Routine for keyboard
ISR:  lw   t0, 0x100(s0)    # read scancode
      sw   t0, 0x40(s0)     # save to 7seg
      addi  s1, s1,  1      # increment interrupt count
      sw    s1, 0x20(s0)    # output to LEDS
      mret
      