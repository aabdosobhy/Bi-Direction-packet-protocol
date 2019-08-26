----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    28/6/2019 
-- Design Name:    register 
-- Module Name:    nRegister   
-- Description:    generic Register 
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

entity nRegister is
	generic(
		SIZE : integer := 8
		);
	port(
		clk : in std_logic;		-- clock
		enb : in std_logic;		-- enable write
		rst : in std_logic;		-- reset
		d : in std_logic_vector(SIZE -1 downto 0);	-- data to register
		q : out std_logic_vector(SIZE -1 downto 0)	-- o/p data register
		); 
end nRegister;

architecture rtl of nRegister is

begin
	process (clk, rst)
	begin
		if rst = '1' then
			q <= (others => '0');

		elsif rising_edge(clk) and enb = '1'  then
			q <= d;
			
		end if;
	end process;

end rtl;