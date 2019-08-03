library ieee;
use ieee.std_logic_1164.all;

entity sh_2b_rg is
    generic(
        SIZE : integer := 8;
        SHIFT_BS : integer := 2;
        RST_VALUE : std_logic_vector := "11110000"
        );
    port (
        clk : in std_logic;
        rst : in std_logic;
        enb : in std_logic;
        LSin : in std_logic_vector(SHIFT_BS -1 downto 0);
        LSout : out std_logic_vector(SIZE -1 downto 0)
    );
    end sh_2b_rg; 
    
architecture rtl of sh_2b_rg is

    signal sh_rg : std_logic_vector(SIZE -1 downto 0);
begin

    process (clk, rst)
    begin    
	    if rst = '1' then 
                sh_rg <= RST_VALUE;   
        elsif falling_edge(clk) and enb = '1' then 
                sh_rg <= LSin & Sh_rg(SIZE -1 downto SHIFT_BS );
        end if;

    end process;
    LSout <= Sh_rg;
end rtl;
