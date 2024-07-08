## Compilation and Use of HDL
This was compiled and ran using Icarus Verilog (iverilog) but alternatives exist. The commands used are below.

Compile:
`iverilog -o SA_TB MAC.v MEM44.v SA.v SA_TB.v`

Run:
`vvp SA_TB`

## How to use the system

### Reset
First step is to reset and initalize the clock. Bring the 'rst' pin high, and set the 'clk' register low. You will also want to set the 'we' (Write Enable) and 'ena' (Enable) pins low.

### Loading
1. First, we write the matrices and activation function threshold. When writing to anything, set the write-enable pin 'we' high. 

2. To write to the weight memory, set the 'sel' pin to 0. For each byte, set 'data_in' to your value and the 'addr' pin to the address. The address is four bits going from matrix position (1,1) over and down until the last position (4,4). The first four addresses will therefore fill the first row. Each data must be clocked in by toggling the clock pin on and off.

3. To load the feature matrix you repeat the same steps setting the address, data and clocking it in. This time we must set the 'sel' pin to 1

4. Finally, to load the activation function threshold, set 'sel' to 2, 'data_in' to the threshold value, and clock it in. The 'addr' pin is not meaninful for this case.

### Multiplication
Now that the system is ready set the 'we' pin low and the 'ena' pin high. This enables the system to start loading and multiplying. You must toggle the clock at least 20 times to completely load, multiply, and write back the product. If you want to print the memory use the naming hiearchy and directly access it as in the provided testbench. For the purposes of this project, there is no defined memory interface so we read it informally this way.

## Files
- **MAC**
    : Multiply-and-Accumulate unit that forms the Systolic Array when used in a grid
  
- **MEM44**
    : Simply addressable memory used to facilitate storing the matrix values and product results. These have a 4x4 structure of 8b words. Data is written one word at a time based on the address given. A whole column can be read out at once using the two LSBs in the address

- **SA**
    : The full Systolic Array structure with control logic and component instantiation.

- **_tb**
    : any file with a _tb is just the testbench for that piece. The SA_TB is the most important to run the whole system.
