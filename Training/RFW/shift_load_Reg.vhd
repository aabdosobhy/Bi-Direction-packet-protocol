----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    26/7/2019 
-- Design Name:    shift register 1 bit with load new value.
-- Module Name:    sh_ld_rg.
-- Target Devices: LCMXO2-1200HC
-- Package name:   TQFP100
-- grade: 		   4
-- Tool versions:  Lattice Diamond
-- Description:    Shift register left one bit and load the register with 
--                 new value if the enable = 0

--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 

----------------------------------------------------------------------------------
-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation, either version
-- 3 of the License, or (at your option) any later version.
----------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;

entity sh_ld_rg is
    generic(
        SIZE : integer := 8
        );
    port (
        clk : in std_logic;
        rst : in std_logic;
        enb : in std_logic;
        load : in std_logic_vector(SIZE -1 downto 0);
        LSout : out std_logic
    );
    end sh_ld_rg; 


architecture rtl of sh_ld_rg is

    signal sh_rg : std_logic_vector(SIZE -1 downto 0);
    signal Sh_rg_O : std_logic_vector(SIZE -1 downto 0);

begin

    process (clk, rst)
    begin
        
	if rst ='1' then 
		sh_rg <= (others => '0');
    elsif rising_edge(clk) then 
        if enb = '1' then 
            sh_rg <= Sh_rg_O(0) & Sh_rg_O(SIZE -1 downto 1);
        else 
            sh_rg <= load;
        end if;
    end if;
        
    end process;
    Sh_rg_O <= sh_rg;
    LSout <= Sh_rg(0);
end rtl;