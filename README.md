# Develop and validate UART VIP

## Introduce
My name is Nguyen Van Huy, and I am a course participant at ICTC (IC Training Center Vietnam). This article presents my work on develop and validate UART VIP, a project I have completed as part of my course at ICTC. The goal of this article is to show the knowledge and skills I have gained through my studies at ICTC and to demonstrate my abilities to potential employers in the field of Design Verification.

The Universal Asynchronous Receiver/Transmitter (**UART**) performs **serial-to-parallel** conversion for data received from a **peripheral device** and **parallel-to-serial** conversion for data received from the **CPU**. It includes **timing control** and an **interrupt system** to minimize **software overhead**.


## Summary of Input Documents for UART

In this section, I have summarized the key points from the "UART Specification" provided by the center.
For further details, please refer to the full documents linked below:
- [UART Slide Presentation](https://github.com/huynv1212/Uart_Verification/blob/b7d4db5c69995b3bbfcb4ec77676a7f98ebc095e/14.%20Project%202.%20Develop%20and%20validate%20UART%20VIP.pdf).
- [UART Specification Document](https://github.com/huynv1212/Uart_Verification/blob/dbb30989dad604e863c3684781a27175cdc2aa41/UART%20Protocol%20summary.pdf).

Summary uart specification:
- UART TX is high when idle
- Start Bit: Signals the beginning of data transmission, usually a single low bit.
- Data Bits: Typically 5 to 9 bits representing the actual data.
- Parity Bit (optional): Error-checking bit to detect single-bit errors.
- Stop Bit(s): Indicates the end of data transmission, typically one or two high bits.
- Baud Rate: Defines the rate of data transmission in bits per second (bps) and needs to match on
both transmitting and receiving UART. Common baud rate: 4800, 9600, 19200, 57600 and
115200

## Tools and Methodology Used
Tools and Methodology Used
- Language: SystemVerilog for writing testbenches and verification components.
- Methodology: UVM for building a structured and reusable verification environment.
- EDA Tool: QuestaSim for simulation and debugging.
## Verification Structure Design
Below is a picture describing the Testbench structure to verify the VIP
![Testbench structure to verify the VIP](Structure_env.png)

Top-Level (`uart_test`)

  The outermost layer of the testbench. It contains:
- **Environment (`uart_env`)**: The main testing structure.
- **Configuration (`uart_lhs_config` and `uart_rhs_config`)**: These blocks define specific settings for the left-hand and right-hand agents. Settings include baud rate, data bits, parity, and stop bits. They ensure that both agents operate correctly within the test environment, with the goal of verifying the correctness of the UART VIP.

Environment (`uart_env`)

  The environment includes:
- **Agents**: Simulate and monitor UART behavior on both sides.
- **Scoreboard**: Verifies data correctness by comparing what is sent and received, and also checks that the baud rate is correct.

Agents (`uart_lhs_agent` and `uart_rhs_agent`)

- **`uart_lhs_agent`**: Simulates one side of the UART (left-hand side).
- **`uart_rhs_agent`**: Simulates the other side (right-hand side).

  Each agent contains:
- **Monitor**: Observes UART signals like TX and RX without interfering.
- **Driver**: Sends test data to the UART under sequencer control.
- **Sequencer**: Decides the order and type of data sent to the driver.

Scoreboard (`uart_scoreboard`)

  This component checks whether the UART is functioning correctly. It compares:
- **Data** transmitted by one agent (TX) and received by the other agent (RX).
- **Baud rate** to ensure that both agents are operating at the correct speed and that the transmission matches the configured baud rate.

Interfaces (`uart_interface`)

  These represent the physical UART connections:
- **`TX_LHS` and `RX_LHS`**: Connect to the left-hand side of the UART.
- **`TX_RHS` and `RX_RHS`**: Connect to the right-hand side.

Device Under Test (`uart_dut`)

  The UART design being verified. It connects to the testbench through the UART interfaces.


## Verification Plan Design

This section presents the Verification Plan Design (VPLAN) for the UART VIP. The VPLAN outlines the various tests implemented to ensure the correctness and **stability** of the UART VIP design. Each test focuses on different aspects of the UART functionality, including data transmission, stop bits, baud rate, parity, and more.

 Test Cases

 uart_lhs sends, uart_rhs receives:
- **TX/RX Test**: Verify data transmission and reception.
- **Stop Bit Test**: 1 Stop bit, 2 Stop bits.
- **Data Bits Test**: 5, 6, 7, 8, 9 Data Bits.
- **Baud Rate Test**: 4800, 9600, 19200, 57600, 115200, Custom (1200).
- **Parity Check**: Even, Odd, No Parity.
- **Combination Test**: Various combinations of Baud Rate, Data Bits, Parity, Stop Bit.

 uart_rhs sends, uart_lhs receives:
- **TX/RX Test**: Verify data transmission and reception.
- **Stop Bit Test**: 1 Stop bit, 2 Stop bits.
- **Data Bits Test**: 5, 6, 7, 8, 9 Data Bits.
- **Baud Rate Test**: 4800, 9600, 19200, 57600, 115200, Custom (1200).
- **Parity Check**: Even, Odd, No Parity.
- **Combination Test**: Various combinations of Baud Rate, Data Bits, Parity, Stop Bit.

 Combination uart_lhs, uart_rhs sends and receives:
- **TX/RX Test**: Verify data transmission and reception between both.
- **Stop Bit Test**: 1 Stop bit, 2 Stop bits.
- **Data Bits Test**: 5, 6, 7, 8, 9 Data Bits.
- **Baud Rate Test**: 4800, 9600, 19200, 57600, 115200, Custom (1200).
- **Parity Check**: Even, Odd, No Parity.
- **Combination Test**: Various combinations of Baud Rate, Data Bits, Parity, Stop Bit.

 Configuration Differences:
- **Baud Rate, Stop Bit, Data Bit, Parity Bit**: Check configuration differences between uart_lhs and uart_rhs tests.

For the full details of the Verification Plan, you can access the complete document [Verificaiton Plan](https://github.com/huynv1212/UartVIP_Validate/blob/903e1a611db39d9579050f9294129ad9d9d820a3/Vplan_UART_nguyenvanhuy%20_ver2.pdf).

## Verification Environment Design and Develop
VIP design file:

./uart_project/

rtl/

- [uart_dut.sv](https://github.com/huynv1212/UartVIP_Validate/blob/e48f88ff2dee80b85d31d7b4f32b3cc3e783d7aa/uart_dut.sv)
  
sequences/

- [seq_pkg.sv](https://github.com/huynv1212/UartVIP_Validate/blob/665601db6a5d7be7f2dec6c5bbd0dbff449aa172/seq_pkg.sv)
- [uart_even_sequence.sv](https://github.com/huynv1212/UartVIP_Validate/blob/8c9dcdca5c31916e94014b483c457792254815bf/uart_even_sequence.sv)
- [uart_lhs_txrx_sequence.sv](https://github.com/huynv1212/UartVIP_Validate/blob/60e19e3dad8b51550d6e4ab84773c1e632b1fa8d/uart_lhs_rhs_sequence.sv)
- [uart_odd_sequence.sv](https://github.com/huynv1212/UartVIP_Validate/blob/134b1c842e4b1ba6b0caba7acb7d6f6319c65d8d/uart_odd_sequence.sv)
 
sim/

- compile.f
- Makefile
- project_env.bash
- regress.cfg
- regress.pl
- regress.rpt
- rtl.f
- tb.f
  
tb/

- [env_pkg.sv](https://github.com/huynv1212/UartVIP_Validate/blob/35ae756344e20a3c525e332bc83b54c7026c64dc/env_pkg.sv)
- [testbench.sv](https://github.com/huynv1212/UartVIP_Validate/blob/2288af881aea117b09f7c011f67e83f1265015dc/testbench.sv)
- [uart_environment.sv](https://github.com/huynv1212/UartVIP_Validate/blob/c3d75c0b5ae23496699fc86b5a339221e4778ef3/uart_environment.sv)
- [uart_scoreboard.sv](https://github.com/huynv1212/UartVIP_Validate/blob/1aefa1c21b93f72fbcc2ae4696f8ae181343b8e7/scoreboard.sv)
  
testcases/

- test_pkg.sv
- [uart_test.sv](https://github.com/huynv1212/UartVIP_Validate/blob/9901fdd242c802114fac009e82c8aa94d358c2ba/uart_test.sv)
- [uart_lhs_rhs_combination2_test.sv](https://github.com/huynv1212/UartVIP_Validate/blob/eaf95e93739119f6c9966345638fb0f053203ffe/uart_lhs_rhs_combination2_test.sv)
- uart_difference_combination_test.sv
- .............
- uart_lhs_19200baudrate_test.sv
- uart_lhs_115200baudrate_test.sv
  
uart_vip/

- [uart_agent.sv](https://github.com/huynv1212/UartVIP_Validate/blob/bb58ebcf00620a067e6b9918140fceadda3aca6b/uart_agent.sv)
- [uart_configuration.sv](https://github.com/huynv1212/UartVIP_Validate/blob/4df6a20b5a8e08781f07a6e38183646d5a598417/uart_configuration.sv)
- [uart_driver.sv](https://github.com/huynv1212/UartVIP_Validate/blob/09ddbb89a84d94197ad9c0cb26aef21e03b9c315/uart_driver.sv)
- [uart_if.sv](https://github.com/huynv1212/UartVIP_Validate/blob/2790a70e5cc3ffb7239bf06d53abe1994baf3455/uart_if.sv)
- [uart_monitor.sv](https://github.com/huynv1212/UartVIP_Validate/blob/dd766cb1d53793542d48ce4554788be1a613a2f0/uart_monitor.sv)
- [uart_pkg.sv](https://github.com/huynv1212/UartVIP_Validate/blob/1b6b57323525714f1c09d683991581f2e61ed47d/uart_pkg.sv)
- [uart_sequencer.sv](https://github.com/huynv1212/UartVIP_Validate/blob/07ae2b5a13eeba588bb64ffda86e798531e2dfcd/uart_sequencer.sv)
- [uart_transaction.sv](https://github.com/huynv1212/UartVIP_Validate/blob/99d9b0798eb6cee7d496df260af9e9efb50878be/uart_transaction.sv)
- uart_vip.f

## Simulation and Waveform
COMING SOON!

## Conclusion and Acknowledgment
COMING SOON!


