library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity alu_tb is
end alu_tb;
 
-- Testbench for alu
architecture behavior of alu_tb is

-- Component for the UUT
component alu is
  port(in1      : in  std_logic_vector(31 downto 0);
       in2      : in  std_logic_vector(31 downto 0);
       op       : in  std_logic_vector(1 downto 0);
       res      : out std_logic_vector(31 downto 0));
end component;
 
-- Test signals
signal in1_tb   : std_logic_vector(31 downto 0);
signal in2_tb   : std_logic_vector(31 downto 0);
signal op_tb    : std_logic_vector(1 downto 0);
signal res_tb   : std_logic_vector(31 downto 0);

begin
 
 -- Instantiate the Unit Under Test (UUT)
uut: alu PORT MAP (
    in1     => in1_tb,
    in2     => in2_tb,
    op      => op_tb,
    res     => res_tb
);

stim_proc: process
    begin
    wait for 40 ns;
    in1_tb <= x"00000002";
    in2_tb <= x"00000003";
    op_tb  <= "00";--add (result should be 5)
  
    wait for 40 ns;
    in1_tb <= x"00000009";
    in2_tb <= x"00000003";
    op_tb  <= "01";--subtract (result should be 6)
    
    wait for 40 ns;
    in1_tb <= x"0000FFFF";
    in2_tb <= x"000000FF";
    op_tb  <= "10";--AND (result should be x"000000FF")
    
    wait for 40 ns;
    in1_tb <= x"0000FFFF";
    in2_tb <= x"FFFF0000";
    op_tb  <= "11";--OR (result should be x"FFFFFFFF")

    wait for 40 ns;
end process;

end;