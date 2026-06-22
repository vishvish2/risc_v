This RISC-V microarchitecture has an external input CPUIn and an external output CPUOut. They are both 32-bit values.

When the load word (lw) instruction is called with the data memory address 0x7FFFFFFC as a source, the current value of CPUIn gets written to the specified destination register. For example:

lw x1, -5(x2)

If the value held in register x2 plus -5 is equal to 0x7FFFFFFC, then the value of CPUIn gets written to register x1.

When the store word (sw) instruction is called with the data memory address 0x7FFFFFFC as a destination, the value held in the specified source register is written to CPUOut. For example:

sw x1, 6(x2)

If the value held in register x2 plus 6 is equal to 0x7FFFFFFC, then the value held in register x1 gets written to CPUOut.