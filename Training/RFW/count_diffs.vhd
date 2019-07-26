----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    26/7/2019 
-- Design Name:    Count Difference 
-- Module Name:    count_diff  
-- Target Devices: LCMXO2-1200HC
-- Package name:   TQFP100
-- Tool versions:  Lattice Diamond
-- Description:    Cout the difference bits between the two input vectors A & B
--                 and accumlate that result to count_diff 
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
use ieee.numeric_std.all;

entity count_diff is
    generic (
        CMP_SIZE : integer  := 8;
		OUT_SIZE : integer  := 32
        );
    port ( 
        clk : in std_logic;
        rst : in std_logic;
        enb : in std_logic;
        A : in std_logic_vector (CMP_SIZE -1 downto 0);
        B : in std_logic_vector (CMP_SIZE -1 downto 0);
        count_diff : out std_logic_vector (OUT_SIZE -1 downto 0)
        );
end count_diff;

architecture rtl of count_diff is

    signal count_diff_sig : std_logic_vector (OUT_SIZE -1 downto 0) := (others => '0');
    signal count_temp : std_logic_vector (OUT_SIZE -1 downto 0);
    signal difference : std_logic_vector (OUT_SIZE -1 downto 0) := (others => '0');
begin

    count_ones : process(clk, rst)
        variable count : unsigned(3 downto 0) := (others => '0');        

    begin
        if rst = '0' then             
            if enb ='1' then 
                if rising_edge(clk) then             
                    count_diff_sig <= count_temp;

                elsif falling_edge(clk) then 
                    count := "0000";
                    for i in 0 to 7 loop
                        count := count + ("000" & (B(i) xor A(i)));
                    end loop;
                    difference <= (OUT_SIZE -1 downto 4 => '0') & std_logic_vector(count);
                end if;
            end if;
        else 
            count_diff_sig <= (others => '0');
            difference <= (others => '0');
        end if;
    end process;


    count_temp <= std_logic_vector(unsigned(count_diff_sig) + unsigned(difference));
    count_diff <= count_diff_sig;

end rtl;