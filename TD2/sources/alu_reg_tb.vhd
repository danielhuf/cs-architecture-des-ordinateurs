library ieee;
use ieee.std_logic_1164.all;

entity alu_reg_tb is
end alu_reg_tb;

-- Testbench for alu_reg
architecture behavior of alu_reg_tb is

-- Component declarationfor the DUT
component alu_reg is
    port(clk        : in  std_logic;
         reset      : in  std_logic;
         in1, in2   : in  std_logic_vector(31 downto 0);
         op         : in  std_logic_vector(1 downto 0);
         ena        : in  std_logic;
         res        : out std_logic_vector(31 downto 0));
end component;
 
-- Test signals
signal clk_tb       : std_logic := '0';
signal reset_tb     : std_logic := '0';
signal in1_tb     : std_logic_vector(31 downto 0);
signal in2_tb     : std_logic_vector(31 downto 0);
signal op_tb        : std_logic_vector(1 downto 0);
signal ena_tb       : std_logic := '0';
signal res_tb   : std_logic_vector(31 downto 0);

 -- Clock period definition
constant clk_period : time := 10 ns;

begin
 
-- Instantiate the Device Under Test (DUT)
uut: alu_reg PORT MAP (
        clk       => clk_tb,
        reset     => reset_tb,
        in1       => in1_tb,
        in2       => in2_tb,
        op        => op_tb,
        ena       => ena_tb,
        res       => res_tb
);

 -- Clock process definition
clk_process :process
begin
    clk_tb <= '0';
    wait for clk_period/2;
    clk_tb <= '1';
    wait for clk_period/2;
end process;

stim_proc: process
    begin
    wait for 4*clk_period;
    reset_tb <= '1';
    wait for 4*clk_period;
    reset_tb <= '0';

    -- Simulate a small propagation delay to drive signals a bit after the clock edge
    wait for 0.7*clk_period;
    
    -- Add 2 + 3
    wait for 4*clk_period;
    in1_tb      <= x"00000002";
    in2_tb      <= x"00000003";
    op_tb       <= "00";--add (result should be 5)
    ena_tb      <= '1';
    wait for clk_period;
    ena_tb      <= '0';
  
    -- Subtract 3 from 9
    wait for 4*clk_period;
    in1_tb      <= x"00000009";
    in2_tb      <= x"00000003";
    op_tb       <= "01";--subtract (result should be 6)
    ena_tb      <= '1';
    wait for clk_period;
    ena_tb      <= '0';
    
    -- Try a "random" reset    
    wait for 2*clk_period;
    reset_tb <= '1';
    wait for 2*clk_period;
    reset_tb <= '0';
    
    -- AND the 2 inputs
    wait for 4*clk_period;
    in1_tb      <= x"0000FFFF";
    in2_tb      <= x"000000FF";
    op_tb       <= "10";--AND (result should be x"000000FF")
    ena_tb      <= '1';
    wait for clk_period;
    ena_tb      <= '0';
    
    -- OR the 2 inputs
    wait for 4*clk_period;
    in1_tb      <= x"0000FFFF";
    in2_tb      <= x"FFFF0000";
    op_tb       <= "11";--OR (result should be x"FFFFFFFF")
    ena_tb      <= '1';
    wait for clk_period;
    ena_tb      <= '0';

    wait for 1 ns;
end process;

end behavior;