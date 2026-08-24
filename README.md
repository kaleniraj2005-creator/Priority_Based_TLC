# Priority_Based_TLC
# Traffic Light Controller using Verilog HDL

## Overview

This project implements a **four-way traffic light controller using Verilog HDL**.

The controller manages traffic lights for four directions:

* North
* East
* South
* West

The design is implemented using a **Finite State Machine (FSM)** and includes traffic sensors, emergency vehicle priority, timing control, and starvation-prevention logic.

The design and testbench were developed and **verified using EDA Playground**.

## Features

* Four-way traffic light control
* FSM-based traffic controller
* Green and yellow light timing
* Traffic sensor-based control
* Emergency vehicle priority
* Starvation prevention using wait counters
* Automatic state transitions
* Verilog testbench for functional verification
* Simulation and waveform verification using EDA Playground

## FSM States

The controller uses 8 states:

| State      | Description                      |
| ---------- | -------------------------------- |
| `N_GREEN`  | North direction has green light  |
| `N_YELLOW` | North direction has yellow light |
| `E_GREEN`  | East direction has green light   |
| `E_YELLOW` | East direction has yellow light  |
| `S_GREEN`  | South direction has green light  |
| `S_YELLOW` | South direction has yellow light |
| `W_GREEN`  | West direction has green light   |
| `W_YELLOW` | West direction has yellow light  |

The states are represented using a 3-bit state variable.

## Timing

The controller uses the following timing values:

| Parameter         |           Value |
| ----------------- | --------------: |
| Green time        | 10 clock cycles |
| Yellow time       |  3 clock cycles |
| Maximum wait time |  4 clock cycles |

These values are defined in the Verilog design as timing parameters.

## Inputs

| Input       |  Width | Description                        |
| ----------- | -----: | ---------------------------------- |
| `clk`       |  1 bit | Clock signal                       |
| `rst`       |  1 bit | Active-high reset                  |
| `sensor`    | 4 bits | Traffic detection inputs           |
| `emergency` | 4 bits | Emergency vehicle detection inputs |

The design uses four sensor inputs corresponding to the four traffic directions.

## Outputs

| Output    |  Width | Description         |
| --------- | -----: | ------------------- |
| `light_N` | 3 bits | North traffic light |
| `light_E` | 3 bits | East traffic light  |
| `light_S` | 3 bits | South traffic light |
| `light_W` | 3 bits | West traffic light  |

The traffic light encoding is:

```text
RED    = 3'b100
YELLOW = 3'b010
GREEN  = 3'b001
```

## How the Controller Works

The controller starts in the `N_GREEN` state after reset.

Each direction goes through:

```text
GREEN → YELLOW → Next Direction GREEN
```

The next direction is selected according to the controller's priority logic.

The controller considers:

1. Emergency vehicle detection
2. Starvation/wait conditions
3. Traffic sensor detection
4. Default direction selection

The next-state logic is implemented using combinational FSM logic.

## Emergency Vehicle Priority

The controller provides priority to emergency vehicles.

The `emergency[3:0]` input represents emergency conditions for the four directions.

Emergency conditions are checked before normal sensor conditions when selecting the next traffic direction.

For example, after the North yellow state, the controller checks emergency inputs before checking normal traffic sensors.

## Starvation Prevention

To prevent one direction from waiting indefinitely, the design contains four wait counters:

```text
wait_N
wait_E
wait_S
wait_W
```

When traffic is detected on a direction that is not currently being served, its wait counter increases until the maximum wait value is reached.

When that direction receives service, its wait counter is reset.

This provides a mechanism to give priority to directions that have been waiting for a longer time.

## Testbench

The project includes a separate Verilog testbench:

```text
traffic_controller_tb.v
```

The testbench:

* Generates the clock
* Applies reset
* Provides different sensor inputs
* Provides emergency inputs
* Waits for specific clock cycles
* Displays the current FSM state
* Displays timer values
* Displays starvation wait counters
* Displays traffic-light outputs
* Generates a VCD dump for simulation

## Verification

The design was **simulated and verified on EDA Playground**.

Different test scenarios were applied to verify:

* Normal traffic operation
* Traffic sensor-based state transitions
* Emergency priority
* Starvation prevention
* Traffic-light outputs
* FSM state transitions

The testbench applies multiple sensor and emergency combinations during simulation.

## EDA Playground

The project was developed and tested using **EDA Playground**.

The testbench also generates a VCD waveform using:

```verilog
$dumpfile("dump.vcd");
$dumpvars(0,traffic_controller_tb);
```

## Project Structure

The GitHub repository contains two Verilog source files:

```text
Traffic-Light-Controller/
│
├── traffic_controller.v
├── traffic_controller_tb.v
└── README.md
```

### `traffic_controller.v`

Contains the main traffic light controller design and FSM.

### `traffic_controller_tb.v`

Contains the testbench used to simulate and verify the design on EDA Playground.

## Tools Used

* **Verilog HDL**
* **EDA Playground**
* **VS Code** — used to organize/store the Verilog source files

## Author

**Niraj Kale**

## Purpose

This project was developed as a **Verilog HDL / VLSI design project** to understand:

* Finite State Machines
* Sequential and combinational logic
* Traffic light controller design
* Timing control
* Priority logic
* Starvation prevention
* Verilog testbench development
* RTL simulation and verification
