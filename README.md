# Synchronous FIFO — RTL Design & UVM Verification

A complete RTL-to-verification project implementing a parameterizable synchronous FIFO in SystemVerilog, verified with a structured UVM testbench featuring a scoreboard, functional coverage, and SVA assertions.

---

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [RTL Design](#rtl-design)
- [UVM Testbench Architecture](#uvm-testbench-architecture)
- [Verification Plan](#verification-plan)
- [SVA Assertions](#sva-assertions)
- [Functional Coverage](#functional-coverage)
- [How to Run](#how-to-run)

---

## Overview

| Item | Detail |
|---|---|
| **Module** | `fifo_sync` |
| **Language** | SystemVerilog (IEEE 1800-2017) |
| **Methodology** | UVM (Universal Verification Methodology) |
| **Default Config** | Depth = 8, Width = 8-bit |
| **Reset** | Asynchronous, active-low (`rst_n`) |
| **Output** | Registered (r_data valid 1 cycle after r_en) |

---

## Project Structure

```
.
├── fifo_sync.sv          # RTL — DUT
├── fifo_if.sv            # Interface + clocking blocks + SVA assertions
├── fifo_pkg.sv           # Package — imports all UVM classes
├── fifo_top.sv           # Testbench top module
│
├── fifo_transaction.sv   # UVM sequence item
├── fifo_sequence.sv      # Sequences (4 test modes)
├── fifo_driver.sv        # UVM driver
├── fifo_monitor.sv       # UVM monitor (prev-cycle latch)
├── fifo_scoreboard.sv    # Self-checking scoreboard (golden model)
├── fifo_coverage.sv      # Functional coverage collector
├── fifo_agent.sv         # UVM agent
├── fifo_env.sv           # UVM environment
└── fifo_base_test.sv     # UVM test (5-stage sequence)
```

---

## RTL Design

### Parameters

| Parameter | Default | Description |
|---|---|---|
| `Depth` | 8 | Number of FIFO entries. Must be a power of 2. |
| `Width` | 8 | Data bus width in bits. |

### Port List

| Port | Direction | Width | Description |
|---|---|---|---|
| `clk` | Input | 1 | Clock — all ops on posedge |
| `rst_n` | Input | 1 | Async active-low reset |
| `w_en` | Input | 1 | Write enable |
| `r_en` | Input | 1 | Read enable |
| `w_data` | Input | `[Width-1:0]` | Write data |
| `r_data` | Output | `[Width-1:0]` | Read data (registered) |
| `full` | Output | 1 | FIFO full flag |
| `empty` | Output | 1 | FIFO empty flag |

### Full/Empty Detection — Extended Pointer Technique

Pointers are `Depth_log + 1` bits wide. The extra MSB acts as a wrap-around bit:

```
empty = (r_ptr == w_ptr)
full  = (r_ptr[MSB] != w_ptr[MSB]) && (r_ptr[lower] == w_ptr[lower])
```

This eliminates the need for a separate occupancy counter and guarantees that `full` and `empty` are always mutually exclusive.

---

## UVM Testbench Architecture

```
fifo_top
├── fifo_sync (DUT)
├── fifo_if   (Interface + SVA)
└── fifo_env
    ├── fifo_agent
    │   ├── uvm_sequencer
    │   ├── fifo_driver     ──→ drives fifo_if via drv_cb clocking block
    │   └── fifo_monitor    ──→ samples fifo_if via mon_cb clocking block
    │                              │
    │                    analysis_port (ap)
    │                         ├──→ fifo_scoreboard
    │                         └──→ fifo_coverage
    └── fifo_sequence (4 modes)
```

### Key Design Decisions

**Dual clocking blocks** — `drv_cb` and `mon_cb` are separated in `fifo_if` to cleanly isolate stimulus from observation, preventing race conditions between driver and monitor.

**Prev-cycle latching in monitor** — because `r_data` is a registered output (available 1 cycle after `r_en`), the monitor captures `{w_en, r_en, w_data, full, empty}` from cycle N-1 and pairs them with `r_data` from cycle N before sending the transaction to the scoreboard. This ensures correct timing alignment.

**Self-checking scoreboard** — uses a SystemVerilog queue as a golden model. On every monitored write (`w_en && !full`), data is pushed. On every read (`r_en && !empty`), expected data is popped and compared against actual `r_data`.

---

## Verification Plan

The test runs in 5 sequential stages via `fifo_base_test`:

| Stage | Mode | Goal |
|---|---|---|
| 1 | `READ_EMPTY` | Verify underflow protection — reads on empty FIFO are ignored |
| 2 | `WRITE_FULL` | Verify overflow protection — writes on full FIFO are ignored |
| 3 | `DATA_STRESS` | Fill FIFO completely, then drain completely — corner case transitions |
| 4 | `RANDOM` (×200) | Randomized w_en/r_en traffic — broad functional coverage |
| 5 | `READ_EMPTY` | Final drain and cleanup |

A 1ms simulation timeout (`uvm_top.set_timeout`) guards against deadlocks.

---

## SVA Assertions

Three SystemVerilog Assertions are embedded directly in `fifo_if`:

| Assertion | Property | Severity |
|---|---|---|
| `A_MUTEX_FLAGS` | `full` and `empty` are never both asserted simultaneously | `$fatal` — simulation stops immediately |
| `A_EMPTY_STABLE` | `empty` stays high unless a write occurs | `$error` |
| `A_FULL_STABLE` | `full` stays high unless a read occurs | `$error` |

All assertions use `disable iff (!rst_n)` to suppress false firings during reset.

---

## Functional Coverage

Collected by `fifo_coverage` (extends `uvm_subscriber`) via the monitor's analysis port.

| Coverpoint / Cross | Description |
|---|---|
| `cp_w_en` | Write enable on/off |
| `cp_r_en` | Read enable on/off |
| `cp_full` | Full flag on/off + transitions `0→1`, `1→0` |
| `cp_empty` | Empty flag on/off + transitions `0→1`, `1→0` |
| `cross_w_r` | All combinations of w_en × r_en |
| `cross_write_full` | Write attempted while FIFO is full |
| `cross_read_empty` | Read attempted while FIFO is empty |

Coverage percentage is reported at end of simulation via `report_phase`.

---

## How to Run

This project can be run entirely in the browser via **[EDA Playground](https://www.edaplayground.com)** — no local installation required.

### Step-by-step

**1. Create a new playground**

Go to [edaplayground.com](https://www.edaplayground.com) and log in (free account required). Click **New Playground**.

**2. Configure the simulator**

In the left panel, under **Tools & Simulators**, select:
- **Simulator:** `Aldec Riviera-PRO` or `Cadence Xcelium` (both support UVM)
- **Language:** `SystemVerilog/Verilog`
- **UVM:** tick the **UVM** checkbox (adds `+incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv` automatically)

**3. Upload the files**

Add all `.sv` files to the playground. In the **testbench** tab paste or upload `fifo_top.sv`. In the **design** tab paste or upload `fifo_sync.sv`. All remaining files (`fifo_if.sv`, `fifo_pkg.sv`, `fifo_transaction.sv`, `fifo_sequence.sv`, `fifo_driver.sv`, `fifo_monitor.sv`, `fifo_scoreboard.sv`, `fifo_agent.sv`, `fifo_coverage.sv`, `fifo_env.sv`, `fifo_base_test.sv`) can be added as additional files via **+ Add file**.

**4. Set the top-level and compile options**

In the **Testbench** compile options box, add:

```
+incdir+. +UVM_TESTNAME=fifo_base_test
```

Set **Top entity** to:

```
fifo_top
```

**5. Run**

Click **▶ Run**. The log window will show UVM phase output, scoreboard PASS/FAIL results, and the final coverage percentage from `report_phase`.

**6. View waveform**

`fifo_top.sv` calls `$dumpfile` / `$dumpvars` automatically. After simulation completes, click **Open EPWave** to view the generated waveform in the browser.

### Expected output

```
UVM_INFO fifo_base_test.sv  : --- STAGE 1: RUNNING READ_EMPTY ---
UVM_INFO fifo_base_test.sv  : --- STAGE 2: RUNNING WRITE_FULL ---
UVM_INFO fifo_base_test.sv  : --- STAGE 3: RUNNING DATA_STRESS ---
UVM_INFO fifo_base_test.sv  : --- STAGE 4: RUNNING RANDOM ---
UVM_INFO fifo_base_test.sv  : --- STAGE 5: FINAL CLEANUP (READ_EMPTY) ---
UVM_INFO fifo_scoreboard.sv : FINAL REPORT: Matches: X, Errors: 0
UVM_INFO fifo_coverage.sv   : FINAL FUNCTIONAL COVERAGE: 100.00 %
```