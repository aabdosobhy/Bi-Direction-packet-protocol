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
        SEED : std_logic_vector := "11011110"
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        enb : in std_logic;
        PRNG_O : out std_logic_vector(1 downto 0)
    );
    end PRNG; 
    
architecture PRNG7542 of PRNG is

    signal feed1_1, feed1_2, feed1 : std_logic;
    signal feed2_1, feed2_2, feed2 : std_logic;
    signal lfsr : std_logic_vector(7 downto 0) := SEED;
    
begin
    
    process(clk, rst)
    begin
        if rst = '1' then
            lfsr <= SEED;
        elsif rst = '0' and rising_edge(clk) and enb = '1' then
            lfsr <= feed2 & feed1 & lfsr(7 downto 2);
        end if;
    end process;
	feed1_1 <= lfsr(0) xor lfsr(2);
	feed1_2 <= feed1_1 xor lfsr(3);
    feed1 <= feed1_2 xor lfsr(5);

    feed2_1 <= lfsr(1) xor lfsr(3);
	feed2_2 <= feed2_1 xor lfsr(4);
    feed2 <= feed2_2 xor lfsr(6);


    PRNG_O <= lfsr(1 downto 0);

end PRNG7542;


