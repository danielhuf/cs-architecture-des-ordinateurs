library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity alu is
  port(in1          : in  std_logic_vector(31 downto 0);
       in2          : in  std_logic_vector(31 downto 0);
       op           : in  std_logic_vector(1 downto 0);
       res          : out std_logic_vector(31 downto 0));
end alu;

architecture behav of alu is
begin
  process (in1, in2, op)
  begin
    case op is 
      when "00" => 
        res <= std_logic_vector(signed(in1) + signed(in2)); 
      when "01" => 
        res <= std_logic_vector(signed(in1) - signed(in2)); 
      when "10" => 
        res <= in1 and in2; 
      when "11" => 
        res <= in1 or in2;     
      when others =>
        null;   
    end case;
  end process;
end;