library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY machxo2;
use machxo2.all;


entity train is
	Generic(
        SEED : std_logic_vector(7 downto 0) := "11100111"
    );
	port(
		clk : std_logic;
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
			e_clk : in std_logic;
			s_clk : in std_logic;
			sdataIn  : in std_logic;
			rst    : in std_logic;
			Dec_Data_O : out std_logic_vector (7 downto 0);
			word_align : out std_logic;
			v_rst : out std_logic;

			pdata2mux_s : out std_logic_vector(7 downto 0);
			state_s : out std_logic_vector(2 downto 0);
        	decoderIn_s : out std_logic_vector(9 downto 0);
        	decoderOut_s : out std_logic_vector(7 downto 0);
        	reg4W_10b_s : out std_logic_vector(39 downto 0);
			en_PRNG : out std_logic
			);
	end component;

	component ECLKSYNCA
		port (
			ECLKI : in std_logic;
			STOP  : in std_logic;
			ECLKO : out std_logic);
	end component;

	component CLKDIVC
		generic (
			DIV : string;
			GSR : string
			);
		port (
			RST: in  std_logic;
			CLKI: in  std_logic;
			ALIGNWD: in  std_logic;
			CDIV1: out std_logic;
			CDIVX : out std_logic
			);
	end component;

	-- component delay 
	-- 	port (
	-- 		A : in std_logic;
	-- 		Z : out std_logic
	-- 	);

	component PRNG is
		Generic (
       		SEED : std_logic_vector := "11100111"
    	);
		port (
			clk : in std_logic;
			rst : in std_logic;
			enb : in std_logic;
			PRNG_O : out std_logic_vector (1 downto 0)
		);
	end component;

	component count_diff is
		port ( 
		A : in std_logic_vector (7 downto 0);
		B : in std_logic_vector (7 downto 0);
		difference : out  std_logic_vector (3 downto 0));
	end component;

	component sh_2b_rg is
		generic(
			SIZE : integer := 8;
			SHIFT_BS : integer := 2
			);
		port (
			clk : in std_logic;
			rst : in std_logic;
			enb : in std_logic;
			LSin : in std_logic_vector(SHIFT_BS -1 downto 0);
			LSout : out std_logic_vector(SIZE -1 downto 0)
		);
	end component; 
	
	signal e_clk  : std_logic;
	signal s_clk : std_logic;
	signal cDiv1_open : std_logic;
	signal word_align : std_logic;
	signal not_clk : std_logic;
	signal dec_8b : std_logic_vector(7 downto 0);
	signal rst_sys , v_rst : std_logic;
	
	signal pdata2mux : std_logic_vector(7 downto 0);
	signal state : std_logic_vector(2 downto 0);
	signal decoderIn : std_logic_vector(9 downto 0);
    signal decoderOut : std_logic_vector(7 downto 0);
	signal reg4W_10b : std_logic_vector(39 downto 0);
	
	signal en_PRNG : std_logic;
	signal PRNG_O : std_logic_vector(1 downto 0);
	signal PRNG_8b : std_logic_vector(11 downto 0);
	-- signal loop_cnt : std_logic;
	-- signal count : std_logic_vector(3 downto 0);
	signal error_cnt : std_logic_vector(3 downto 0);
	signal BE_I : std_logic_vector(31 downto 0) := (others => '0');
	signal BE_O : std_logic_vector(31 downto 0);
begin

	clk_SYNC_INST: ECLKSYNCA
		port map(
			ECLKI => clk,
			STOP  => '0',
			ECLKO => e_clk
			);
 
	clkdiv_inst : CLKDIVC
        generic map (
            DIV => "4.0",
            GSR => "ENABLED"
        	)
        port map (
            RST     => rst,
            ALIGNWD => word_align,
            CLKI    => e_clk,
            CDIV1   => cDiv1_open,
            CDIVX   => s_clk
			);
			   
	deserilaizer_inst : deserializer 
		port map (
			e_clk => e_clk,
			s_clk => s_clk,			
			sdataIn => datain,
			rst => rst,
			Dec_Data_O => dec_8b,
			word_align => word_align,
			v_rst => v_rst,

			pdata2mux_s => pdata2mux,
			state_s => state,
			decoderIn_s => decoderIn,
			decoderOut_s => decoderOut,
			reg4W_10b_s => reg4W_10b,
			
			en_PRNG => en_PRNG
			);

	PRNG_Reg : PRNG
        generic map (
            SEED => SEED
            )
        port map(
            clk => e_clk,
            rst => rst_sys,
            enb => en_PRNG,
            PRNG_O => PRNG_O
        );

	-- count_r : entity work.sh_rg(sh_Count) 
    --     generic map(
    --         size => 4)
    --     port map(
    --         clk => not_clk,
    --         rst =>  rst_sys,
    --         enb => '1',
    --         LSin => loop_cnt,
    --         LSout => count
    --     );

	word_8b_r : sh_2b_rg 
		generic map(
			SIZE => 12,
			SHIFT_BS => 2
			)
		port map(
			clk => not_clk,
            rst =>  rst_sys,
            enb => en_PRNG,
            LSin => PRNG_O,
            LSout => PRNG_8b
		);
	
	count_error : count_diff 
		port map( 
			A => PRNG_8b(7 downto 0),
			B => dec_8b, 
			difference => error_cnt
			);
		
	BE_counter : nRegister 
		generic map (
			SIZE => 32)
		port map (
			clk => e_clk,
			enb => '1',
			rst => rst_sys,
			d => BE_I,
			q => BE_O
		); 

	process (s_clk)
	begin
		if falling_edge(s_clk) and en_PRNG = '1' then 
	
			BE_I <= std_logic_vector(unsigned( BE_O ) + unsigned( error_cnt ));
		end if;
	end process;


	not_clk <= not e_clk;
	rst_sys <= rst or v_rst;
   	-- loop_cnt <= count(0);
	BE_cnt <= BE_O;
end rtl;