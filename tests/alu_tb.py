import cocotb
from cocotb.triggers import Timer


@cocotb.test
async def alu_tb(dut):
    """ Testbench for Arithmetic Logic Unit where each of the control
        signals are tested for the expected output
    """

    # Set ALU input sequence - (A, B, ALUControl signal, tested instruction and flag)
    control_sequence = [(0x00000064, 0x00000208, 0b10010, "add"),                                       # 100 + 520 = 620 
                        (0x00000064, 0x00000208, 0b10110, "add (X bits varied in ALUControl)"),         # 100 + 520 = 620  
                        (0x00000064, 0x00000208, 0b01010, "subtract, negative true"),                   # 100 - 520 = -420
                        (0x00000258, 0x00000208, 0b01010, "subtract, negative false"),                  # 600 - 520 = 80
                        (0x00000208, 0x00000208, 0b01010, "subtract, zero true"),                       # 520 - 520 = 0
                        (0x000002BC, 0x00000208, 0b01010, "subtract, zero false"),                      # 700 - 520 = 180
                        (0x000002BC, 0x00000208, 0b10111, "bitwise OR"),
                        (0x00000AAA, 0x00000555, 0b01111, "bitwise OR (X bits varied in ALUControl)"),
                        (0x000002BC, 0x00000208, 0b01011, "bitwise AND"),
                        (0x000002BC, 0x00000003, 0b01000, "shift left logical"),
                        (0x000002BC, 0x00000003, 0b10100, "shift right logical"),
                        (0x000002BC, 0x00000003, 0b01101, "set less than false"),                       # 700 < 3 = False
                        (0x000002BC, 0x000003E8, 0b01101, "set less than true"),                        # 700 < 1000 = True
                        ]
    
    # Expected output values - (ALUResult, Zero, Negative)
    expected_outputs = [(0x0000026C, 0, 0),     # 620
                        (0x0000026C, 0, 0),     # 620
                        (0xFFFFFE5C, 0, 1),     # -420 Negative True
                        (0x00000050, 0, 0),     # 80
                        (0x00000000, 1, 0),     # 0 Zero True
                        (0x000000B4, 0, 0),     # 180 Zero False
                        (0x000002BC, 0, 0),     # 32'h2BC OR 32'h208 = 32'h2BC
                        (0x00000FFF, 0, 0),     # 32'hAAA OR 32'h555 = 32'hFFF
                        (0x00000208, 0, 0),     # 32'h2BC AND 32'h208 = 32'h208
                        (0x000015E0, 0, 0),     # 32'h2BC shifted left by 3 = 32'h15E0
                        (0x00000057, 0, 0),     # 32'h2BC shifted right by 3 = 32'h57
                        (0x00000000, 1, 0),     # 700 < 3 = False
                        (0x00000001, 0, 0),     # 700 < 1000 = True
                        ]
    
    for i in range(len(control_sequence)):
        dut.A.value = control_sequence[i][0]
        dut.B.value = control_sequence[i][1]
        dut.ALUControl.value = control_sequence[i][2]


        await Timer(10, unit="ns")

        dut._log.info(f"{control_sequence[i][3]}")

        assert dut.ALUResult.value == expected_outputs[i][0]
        assert dut.Zero.value == expected_outputs[i][1]
        assert dut.Negative.value == expected_outputs[i][2]