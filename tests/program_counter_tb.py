import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer


@cocotb.test()
async def program_counter_tb(dut):
    """PC testbench to reset, increment and re-reset again."""

    cocotb.start_soon(Clock(dut.CLK, 10, unit="ns").start())

    # Reset initially
    dut.Reset.value = 1             # Assert Reset
    dut.PCNext.value = 0x00000000   # Set counter to 0
    await Timer(10, unit="ns")      # Equivalent of #15 in SystemVerilog
    dut.Reset.value = 0

    await RisingEdge(dut.CLK)
    assert dut.PC.value == 0x00000000, \
        f"Expected 0x0 after reset, got {dut.PC.value.to_unsigned():#010x}"
    dut._log.info(f"t=after reset  PC={dut.PC.value.to_unsigned():#010x}")

    # Each value is a PCNext value
    test_sequence = [
        0x00000004,
        0x00000006,
        0x0000000C,
        0x00000010,
    ]

    for pcnext_val in test_sequence:
        dut.PCNext.value = pcnext_val   # Change DFF input at falling edge for t_setup
        await RisingEdge(dut.CLK)       # DFF samples PCNext on this edge
        await FallingEdge(dut.CLK)      # Give DFF half a clock period for t_hold
        assert dut.PC.value == pcnext_val, (
            f"Expected PC={pcnext_val:#010x}, "
            f"got {dut.PC.value.to_unsigned():#010x}"
        )
        dut._log.info(
            f"PCNext={pcnext_val:#010x}  →  PC={dut.PC.value.to_unsigned():#010x}"
        )

    # Test reset again
    await Timer(10, unit="ns")
    dut.Reset.value = 1
    dut.PCNext.value = 0x00000018

    await RisingEdge(dut.CLK)
    await RisingEdge(dut.CLK)
    assert dut.PC.value == 0x00000000, (
        f"Expected 0x0 on re-reset, got {dut.PC.value.to_unsigned():#010x}"
    )
    dut._log.info("Re-reset asserted — PC correctly zeroed")

    await Timer(10, unit="ns")
    dut.Reset.value = 0

    await FallingEdge(dut.CLK) 
    dut.PCNext.value = 0x0000001E

    await RisingEdge(dut.CLK)
    await FallingEdge(dut.CLK)
    assert dut.PC.value == 0x0000001E, (
        f"Expected 0x1e after re-reset release, "
        f"got {dut.PC.value.to_unsigned():#010x}"
    )
    dut._log.info(f"Post-reset resume  PC={dut.PC.value.to_unsigned():#010x}")

    await Timer(20, unit="ns")
    dut._log.info("Test complete.")
