# External I/O
This RISC-V microarchitecture has an external input `CPUIn` and an external output `CPUOut`. They are both 32-bit values.

When the load word (`lw`) instruction is called with the data memory address 0x7FFFFFFC as a source, the current value of `CPUIn` gets written to the specified destination register. For example:

`lw x1, -5(x2)`

If the value held in register x2 plus -5 is equal to 0x7FFFFFFC, then the value of `CPUIn` gets written to register x1.

When the store word (`sw`) instruction is called with the data memory address 0x7FFFFFFC as a destination, the value held in the specified source register is written to `CPUOut`. For example:

`sw x1, 6(x2)`

If the value held in register x2 plus 6 is equal to 0x7FFFFFFC, then the value held in register x1 gets written to `CPUOut`.

# Machine Code

The machine code in `risc_v.srcs/sources_1/new/program.mem` translates to the following assembly

```asm
addi x1, x0, 50     # Stores the value 50 in x1
lui x10, 0x80000    # Store 0x80000000 in x10
lw x2, -4(x10)      # 0x80000000 - 4 = 0x7FFFFFFC, CPUIn gets written to x2
sub x3, x1, x2      # x3 = x1 – x2 = 50 - CPUIn
sw x3, -4(x10)      # 0x80000000 - 4 = 0x7FFFFFFC, CPUOut = x3
beq x0, x0, 0       # end
```
It performs the operation `CPUOut = 50 - CPUIn` where `CPUOut` and `CPUIn` are an external output and input to and from the microarchitecture.