A verilog wishbone/amba memory controller ported form gaisler IP lib

Features:

1) Dual bus protocols support

2) Support SDRAM, SRAM, PROM, IO.

3) Wishbone burst extension support, make use of full bandwidth

4) Gaisler verified the original VHDL version in silicon

5) Verilog version verified in FPGA

6) Can be used in FPGA or ASIC design

Limits:
1) Wishbone master can't deassert wb\_stb during burst transactions, or corresponding write or read maybe wrong. Tricky to work around it.