library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity alu_regfile is
  port(clk      : in  std_logic;
       reset    : in  std_logic;
       op       : in  std_logic_vector(1 downto 0);
       Rreg1    : in  std_logic_vector(2 downto 0);
       Rreg2    : in  std_logic_vector(2 downto 0);
       Wreg     : in  std_logic_vector(2 downto 0);
       ena      : in  std_logic;
       res      : out std_logic_vector(31 downto 0);
       init     : in  std_logic);
end alu_regfile;


architecture behav of alu_regfile is

-- ALU signals
signal alu_in1  : std_logic_vector(31 downto 0);
signal alu_in2  : std_logic_vector(31 downto 0);
signal alu_out  : std_logic_vector(31 downto 0);  
signal alu_op   : std_logic_vector(1 downto 0);

-- Register file
type mem_array is array(7 downto 0) of std_logic_vector(31 downto 0);
signal reg_file: mem_array;
signal RegWrite : std_logic;
  
begin

--------------------------------------------------------------------------------
-- Control unit
-- + Generate the ALU control signal to select the required operation
--    | In a real CPU design this signal would result from decoding the instruction
--    | Suppose the ALU operation is already decoded and available in "op" input
-- + Generate the write signal to store the result in the register file
--------------------------------------------------------------------------------
-- Use the control unit from before

process (clk)
begin
    if rising_edge(clk) then
        if (reset = '1') then
            alu_op      <= (others => '0');
            RegWrite    <= '0';    
        elsif (ena = '1') then
            alu_op <= op;   
            RegWrite <= '1';
            -- Complete the code for alu_op and RegWrite
        else
            RegWrite <= '0';
            -- Complete the code to make RegWrite active only 1 clock cycle
        end if;
    end if;
end process;

--------------------------------------------------------------------------------
-- Register file
-- Write: synchronous with the clock edge, write enable signal
-- Read: combinational outputs, no read enable signal
--------------------------------------------------------------------------------
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

-- Complete the code
-- Register file outputs are the ALU inputs
            
alu_in1 <= reg_file(to_integer(unsigned(Rreg1)));
alu_in2 <= reg_file(to_integer(unsigned(Rreg2)));

  
--------------------------------------------------------------------------------
-- ALU
--------------------------------------------------------------------------------
-- Use the ALU from before

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

--------------------------------------------------------------------------------
-- Output
--------------------------------------------------------------------------------
-- Assign the output

res <= alu_out;

end behav;
