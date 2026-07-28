# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

You are an expert VHDL coder working on an FPGA design for a Xilinx Ultrascale+ device.
The FPGA is part of a ZCU102 development board. 
The project involves the waveform generation using 32 DACs connected to the FPGA with a JESD204B interface.
The DACs are on an Abaco FMC216 board.
The DACs are Texas Instruments DAC39J84 devices
The Abaco board uses a LMK04828 PLL clock generator chip
The FPGA uses a Xilinx JESD204C LogiCORE IP Product (in JESD204B mode) and a JESD204 PHY v4.0 IP block 

The project involves the waveform generation using 32 DACs connected to the FPGA with a JESD204B interface.

The JESD204B parameters are:
Number of lanes per device L = 2
Number of converters per device M = 4
Samples per Converter per Frame S = 1
Number of bits per Sample N = 16
Number of octets per frame (M*S*N/8*L)  = (4*1*16)/(8*2)  F = 4
Control bits per Sample CS = 0

Number of Frames in a Multiframe (K) is typically 16 or 32


## Build System

**Tool:** Xilinx Vivado (GUI-based EDA tool)

**Project Files:** Located inoutside of the github repo in `D:/Work/UW-Quantum/tools/xilinx/` 
Key projects:
- `zcu102`

**Constraints:**

**Output:** Bitstream files (`.bit`) are placed in `bitfiles/` directory

## Architecture

```
src/hdl/
├── fpga/           # Reusable blocks across all FPGAs
│   ├── common/    # 
│   ├── zcu102/    # 
│
├── ip_custom/         # 
│   ├── axi_qlaser_v1_0/   # 
│ 
│
├── std_developerskit/        # Test I/O package
├── testbench/         # testbench files for simulation
```

**Key Packages:**
- `fpga_common_pkg.vhdl` - Common register addresses, system-wide constants
- `*_version_pkg.vhdl` - HDL version tracking for each design

**Data Flow:** Waveform gen or test pattern -> JESD TX -> Abaco FMC216 board

## VHDL Coding Guidelines

### Language & Libraries
- **VHDL-2008** compliant code
- Use `ieee.numeric_std` for arithmetic (NEVER use `std_logic_arith`, `std_logic_unsigned`, or `std_logic_signed`)
- Use `rising_edge(clk)` not `clk'event and clk = '1'`

### Naming Conventions

**Case:**
- Lowercase for signals, ports, entities, architectures
- UPPERCASE for constants, generics, enumeration values

**Required Prefixes:**
| Prefix | Usage |
|--------|-------|
| `u_` | Component instances |
| `g_` | Generate block labels |
| `pr_` | Process names |
| `v_` | Variables |
| `t_` | Type definitions |
| `t_rec_` | Record types |
| `t_arr_` | Array types |
| `clk_` | Clock signals |
| `reset_` | Reset signals |
| `cnt_` | Counter signals |
| `G_` | Entity generics |
| `S_` | State machine states |

**Required Suffixes:**
| Suffix | Usage |
|--------|-------|
| `_pkg` | Package names/files |
| `_d`, `_d1`, `_d2` | Pipeline delays |
| `_msync` | Metastability synchronizers |
| `_n` | Active low (avoid if possible) |
| `_i` | Internal signals driving outputs |
| `_hold` | Sampled/held signals (not `_latch`) |

**Naming Hierarchy:** Most general to most specific (e.g., `bs_fifo_dout` not `dout_bs_fifo`)

### Architecture Names
- `rtl` - Synthesizable RTL code
- `behave` - Non-synthesizable/testbench
- `struct` - Structural (instances only)
- `empty` - Stub with default outputs
- `dummy` - Limited functionality

### Formatting
- 4 spaces for indentation (no tabs)
- Line length: 80-100 chars preferred, max 140
- Unix line endings (LF only)
- One statement per line

### Process Style
```vhdl
pr_example : process(clk)
begin
    if rising_edge(clk) then
        if (reset = '1') then
            -- synchronous reset
        else
            -- logic
        end if;
    end if;
end process pr_example;
```

### State Machines
```vhdl
type t_state is (S_IDLE, S_RUN, S_DONE);
signal state : t_state;

-- Single synchronous process style preferred
-- Always include "when others =>" for recovery
```

### Component Instantiation
```vhdl
-- Preferred: entity instantiation (no component declaration needed)
u_myblock : entity work.myblock
port map (
    clk  => clk,
    data => data
);
```

### Critical Rules
- All registers must be reset (use synchronous resets)
- No signal initial values in RTL (use reset instead)
- No internal tri-states
- No magic numbers (use constants)
- Prefer one clock per entity
- Comment every process explaining its purpose
- Remove unused code (don't comment out)

### Common Abbreviations
`ena`=enable, `ctrl`=control, `sel`=select, `adr`/`addr`=address, `cnt`=count, `idx`=index, `ptr`=pointer, `dly`=delay, `ovfl`=overflow, `undfl`=underflow, `req`=request, `gnt`=grant, `pkt`=packet

## File Organization

- Entity and architecture in same file: `entity_name.vhdl`
- Alternative architectures: `entity_name_arch.vhdl`
- Testbenches: `tb_entity_name.vhdl`
- Packages: `name_pkg.vhdl`

## Python Tools

Located in `src/python/`:
- `GUI-qlaser/` - Control GUI for FPGA written in Python using tkinter
- ROM initialization and image generation utilities
