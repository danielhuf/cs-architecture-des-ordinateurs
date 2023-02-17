library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity alu_reg is
  port(clk          : in  std_logic;
       reset        : in  std_logic;
       in1, in2     : in  std_logic_vector(31 downto 0);
       op           : in  std_logic_vector(1 downto 0);
       ena          : in  std_logic;
       res          : out std_logic_vector(31 downto 0));
end alu_reg;

architecture behav of alu_reg is

signal alu_out      : std_logic_vector(31 downto 0);
signal alu_op       : std_logic_vector(1 downto 0);
signal RegWrite     : std_logic;

begin

--------------------------------------------------------------------------------
-- Control unit
-- + Generate the ALU control signal to select the required operation
--    | In a real CPU design this signal would result from decoding the instruction
--    | Suppose the ALU operation is already decoded and available in "Op" input
-- + Generate the write enable signal for the ALU result register 
--------------------------------------------------------------------------------
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
-- ALU
--------------------------------------------------------------------------------
-- Use the ALU from before

process (in1, in2, alu_op)
  begin
    case alu_op is 
      when "00" => 
        alu_out <= std_logic_vector(signed(in1) + signed(in2)); 
      when "01" => 
        alu_out <= std_logic_vector(signed(in1) - signed(in2)); 
      when "10" => 
        alu_out <= in1 and in2; 
      when "11" => 
        alu_out <= in1 or in2;     
      when others =>
        null;   
    end case;
  end process;

--------------------------------------------------------------------------------
-- Output register to save ALU result
--------------------------------------------------------------------------------
process (clk)
    begin
        if rising_edge(clk) then
            if(RegWrite = '1') then
                res <= alu_out;
                
            elsif(reset = '1') then
                res <= (others => '0');
            end if;

        end if;
  -- Complete the code for output res

end process;
  
end;