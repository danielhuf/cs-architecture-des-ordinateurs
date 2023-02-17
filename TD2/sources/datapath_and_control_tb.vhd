library ieee;
use ieee.std_logic_1164.all;

entity datapath_and_control_tb is
end datapath_and_control_tb;

-- Testbench for datapath_and_control_tb
architecture behavior of datapath_and_control_tb is

-- Component declaration for the DUT
component datapath_and_control is
    port(clk      : in  std_logic;
         reset    : in  std_logic;
         inst     : in  std_logic_vector(31 downto 0); 
         inst_we  : in  std_logic;
         init     : in  std_logic);
end component;
 
-- Test signals
signal clk_tb       : std_logic := '0';
signal reset_tb     : std_logic := '0';
signal inst_tb      : std_logic_vector(31 downto 0) := (others => '0');
signal inst_we_tb   : std_logic := '0';
signal init_tb      : std_logic := '0';

-- Auxiliary signals to build the instruction
signal funct7_tb   : std_logic_vector(6 downto 0);
signal funct3_tb   : std_logic_vector(2 downto 0);
signal rs1_tb      : std_logic_vector(4 downto 0);
signal rs2_tb      : std_logic_vector(4 downto 0);
signal rd_tb       : std_logic_vector(4 downto 0);
signal opcode_tb   : std_logic_vector(6 downto 0);


 -- Clock period definition
constant clk_period : time := 10 ns;


begin

-- Instantiate the Device Under Test (DUT)
uut: datapath_and_control port map (
        clk     => clk_tb,
        reset   => reset_tb,
        inst    => inst_tb,
        inst_we => inst_we_tb,
        init    => init_tb
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
    
    -- Initial reset
    reset_tb <= '1';
    wait for 4*clk_period;
    reset_tb <= '0';
    wait for 4*clk_period;
    
    
    wait for 4*clk_period;
    -- Initialize the register file
    -- ONLY FOR SIMULATION PURPOSES
    -- AND ONLY IN THIS TD
    init_tb <= '1';
    wait for clk_period;
    init_tb <= '0';
    wait for clk_period;

    -- Simulate a small propagation delay to drive signals a bit after the clock edge
    wait for 0.7*clk_period;

    -- r0 = r7 - r6
    -- Prepare instruction encoding
    opcode_tb   <= "0110011";
    funct7_tb   <= "0100000"; -- sub
    funct3_tb   <= "000";
    rs1_tb      <= "00111";  --r7 = 7
    rs2_tb      <= "00110";  --r6 = 6
    rd_tb       <= "00000";  --r0 --> 1
    inst_tb     <= "0100000" & "00110" & "00111" & "000" & "00000" & "0110011";
    --             funct7_tb &  rs2_tb &  rs1_tb & funct3_tb & rd_tb & opcode_tb;
    -- Activate enable
    inst_we_tb  <= '1';
    wait for clk_period;
    inst_we_tb  <= '0';
    wait for 4*clk_period;
    
    -- r4 = r4 + r5
    -- Prepare instruction encoding
    opcode_tb   <= "0110011";
    funct7_tb   <= "0000000"; -- add
    funct3_tb   <= "000";
    rs1_tb      <= "00100";  --r4 = 4
    rs2_tb      <= "00101";  --r5 = 5
    rd_tb       <= "00100";  --r4 --> 9
    inst_tb     <= "0000000" & "00101" & "00100" & "000" & "00100" & "0110011";
    --             funct7_tb &  rs2_tb &  rs1_tb & funct3_tb & rd_tb & opcode_tb;
    -- Activate enable
    inst_we_tb  <= '1';
    wait for clk_period;
    inst_we_tb  <= '0';
    wait for 4*clk_period;

    -- Try a "random" reset    
    reset_tb <= '1';
    wait for 4*clk_period;
    reset_tb <= '0';
    wait for 4*clk_period;
    
    wait;
end process;

end behavior;

