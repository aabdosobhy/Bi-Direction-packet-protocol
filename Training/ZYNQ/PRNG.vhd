----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    28/6/2019 
-- Design Name:    PRNG 
-- Module Name:    PRNG  
-- Target Devices: Zynq-7000  xc7z020clg400-1
-- Tool versions:  xilinx vivado
-- Description:    PRNG(Pseudo Random Number Generation) that generate every 8 bit 
--                 a new word using Fibonacci LFSR of polynomial 5320
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

entity PRNG is
    Generic (
        SEED : std_logic_vector := "11100111"
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        enb : in std_logic;
        PRNG_O : out std_logic
    );
    end PRNG; 
    
architecture PRNG7542 of PRNG is

	signal feed1, feed2, feed : std_logic;
    signal lfsr : std_logic_vector(7 downto 0) := SEED;
    
begin
    
    process(clk, rst)
    begin
        if rst = '1' then
            lfsr <= SEED;
        elsif rst = '0' and rising_edge(clk) and enb = '1' then
            lfsr <= feed & lfsr(7 downto 1);
        end if;
    end process;
	feed1 <= lfsr(0) xor lfsr(2);
	feed2 <= feed1 xor lfsr(3);
    feed <= feed2 xor lfsr(5);
    PRNG_O <= lfsr(0);

end PRNG7542;