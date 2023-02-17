library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity datapath_and_control is
  port(clk      : in  std_logic;
       reset    : in  std_logic;
       inst     : in  std_logic_vector(31 downto 0); 
       inst_we  : in  std_logic;
       init     : in  std_logic);
end datapath_and_control;


architecture behav of datapath_and_control is

-- ALU signals
signal alu_in1  : std_logic_vector(31 downto 0);
signal alu_in2  : std_logic_vector(31 downto 0);
signal alu_out  : std_logic_vector(31 downto 0);  
signal alu_op   : std_logic_vector(1 downto 0);

-- Register file
type mem_array is array(7 downto 0) of std_logic_vector(31 downto 0);
signal reg_file: mem_array;
-- Why size 3 ?
signal Rreg1    : std_logic_vector(2 downto 0);
signal Rreg2    : std_logic_vector(2 downto 0);
signal Wreg     : std_logic_vector(2 downto 0);

signal RegWrite : std_logic;

-- Instruction fields
signal IR       : std_logic_vector(31 downto 0);
signal funct7   : std_logic_vector(6 downto 0);
signal funct3   : std_logic_vector(2 downto 0);
signal rs1      : std_logic_vector(4 downto 0);
signal rs2      : std_logic_vector(4 downto 0);
signal rd       : std_logic_vector(4 downto 0);
signal opcode   : std_logic_vector(6 downto 0);

signal exec     : std_logic;

begin

--------------------------------------------------------------------------------
-- Instruction register
--------------------------------------------------------------------------------
-- Complete the code for the signals: IR and exec
--  IR: the instruction register
--  exec: we generate an auxiliary signal pulse, 1 clock cycle wide, to enable the control unit 



--------------------------------------------------------------------------------
-- Control unit
-- + 1. Generate the ALU control signal alu_op to select the required operation
--    | In a real CPU design this signal would result from decoding the instruction
--    | Suppose the ALU operation is already decoded and available in "op" input
-- + 2. Generate the write signal RegWrite to store the result in the register file
-- + 3. Extract the address of source and destination operands in the register file
--------------------------------------------------------------------------------

-- Let's make it a bit closer to RISC-V
-- Define RISC-V R-type instruction field names
funct7  <= IR(31 downto 25);
rs2     <= IR(24 downto 20);
rs1     <= IR(19 downto 15);
funct3  <= IR(14 downto 12);
rd      <= IR(11 downto 7);
opcode  <= IR(6 downto 0);

-- 1. and 2.
-- Complete the code for alu_op and RegWrite

process (clk)
begin
    if rising_edge(clk) then
      if (inst_we = '1') then
          exec <= '1';
          IR <= inst;
      else
        exec <= '0';
      end if;
    end if;
end process;

Rreg1   <= rs1(2 downto 0);
Rreg2   <= rs2(2 downto 0);
Wreg    <= rd(2 downto 0);

--Control Unit
process(clk)
  begin 
    if rising_edge(clk) then
      if (exec = '1') then
        RegWrite <= '1';  
        case( funct7 ) is
          when "0100000" =>
            alu_op <= "01";
          when "0000000" =>
            case( funct3 ) is
              when "000" => 
                alu_op <= "00";
              when "110" =>
                alu_op <= "10";
              when "111" =>
                alu_op <= "11";    
              when others =>
                alu_op <= "00";
            end case ;
            when others =>
              alu_op <= "00";
          end case ;  
      else  
        RegWrite <= '0'; 
        alu_op <= "00";   
      end if;
    end if;
end process;
-- 3. 
-- Complete the code for the source and destination operands
-- Since our regfile and datapath is a stripped down version, 
-- we keep only the bits required to address the 8 registers of our register file


--------------------------------------------------------------------------------
-- Register file
-- Write: synchronous with the clock edge, write enable signal
-- Read: combinational outputs, no read enable signal
--------------------------------------------------------------------------------
-- Use the same register file as before...
alu_in1 <= reg_file(to_integer(unsigned(Rreg1)));
alu_in2 <= reg_file(to_integer(unsigned(Rreg2)));

process (clk) 
begin
    if rising_edge(clk) then 
        -- Complete the code for reg_file: check multi-ported memories on the slides
        if(RegWrite = '1') then
            reg_file(to_integer(unsigned(Wreg))) <= alu_out;
        end if;
        -- Dirty hack to initialize the register file for a simple, meaningful simulation. So, only for simulation purposes in this special case.
        -- This is NOT the way to do it for a real design
        if (reset = '1') then
          reg_file <= (0 => (others => '0'),
            1 => x"00000000",
            2 => x"00000000",
            3 => x"00000000",
            4 => x"00000000",
            5 => x"00000000",
            6 => x"00000000",
            7 => x"00000000",
            others => (others => '0'));
            
        elsif(init = '1') then
            reg_file <= (0 => (others => '0'),
            1 => x"00000001",
            2 => x"00000002",
            3 => x"00000003",
            4 => x"00000004",
            5 => x"00000005",
            6 => x"00000006",
            7 => x"00000007",
            others => (others => '0'));
        end if;
    end if;
end process;
  
--------------------------------------------------------------------------------
-- ALU
--------------------------------------------------------------------------------
-- Use the same ALU as before ...

process (alu_op,alu_in1,alu_in2)
  begin
    case alu_op is 
      when "00" => 
        alu_out <= std_logic_vector(signed(alu_in1) + signed(alu_in2)); 
      when "01" => 
        alu_out <= std_logic_vector(signed(alu_in1) - signed(alu_in2)); 
      when "10" => 
        alu_out <= alu_in1 and alu_in2; 
      when "11" => 
        alu_out <= alu_in1 or alu_in2;     
      when others =>
        null;   
    end case;
end process;

end behav;
