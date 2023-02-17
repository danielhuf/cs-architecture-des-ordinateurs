################################## Members of the project ##################################

- Daniel Stulberg Huf
- Lawson Oliveira Lima
- Lucas Vitoriano de Queiroz Lira

##################################### Project overview #####################################

The goal of this project was to build a RISC-V processor in VHDL capable of executing a part
of the instruction set provided by the architecture, and that in the end would run an 
application that performs a screen display. The explanation of the project development will 
be split in sections that represent each part of the processor design.

###################################### Control section ######################################

This section takes into consideration the development of the file 'vdh/CPU_PC.vhd'. Firstly,
we initialized the signals in the beginning of the process for the execution to work properly.
Then, we developed each case that will be treated in the S_Decode state, which will decide
the next state according to the instruction encoding. With exception to the branch and jump 
type instructions, the PC was incremented by 4 before changing from the S_Decode state to
the next instruction correspondant state. It is valid to say that each operation is 
associated with a control state, as it will be carried out in one cycle. 

Alongside with the code, a Finish State Machine was added to the repository in order to 
graphically explain each step for executing an instruction.

##################################### Operating section #####################################

In accordance with the architectural design containing the operating datapath, we developed 
the control for each instruction of all the families, which will be briefly described below:

U-type instructions: Instructions with upper imediates. The X and Y operands from the 
register file are properly selected and the signal to write in the register file is enabled,
wich will receive the result of these two operands. The validation of a read transaction to 
memory in order to retrieve the next instruction to be executed (pointed by PC) is also 
performed in the same state of the U-type instruction itself. After that, the next step will 
be passing directly to the S_Fetch state. 

Arithmetic and logic instructions: The writing in the register file is validated after 
selecting the Y operand from ALU and either an arithmetic, logical or shift ALU operation. 
Then, the origin of the data to be written in the register file is selected, and this step is
followed by the validation of a read transaction to memory in order to retrieve the next 
instruction to be executed (pointed by PC). After that, the execution is passed directly to 
the S_Fetch state. 

Branch instructions: The Y operand from the ALU receives the value contained in rs2. Then, if 
the branch is validated, the PC is increased by a constant value, otherwise it is update by 
adding 4. The validation of a read transaction to memory in order to retrieve the next 
instruction to be executed happens in a next state, called 'WriteNewInstructionInPC'. 

Load from memory instructions: Firstly, the immediate is selected to add with the value of rs1.
The address of the data coming from AD is also assigned to the memory. Both the signals to 
read from memory and to write in the AD are enabled. In order to adjust the parameters of the 
load instruction, the type of data (word, half-word or byte) to write in the register file and 
the sign-extension (enabled or not) are properly set for each instruction of the family. The 
next step will be passing to a next state called 'LoadFromMemory', which will be responsable 
for assigning the data coming from memory to the destination register in the register file. 
To do that, the signal to write in the register file is enabled. Just like the conditional 
branch instructions, the validation of a read transaction to memory in order to retrieve the 
next instruction to be executed happens in a next state, called 'ReadNextPCInstruction'. 

Save in memory instructions: Firstly, the immediate is selected to add with the value of rs1. 
Then, the writing into AD is enabled. The next step will be passing to a next state called 
'SaveInTheMemory', which will be responsable for assigning the address of the data coming 
from AD to memory. Then, the signal to write in memory is enabled. Just like the conditional 
branch instructions, the validation of a read transaction to memory in order to retrieve the 
next instruction to be executed happens in the 'ReadNextPCInstruction' state.

Jump instructions: the destination register is updated in both the jal and jalr instructions 
by selecting the X and Y operands in the register file with the value of PC and the constant 4, 
consecutively. Then, the writing in the register file is validated by summing these two 
operands. In order to update the value of PC, either the PC value will be added to a constant 
(jal case) or the value of rs1 will be added to a constant (jalr case). The signal to write in 
the PC is validated on both cases. Just like the conditional branch instructions, the 
validation of a read transaction to memory in order to retrieve the next instruction to be 
executed happens in the 'WriteNewInstructionInPC' state. 

Before all of the instructions above, with exception of the jump and branch cases, it was 
first necessary to increment PC in the S_Decode state.

We have also completed the vhdl code of the file 'vdh/CPU_CND.vhd', which contains the entity
responsible for the jump condition of the processor and is in accordance with the datapath 
that was designed. 

################################# Validation of instructions ################################

All of the 37 instructions have been properly tested and commented. The print containing the
validation of all the autotest is in the file 'Autotests_result.png' present in the repository.

