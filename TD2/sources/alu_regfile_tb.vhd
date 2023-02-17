library ieee;
use ieee.std_logic_1164.all;

entity alu_regfile_tb is
end alu_regfile_tb;

-- Testbench for alu_regfile
architecture behavior of alu_regfile_tb is
 
-- Component declaration for the DUT
component alu_regfile is
  port(clk      : in  std_logic;
       reset    : in  std_logic;
       op       : in  std_logic_vector(1 downto 0);
       Rreg1    : in  std_logic_vector(2 downto 0);
       Rreg2    : in  std_logic_vector(2 downto 0);
       Wreg     : in  std_logic_vector(2 downto 0);
       ena      : in  std_logic;
       res      : out std_logic_vector(31 downto 0);
       init     : in  std_logic);
end component;

--Inputs
signal clk_tb       : std_logic := '0';
signal reset_tb     : std_logic := '0';
signal op_tb        : std_logic_vector(1 downto 0) := (others => '0');
signal Rreg1_tb     : std_logic_vector(2 downto 0) := (others => '0');
signal Rreg2_tb     : std_logic_vector(2 downto 0) := (others => '0');
signal Wreg_tb      : std_logic_vector(2 downto 0) := (others => '0');
signal ena_tb       : std_logic := '0';
signal res_tb       : std_logic_vector(31 downto 0) := (others => '0');
signal init_tb      : std_logic := '0';

 -- Clock period definition
constant clk_period : time := 10 ns;

begin
 
-- Instantiate the Device Under Test (DUT)
uut: alu_regfile port map (
        clk         => clk_tb,
        reset       => reset_tb,
        op          => op_tb,
        Rreg1       => Rreg1_tb,
        Rreg2       => Rreg2_tb,
        Wreg        => Wreg_tb,
        ena         => ena_tb,
        res         => res_tb,
        init        => init_tb
);
 
 -- Stimulus process
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
    -- Initialize the register file
    -- ONLY FOR SIMULATION PURPOSES
    -- AND ONLY FOR THIS TD
    init_tb <= '1';
    wait for clk_period;
    init_tb <= '0';
    wait for clk_period;

    -- Simulate a small propagation delay to drive signals a bit after the clock edge
    wait for 0.7*clk_period;

    -- r0 = r7 - r6
    Rreg1_tb <= "111";  --r7 = 7
    Rreg2_tb <= "110";  --r6 = 6
    Wreg_tb  <= "000";  --r0 --> 1
    op_tb    <= "01";   --subtract
    ena_tb   <= '1';
    wait for clk_period;
    ena_tb   <= '0';
    wait for 4*clk_period;
    
    -- r4 = r4 + r5
    Rreg1_tb <= "100"; --r4 = 4
    Rreg2_tb <= "101"; --r5 = 5
    Wreg_tb  <= "100"; --r4 --> 9
    op_tb   <= "00";   --add
    ena_tb   <= '1';
    wait for clk_period;
    ena_tb   <= '0';
    wait for 4*clk_period;

    -- Try a "random" reset    
    reset_tb <= '1';
    wait for 4*clk_period;
    reset_tb <= '0';
    wait for 4*clk_period;
    
    wait for 2 ns;
end process;
 
end behavior;