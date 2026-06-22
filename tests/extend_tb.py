import cocotb
from cocotb.triggers import Timer

@cocotb.test
async def extend_tb(dut):
    """ Extend block testbench to test immediate value extension for
        each of the instruction types
    """

    # Test instructions of each type - (Immediate Source, Instruction, expected value, Instruction type)
    instr_sequence = [
        (0b000, 0b10110100101101011100101011010111, "I"),   # I-Type
        (0b001, 0b01101011100101011011110010101001, "S"),   # S-Type
        (0b010, 0b11001100110101100111001010110110, "B"),   # B-Type
        (0b011, 0b00111101001011011110001101001010, "U"),   # U-Type
        (0b100, 0b11100011101001101011100100110101, "J"),   # J-Type
    ]

    # Expected immediate extensions for each corresponding instruction type
    expected_values = [0b11111111111111111111101101001011,
                       0b00000000000000000000011010111001,
                       0b11111111111111111111110011000100,
                       0b00111101001011011110000000000000,
                       0b11111111111101101011011000111010]

    
    for i in range(5):
        dut.ImmSrc.value = instr_sequence[i][0]
        dut.Instr.value = instr_sequence[i][1]
        await Timer(10, unit="ns")

        dut._log.info(f"{instr_sequence[i][2]}-Type Instruction test")

        assert dut.ImmExt.value == expected_values[i], (
            f"Error at iteration {i}, "
            f"Expected {expected_values[i]}, got {dut.ImmExt.value}"
            )