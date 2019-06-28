library ieee;
use ieee.std_logic_1164.all;

entity train is
	Generic(
        SEED : std_logic_vector(7 downto 0) := "11100111"
    );
	port(
		datain : in std_logic;		-- clock
		rst : in std_logic;
		BE_cnt : out std_logic_vector(31 downto 0)
		); 
end train;

architecture rtl of train is
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
	
	component deserializer is
		port (
			sdataIn  : in std_logic;
			rst : in std_logic;
			clk_gen : out std_logic;
			clk_x8 : out std_logic;
			Dec_Data_O : out std_logic_vector (7 downto 0);
			freez : out std_logic
		);
	end component;

	component PRNG is
		port (
			clk : in std_logic;
			rst : in std_logic;
			enb : in std_logic;
			PRNG_O : out std_logic
		);
	end component;

	component count_diff is
		port ( 
		A : in std_logic_vector (7 downto 0);
		B : in std_logic_vector (7 downto 0);
		difference : out  std_logic_vector (3 downto 0));
	end component;

	signal clk_gen : std_logic;
	signal word_clk : std_logic;
	signal not_clk_gen : std_logic;
	signal freez_cycle : std_logic;
	signal dec_8b : std_logic_vector(7 downto 0);
	signal rst_sys : std_logic;
	signal en_PRNG : std_logic;
	signal PRNG_O : std_logic;
	signal en_shift : std_logic;
	signal PRNG_8b : std_logic_vector(7 downto 0);
	signal loop_cnt : std_logic;
	signal count : std_logic_vector(9 downto 0);
	signal BE_I, BE_O : std_logic_vector(31 downto 0);

begin

	deserilaizer_inst : deserializer is
		port map (
			sdataIn => datain,
			rst => '0',
			clk_gen => clk_gen,
			clk_x8 => word_clk,
			Dec_Data_O => dec_8b,
			freez => freez_cycle
		);

	PRNG_Reg : PRNG
        generic map (
            SEED => SEED
            )
        port map(
            clk => clk_gen,
            rst => rst_save,
            enb => en_shift,
            PRNG_O => PRNG_O
        );


	count_r : entity work.sh_rg(sh_Count) 
        generic map(
            size => 10)
        port map(
            clk => not_clk_gen,
            rst =>  rst_sys,
            enb => '1',
            LSin => loop_cnt,
            LSout => count
        );

	word_8b_r : entity work.sh_rg(sh_rg_A)
        generic map(
            size => 8 -- check
            )
        port map(
            clk => not_clk_gen,
            rst =>  rst_sys,
            enb => en_shift,
            LSin => PRNG_O,
            LSout => PRNG_8b
		);
	
	BE_counter : nRegister 
	generic map (
		SIZE => size -1)
	port map (
		clk => clk_gen,
		enb => '1',
		rst => rst_sys,
		d => BE_I,
		q => BE_O
	); 

	
	process (clk_gen)
	begin
		if rising_edge(clk_gen) and en_shift =='1' then 
			-- cmp 2 signals (PRNG_sh xnor serdes_sh)
			BE_I <= std_logic_vector(to_unsigned(to_integer(unsigned( BE_O )) + 1, 32));
		end if;
	end process;

	process(clk)
    begin 
        if rising_edge(clk) then 
            if rst = '1' then 
                rst_save <= '1';
            else rst_save <= '0';
            end if;
        end if;
    end process;

	
	rst_sys <= rst or dec_8b(7) or dec_8b(6) or dec_8b(5) or dec_8b(4)
		or dec_8b(3) or dec_8b(2) or dec_8b(1) or dec_8b(0);
   	loop_cnt <= count(0);

end rtl;