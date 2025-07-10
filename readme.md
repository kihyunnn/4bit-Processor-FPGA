# 16-bit MIPS-like Microprocessor in Verilog

## 1. Project Overview

This project is a Verilog HDL implementation of a simplified 16-bit MIPS-like microprocessor, designed and verified on a Xilinx Zybo-Z7 FPGA board. It processes 16-bit instructions entered via physical switches and buttons, performs arithmetic and logical operations, and displays the results on LEDs and 7-Segment Displays (SSDs).

The primary goal was to build a complete, functional system by designing and integrating the core components of a microprocessor: **I/O**, a **Control Unit**, a **Register File**, and an **Arithmetic Logic Unit (ALU)**.

---

## 2. Development Environment

*   **Hardware**: Digilent Zybo-Z7-20 FPGA Board
*   **Software**: Xilinx Vivado 2019.2

---

## 3. How to Use

The processor is controlled using the switches and buttons on the FPGA board.

1.  **Reset**: Press **BTN3** at any time to reset the processor and return to the `Idle` state.
2.  **Instruction Input**: Input the 16-bit instruction in 4 steps using the 4 rightmost switches (**SW0-SW3**).
    *   **Step 1 (Opcode)**: Set `SW0-SW3` to the desired `Opcode` value and press **BTN0**.
    *   **Step 2 (Rd1)**: Set `SW0-SW3` to the `Rd1` address and press **BTN0**.
    *   **Step 3 (Rd2)**: Set `SW0-SW3` to the `Rd2` address and press **BTN0**.
    *   **Step 4 (Wr)**: Set `SW0-SW3` to the `Wr` address and press **BTN0**.
3.  **Execution**: After the final input step, the processor automatically enters the `Execute` state.
4.  **View Result**: Once execution is complete, the `Done` state is reached.
    *   The 4-bit result is displayed on the 4 rightmost LEDs.
    *   The result is also shown on the 7-Segment Displays.
    *   If an **overflow** occurs, the SSDs will display "OVFL".
    *   While in the `Done` state, **hold BTN1** to view the original instruction you entered on the SSDs.

---

## 4. Project Structure

*   **Source Code**: All Verilog source files (`.v`) are located in:
    `digital_system_final3/digital_system_final3.srcs/sources_1/new/`
*   **Constraints File**: The pin constraints for the Zybo-Z7 board are in:
    `digital_system_final3/Zybo-Z7-Master.xdc`
*   **Vivado Project**: The main project file is:
    `digital_system_final3/digital_system_final3.xpr`

---

## 5. Detailed Architecture

### 5.1. Instruction Format

Each instruction is 16 bits wide, divided into four 4-bit fields:

| Bits    | 15:12  | 11:8 | 7:4 | 3:0 |
| :------ | :----: | :--: | :--: | :-: |
| **Field** | Opcode | Rd1  | Rd2  | Wr  |

### 5.2. Core Modules

*   **`io_block`**: The top-level module that connects all sub-modules and maps them to the FPGA's physical I/O.
*   **`mips_fsm`**: A 7-state FSM (`Idle`, `Input 1-4`, `Execute`, `Done`) that controls the entire operation sequence.
*   **`mips_counter`**: Processes button inputs, generating single-clock pulses from `debouncer` modules to ensure clean state transitions.
*   **`control`**: Decodes the `Opcode` to generate control signals (`RegWrite`, `ALUSrc`, `ALUOp`).
*   **`register`**: A 16x4-bit register file. Register 0 is hardwired to zero. Writes are gated by `RegWrite` and the `overflow` flag to ensure data integrity.
*   **`alu`**: Performs 16 different arithmetic/logic operations. It uses a custom-designed **Carry Lookahead Adder (`cla4`)** for high-speed addition and subtraction.
*   **`hex2ssd`**: Converts 4-bit hex values to 7-segment display signals, with special logic to show "OVFL" on overflow.
