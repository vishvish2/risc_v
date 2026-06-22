This repository can be forked and cloned to a local folder via `git clone`

# Vivado
The FPGA used is the Artix-7 Nexys A7 board with part number `xc7a100tcsg324-1`

- The file `build.tcl` has a script to rebuild the Vivado project used to run the program on the FPGA.
- After cloning the repository to a local folder, open Vivado then open the TCL Console via `Window -> Tcl Console`.
- Use the `cd` command to navigate to the directory the repository is stored in
    - For example, for me to do this, I would do `cd /home/vishnu/Documents/Vivado_Projects/risc_v`
- Run `source build.tcl` to rebuild the Vivado project, the files in `risc_v.src` will be duplicated and stored in a folder called `risc_v` along with other required Vivado files folders
- The project can be opened by opening the generated `risc_v.xpr` file in the Open Project menu.

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
loop:
lw x2, -4(x10)      # 0x80000000 - 4 = 0x7FFFFFFC, CPUIn gets written to x2
sub x3, x1, x2      # x3 = x1 – x2 = 50 - CPUIn
sw x3, -4(x10)      # 0x80000000 - 4 = 0x7FFFFFFC, CPUOut = x3
jalr x0, x0, loop       # end
```
It performs the operation `CPUOut = 50 - CPUIn` where `CPUOut` and `CPUIn` are an external output and input to and from the microarchitecture.