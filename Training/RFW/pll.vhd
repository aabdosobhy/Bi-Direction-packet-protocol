library ieee;
use ieee.std_logic_1164.all;

entity pll is
	port(
		ref_clk_in : in std_logic;		-- input clock to FPGA
		--
		pll_locked : out std_logic;		-- PLL locked
		--
		lvds_clk : out std_logic;		-- regenerated clock
		word_clk : out std_logic		-- word clock
	); 
end pll;

architecture rtl of pll is



end rtl;