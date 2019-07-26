----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    28/6/2019 
-- Design Name:    shift register
-- Module Name:    shift register  
-- Target Devices: Zynq-7000  xc7z020clg400-1
-- Tool versions:  xilinx vivado
-- Description:    Shift register that shifts a bit every clock cycle
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation, either version
-- 3 of the License, or (at your option) any later version.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity sh_rg is
    generic(
        SIZE : integer := 8
        );
    port (
        clk : in std_logic;
        rst : in std_logic;
        enb : in std_logic;
        LSin : in std_logic;
        LSout : out std_logic_vector(SIZE -1 downto 0)
    );
    end sh_rg; 
    
architecture sh_rg_A of sh_rg is

    signal sh_rg : std_logic_vector(SIZE -1 downto 0);
begin

    process (clk)
    begin       
        if rising_edge(clk)  then 
            if rst = '1' then 
                sh_rg <= (others => '0');
            elsif enb = '1' then 
                sh_rg <= LSin & Sh_rg(SIZE -1 downto 1);
            end if;
        
        end if;
    end process;
    LSout <= Sh_rg;
end sh_rg_A;

architecture sh_Count of sh_rg is
    
    signal sh_rg_C : std_logic_vector(SIZE -1 downto 0);

begin
    
    process (clk)
    begin
        
        if rising_edge(clk)  then 
            if rst = '1' then 
                sh_rg_C <= (SIZE -1 => '1' , others => '0');
            elsif enb = '1' then 
                sh_rg_C <= LSin & sh_rg_C(SIZE -1 downto 1);
            end if;
        
        end if;
    end process;
    LSout <= sh_rg_C;
end sh_Count;