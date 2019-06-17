library ieee;
use ieee.std_logic_1164.all;

entity train is
	generic(
		SIZE : integer := 10
	);
	port(
		clk : in std_logic;		-- clock
		rst : in std_logic;		-- reset
		dec_ld : in std_logic_vector(SIZE -1 downto 0);	-- data to register
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
	
	component  dec_8b10b is	
    port(
		RESET : in std_logic ;	-- Global asynchronous reset (AH) 
		RBYTECLK : in std_logic ;	-- Master synchronous receive byte clock
		AI, BI, CI, DI, EI, II : in std_logic ;
		FI, GI, HI, JI : in std_logic ; -- Encoded input (LS..MS)		
		KO : out std_logic ;	-- Control (K) character indicator (AH)
		HO, GO, FO, EO, DO, CO, BO, AO : out std_logic 	-- Decoded out (MS..LS)
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

	signal clk_gen : std_logic;
	signal not_clk_gen : std_logic;
	signal enc_10B : std_logic_vector(9 downto 0);
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

	Decoder : dec_8b10b 
		port map (
			RESET => rst_sys,
			RBYTECLK => clk_gen,
			AI => enc_10b(0), 
			BI => enc_10b(1), 
			CI => enc_10b(2), 
			DI => enc_10b(3), 
			EI => enc_10b(4), 
			II => enc_10b(5),
			FI => enc_10b(6), 
			GI => enc_10b(7), 
			HI => enc_10b(8), 
			JI => enc_10b(9),	
			KO => '0',
			HO => dec_8b(7), 
			GO => dec_8b(6), 
			FO => dec_8b(5), 
			EO => dec_8b(4), 
			DO => dec_8b(3), 
			CO => dec_8b(2), 
			BO => dec_8b(1), 
			AO => dec_8b(0) 
		);
	
	PRNG_r : PRNG 
	port map (
		clk => clk_gen,
		rst => rst_sys,
		enb => en_PRNG,
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
	rst_sys <= rst or dec_8b(7) or dec_8b(6) or dec_8b(5) or dec_8b(4)
		or dec_8b(3) or dec_8b(2) or dec_8b(1) or dec_8b(0);
   	loop_cnt <= count(0);
end rtl;