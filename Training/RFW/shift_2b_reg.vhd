----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    26/7/2019 
-- Design Name:    shift Register by 2 bits 
-- Module Name:    sh_2b_rg  
-- Target Devices: LCMXO2-1200HC
-- Package name:   TQFP100
-- grade: 		   4
-- Tool versions:  Lattice Diamond
-- Description:    shift register at the rising edge by 2 bits to act as ddr.
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

entity sh_2b_rg is
    generic(
        SIZE : integer := 8;
        SHIFT_BS : integer := 2
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
                sh_rg <= "01110000";   
        elsif rising_edge(clk) and enb = '1' then 
                sh_rg <= LSin & Sh_rg(SIZE -1 downto SHIFT_BS );
            end if;

    end process;
    LSout <= Sh_rg;
end rtl;
