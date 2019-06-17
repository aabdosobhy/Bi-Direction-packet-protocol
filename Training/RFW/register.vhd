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