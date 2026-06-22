# control_unit_tb.py
import cocotb
from cocotb.types import LogicArray
from cocotb.triggers import Timer


def check(dut, label, immsrc, alusrc, alucontrol, memwrite, resultsrc, pcsrc, regwrite):
    """Assert all control signals with expected results."""

    def match(signal, expected_str, name):
        expected = LogicArray(expected_str)
        actual   = LogicArray(str(signal.value))  # normalise to LogicArray regardless of width
        assert actual == expected, (
            f"{label} {name}: expected {expected_str}, got {actual}"
        )

    match(dut.ImmSrc, immsrc, "immsrc")
    match(dut.ALUSrc, alusrc, "alusrc")  # 1-bit, pass "0" or "1"
    match(dut.ALUControl, alucontrol,"alucontrol")
    match(dut.MemWrite, memwrite, "memwrite")
    match(dut.ResultSrc, resultsrc, "resultsrc")
    match(dut.PCSrc, pcsrc, "pcsrc")
    match(dut.RegWrite, regwrite, "regwrite")

    dut._log.info(f"{label}")


async def drive(dut, instr, delay_ns=10):
    dut.Instr.value = instr
    await Timer(delay_ns, unit="ns")


@cocotb.test()
async def control_unit_tb(dut):
    """Control unit: drive instructions, assert expected control signals."""

    dut.Zero.value     = LogicArray("X")
    dut.Negative.value = LogicArray("X")
    dut.Instr.value    = 0

    # R-Type 
    # immsrc=xxx, alusrc=0, memwrite=0, resultsrc=00, pcsrc=00
    await drive(dut, 0b00000000000000000000000000110011)
    check(dut, "add", immsrc="xxx", alusrc="0", alucontrol="x0x10", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    await drive(dut, 0b01000000000000000000000000110011)
    check(dut, "sub", immsrc="xxx", alusrc="0", alucontrol="x1x10", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    await drive(dut, 0b00000000000000000110000000110011)
    check(dut, "or", immsrc="xxx", alusrc="0", alucontrol="xx111", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    await drive(dut, 0b00000000000000000111000000110011)
    check(dut, "and", immsrc="xxx", alusrc="0", alucontrol="xx011", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    await drive(dut, 0b00000000000000000001000000110011)
    check(dut, "sll", immsrc="xxx", alusrc="0", alucontrol="0xx00", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    await drive(dut, 0b00000000000000000101000000110011)
    check(dut, "srl", immsrc="xxx", alusrc="0", alucontrol="1xx00", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    await drive(dut, 0b00000000000000000010000000110011)
    check(dut, "slt", immsrc="xxx", alusrc="0", alucontrol="x1x01", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    # I-Type (ALU)
    # immsrc=000, alusrc=1, memwrite=0, resultsrc=00, pcsrc=00
    await drive(dut, 0b00000000000000000000000000010011)
    check(dut, "addi", immsrc="000", alusrc="1", alucontrol="x0x10", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    await drive(dut, 0b00000000000000000110000000010011)
    check(dut, "ori", immsrc="000", alusrc="1", alucontrol="xx111", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    await drive(dut, 0b00000000000000000111000000010011)
    check(dut, "andi", immsrc="000", alusrc="1", alucontrol="xx011", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    await drive(dut, 0b00000000000000000001000000010011)
    check(dut, "slli", immsrc="000", alusrc="1", alucontrol="0xx00", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    await drive(dut, 0b00000000000000000101000000010011)
    check(dut, "srli", immsrc="000", alusrc="1", alucontrol="1xx00", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    await drive(dut, 0b00000000000000000010000000010011)
    check(dut, "slti", immsrc="000", alusrc="1", alucontrol="x1x01", memwrite="0", resultsrc="00", pcsrc="00", regwrite="1")

    # Load
    await drive(dut, 0b00000000000000000010000000000011)
    check(dut, "lw", immsrc="000", alusrc="1", alucontrol="x0x10", memwrite="0", resultsrc="01", pcsrc="00", regwrite="1")

    # Store
    await drive(dut, 0b00000000000000000010000000100011)
    check(dut, "sw", immsrc="001", alusrc="1", alucontrol="x0x10", memwrite="1", resultsrc="xx", pcsrc="00", regwrite="0")

    # Branch: beq
    dut.Instr.value = 0b00000000000000000000000001100011
    dut.Zero.value  = 0
    await Timer(10, unit="ns")
    check(dut, "beq (zero=0)", immsrc="010", alusrc="0", alucontrol="x1x10", memwrite="0", resultsrc="xx", pcsrc="00", regwrite="0")

    dut.Instr.value = 0b00000000000000000000000001100011
    dut.Zero.value  = 1
    await Timer(10, unit="ns")
    check(dut, "beq (zero=1)", immsrc="010", alusrc="0", alucontrol="x1x10", memwrite="0", resultsrc="xx", pcsrc="01", regwrite="0")

    # Branch: bne
    dut.Instr.value = 0b00000000000000000001000001100011
    dut.Zero.value  = 0
    await Timer(10, unit="ns")
    check(dut, "bne (zero=0)", immsrc="010", alusrc="0", alucontrol="x1x10", memwrite="0", resultsrc="xx", pcsrc="01", regwrite="0")

    dut.Instr.value = 0b00000000000000000001000001100011
    dut.Zero.value  = 1
    await Timer(10, unit="ns")
    check(dut, "bne (zero=1)", immsrc="010", alusrc="0", alucontrol="x1x10", memwrite="0", resultsrc="xx", pcsrc="00", regwrite="0")

    # Branch: blt
    dut.Instr.value    = 0b00000000000000000100000001100011
    dut.Negative.value = 0
    await Timer(10, unit="ns")
    check(dut, "blt (negative=0)", immsrc="010", alusrc="0", alucontrol="x1x10", memwrite="0", resultsrc="xx", pcsrc="00", regwrite="0")

    dut.Instr.value    = 0b00000000000000000100000001100011
    dut.Negative.value = 1
    await Timer(10, unit="ns")
    check(dut, "blt (negative=1)", immsrc="010", alusrc="0", alucontrol="x1x10", memwrite="0", resultsrc="xx", pcsrc="01", regwrite="0")

    # Branch: bge
    dut.Instr.value    = 0b00000000000000000101000001100011
    dut.Negative.value = 0
    await Timer(10, unit="ns")
    check(dut, "bge (negative=0)", immsrc="010", alusrc="0", alucontrol="x1x10", memwrite="0", resultsrc="xx", pcsrc="01", regwrite="0")

    dut.Instr.value    = 0b00000000000000000101000001100011
    dut.Negative.value = 1
    await Timer(10, unit="ns")
    check(dut, "bge (negative=1)", immsrc="010", alusrc="0", alucontrol="x1x10", memwrite="0", resultsrc="xx", pcsrc="00", regwrite="0")

    # J-Type and U-Type
    await drive(dut, 0b00000000000000000000000001101111)
    check(dut, "jal", immsrc="100", alusrc="x", alucontrol="xxxxx", memwrite="0", resultsrc="10", pcsrc="01", regwrite="1")

    await drive(dut, 0b01000000000000000000000001100111)
    check(dut, "jalr", immsrc="000", alusrc="1", alucontrol="x0x10", memwrite="0", resultsrc="10", pcsrc="10", regwrite="1")

    await drive(dut, 0b00000000000000000110000000110111)
    check(dut, "lui", immsrc="011", alusrc="x", alucontrol="xxxxx", memwrite="0", resultsrc="11", pcsrc="00", regwrite="1")

    dut._log.info("All assertions passed.")
