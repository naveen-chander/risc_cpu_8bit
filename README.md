# Building an 8-bit RISC CPU (from scratch)

## Table of Contents

1. [Overview](#overview)
2. [Requirements] (#req)
3. [Setup ](#setup)
4. [Running Postlayout Simulations](#Postlayout)


<a name="overview"></a>
### Overview
This repository contains an IP to build a simple 8-bit RISC CPU with 15 instructions. 
All buses and instructions are 8 bit.
A test program to get the sum of first 10 natural numbers is provided in the test bench.

<a name="req"></a>
### Requirements
All sources are written in VHDL targeted at Atrix-7 (xc7a35t device) 
The repository has been tested on Xilinx Vivado 2018.2 
If the user wants to port it to any other FPGA, then the user needs to do the following:
* Copy all sources
* Instantiate 2 x synchronous DP_RAMS of size 256 x 8 with Chip Enable, Read and Write Enable.
	Address and Data bus can be common.
```

<a name="setup"></a>
### Setup 

* Clone the github 
   ```
   $ git clone https://github.com/naveen-chander/risc_cpu_8bit.git 
   ```
* Create a new project and all add sources from the /src directory
   ```
   
* From sim folder, use tb_top as testbench.
   ```
   
* instructions.txt and data.txt should be included in the simulation folder as it contains the required code and data. 

<a name="POstlayout"></a>
### Running Postlayout Simulations 
* If you are using Vivado, then post layout simulation can be seen by adding tb_top_behav.wcfg file 
```
* Runtime : 20 us
```

