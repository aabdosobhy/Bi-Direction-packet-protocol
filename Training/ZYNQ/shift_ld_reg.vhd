library ieee;
use ieee.std_logic_1164.all;

entity sh_ld_reg is
	generic(
		SIZE : integer := 8
	);
	port(
		clk : in std_logic;		-- clock
		enb : in std_logic;		-- enable write
		rst : in std_logic;		-- reset
		din_ld : in std_logic_vector(SIZE -2 downto 0);	-- data to register
		sh_O : out std_logic
		); 
end sh_ld_reg;

architecture rtl of nRegister is
	component nRegister is
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
    end component;

	signal sh_out : std_logic;
	signal ld_word : std_logic_vector(SIZE -1 downto 0);
	signal sh_word : std_logic_vector(SIZE -1 downto 0);
    --signal Sh_rg_O : std_logic_vector(7 downto 0);
begin
	reg : nRegister 
        generic map (
            SIZE => SIZE -1)
        port map (
            clk => clk,
            enb => '1',
            rst => rst,
            d => ld_word,
            q => sh_word
        );
	process (clk, rst)
	begin
		if rst = '1' then
			ld_word <= (others => '0');
		elsif rising_edge(clk) and enb = '1'  then
			ld_word <= din_ld & sh_word(1);
		elsif rising_edge(clk) and enb = '0'  then
			ld_word <= 0 & sh_word(SIZE -1 downto 1);
		end if;
	end process;
	sh_O <= sh_word(0);
end rtl;