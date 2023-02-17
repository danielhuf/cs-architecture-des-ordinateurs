library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CND is
    generic (
        mutant      : integer := 0
    );
    port (
        ina         : in w32; --rs1
        inb         : in w32; --ALU_Y
        f           : in  std_logic; --IR14
        r           : in  std_logic; --IR13
        e           : in  std_logic; --IR12
        d           : in  std_logic; --IR6
        s           : out std_logic; --SLT
        j           : out std_logic --status.JCOND
    );
end CPU_CND;

architecture RTL of CPU_CND is

    signal ext_signe : std_logic;
    signal z_alu     : std_logic;
    signal s_alu     : std_logic;
    
    begin 
    process(all)
    variable aux: unsigned(32 downto 0);
    begin
    
        ext_signe <= ((not e) and (not d)) or (d and (not r));
        if (ext_signe='1')  then
            if (signed(ina) < signed(inb)) then
                s_alu <= '1';
                z_alu <= '0';
            elsif (signed(ina) = signed(inb))  then
                s_alu <= '0';
                z_alu <= '1';      	
            else          	
                s_alu <= '0';
                z_alu <= '0';
            end if;

        else
            if (unsigned(ina) < unsigned(inb)) then
                s_alu <= '1';
                z_alu <= '0';
            elsif (unsigned(ina) = unsigned(inb)) then
                s_alu <= '0';
                z_alu <= '1';      	
            else          	
                s_alu <= '0';
                z_alu <= '0';
            end if;    
                                 
        end if;
        s <= s_alu;
	j <= ((not f) and (z_alu xor e)) or (f and (s_alu xor e));
    end process;

end RTL;

