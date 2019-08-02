----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    28/6/2019 
-- Design Name:    top 
-- Module Name:    top  
-- Target Devices: Zynq-7000  xc7z020clg400-1
-- Tool versions:  xilinx vivado
-- Description:    top module that generates bits using PRNG with a ploynomial 
--                 of 5320 with the using of and LFSR and the output is serialaized  
--                 using serializer module.
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

entity top is
    port (
        clk : in std_logic;
        rst : in std_logic;
        lvds_p : out std_logic;
        lvds_n : out std_logic
        );
    end top; 
    
architecture rtl of top is    

    component train is
        Generic(
            SEED : std_logic_vector(7 downto 0) := "11100111"
            );
        port (
            clk : in std_logic;
            rst : in std_logic;
            lvds_p : out std_logic;
            lvds_n : out std_logic
            );
        end component; 
begin

    train_inst : train 
        generic map (
            SEED => "11100111"
            )
        port map(
            clk => clk,
            rst => rst,                   
            lvds_p => lvds_p,
            lvds_n => lvds_n
        );

end rtl;