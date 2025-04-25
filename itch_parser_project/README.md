# FPGA-Based ITCH Parser with Partial TCP Segment Framing

## 🧠 Overview

This project showcases a modular, latency-aware FPGA pipeline designed for **market data parsing** in **high-frequency trading (HFT)** systems. It focuses on extracting and decoding **Nasdaq TotalView-ITCH messages**, which are delivered over **TCP**, but without implementing a full TCP/IP stack in hardware.

Instead, the design assumes a realistic HFT architecture where:
- **TCP offloading** is handled by NICs or soft logic
- The **FPGA receives a clean ITCH byte stream**
- The **core logic operates in deterministic hardware** for minimal latency

The project includes:
- A **TCP Segment Stripper** that parses headers and extracts clean payload
- A **Header Parser FSM** that detects ITCH message boundaries
- A **Payload Dispatcher** for routing to future message decoders
- A complete **Cocotb simulation testbench** with randomized and corner-case coverage
- Optional **VCD waveform dumping** and visualization via GTKWave

---

## 🎯 Goals

- Showcase strong **digital design and verification skills** using Verilog + cocotb
- Demonstrate architectural awareness of **low-latency HFT data paths**
- Deliver a clean, pipelined, modular design that mimics **real-world FPGA trading logic**
- Provide **industry-aligned artifacts** that could integrate into larger HFT infrastructure

---

## 🧩 Architecture

      [ Ethernet / TCP Stack ]
               ↓
      (TCP handled externally)
               ↓
     [ tcp_segment_stripper.v ]
     • Parses TCP header
     • Outputs clean ITCH stream
               ↓
     [ itch_parser.v ]
     • FSM extracts msg_type, msg_len
     • Emits new_msg flag
               ↓
     [ payload_dispatcher.v ] (optional)
     • Routes payload to handler by msg_type
               ↓
        [ Order Book / Strategy ]

---

## 🛠️ Technologies

- **Language:** Verilog HDL
- **Simulation/Testbench:** [Cocotb](https://cocotb.readthedocs.io/)
- **Simulator:** Icarus Verilog
- **Waveform Viewer:** GTKWave
- **Platform:** Alinx AX7050 (Spartan-7 FPGA)
- **Development Workflow:** VS Code (Windows) + WSL (Linux) + Git

---

## 📦 Deliverables

### RTL Modules
| Module                    | Description                                              |
|---------------------------|----------------------------------------------------------|
| `tcp_segment_stripper.v`  | Parses TCP headers and extracts payload (no retransmit) |
| `itch_parser.v`           | FSM that reads 1-byte message type + 2-byte length      |
| `payload_dispatcher.v`    | (Optional) Routes messages to type-specific decoders    |

### Testbenches
| File                      | Description                                              |
|---------------------------|----------------------------------------------------------|
| `test_itch_parser.py`     | Unit tests for header parser using Cocotb               |
| `test_tcp_stripper.py`    | Stimulus for simulating valid TCP segments              |
| `helpers.py`              | Utility functions for driving inputs and checking outputs |

### Simulation
- **Makefile** for Icarus Verilog simulation (`make`)
- Generates `dump.vcd` for waveform analysis
- Compatible with GTKWave

---

## ✅ Test Coverage

- [x] Valid ITCH header parsing
- [x] Multiple headers back-to-back
- [x] Randomized headers
- [x] Reset mid-stream recovery
- [x] TCP packet framing with valid ports/offsets
- [ ] (Planned) Payload decoders for Add/Delete/Modify Order

---

## 📈 Future Work

- Add full ITCH message format decoders (`'A'`, `'D'`, `'E'`, etc.)
- Hook into a simulated order book
- Integrate with a kernel-bypass TCP engine for live capture
- Add FIFO-based backpressure logic between modules

---

## 🤝 Who Is This For?

- FPGA verification engineers preparing for **HFT firm interviews**
- Engineers curious about **low-latency streaming protocols**
- Students looking to simulate **real-world FPGA data pipelines**
- Hardware teams prototyping **FPGA-based market data handlers**

---

## 📄 License

MIT License. Open for academic and portfolio use.  
Please reach out if you're interested in extending or collaborating.

https://www.dropbox.com/scl/fi/8bhhzzbea2lyggvk4eqy2/itch_parser_project.zip?rlkey=xntczlg7c9wfvp5oxoi89hiq3&st=tww9jsud&dl=0