library ieee;
    use ieee.std_logic_1164.all;

entity train is
    port (
        clk : in std_logic;
        rst : in std_logic;
        lvds_O : out std_logic
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
    
    component sh_rg is
        generic(
            size := integer 8
            );
        port (
            clk : in std_logic;
            rst : in std_logic;
            enb : in std_logic;
            LSin : in std_logic;
            LSout : out std_logic_vector(size -1 downto 0)
        );
    end component;
    
    component enc_8b10b is	
        port(
            RESET : in std_logic ;		-- Global asynchronous reset (active high) 
            SBYTECLK : in std_logic ;	-- Master synchronous send byte clock
            KI : in std_logic ;			-- Control (K) input(active high)
            AI, BI, CI, DI, EI, FI, GI, HI : in std_logic ;	-- Unencoded input data
            JO, HO, GO, FO, IO, EO, DO, CO, BO, AO : out std_logic 	-- Encoded out 
        );
    end component;
    
    component sh_ld_reg is
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
    end component;

    signal enc_8bit : std_logic_vector(7 downto 0);
    signal enc_10bit : std_logic_vector(9 downto 0);
    signal word_8b : std_logic_vector(7 downto 0);
    signal not_clk : std_logic;
    signal count : std_logic_vector(9 downto 0);
    signal loop_cnt : std_logic;
    signal PRNG_O : std_logic;
    Signal en_shift : std_logic;

begin
    
    enc_8b_10b : enc_8b10b
    port map(
    RESET => rst,
    SBYTECLK => clk,
    KI => '0',
    AI => enc_8bit(0),
    BI => enc_8bit(1),
    CI => enc_8bit(2),
    DI => enc_8bit(3),
    EI => enc_8bit(4),
    FI => enc_8bit(5),
    GI => enc_8bit(6),
    HI => enc_8bit(7),
    
    JO => enc_10bit(9), 
    HO => enc_10bit(8), 
    GO => enc_10bit(7), 
    FO => enc_10bit(6), 
    IO => enc_10bit(5), 
    EO => enc_10bit(4), 
    DO => enc_10bit(3), 
    CO => enc_10bit(2), 
    BO => enc_10bit(1), 
    AO => enc_10bit(0)
    );

    count : work.sh_rg(sh_Count) 
        generic map(
            size => 10)
        port map(
            clk => not_clk,
            rst =>  rst,
            enb => '1',
            LSin => loop_cnt,
            LSout => count
        );
    
    word_8b : work.sh_rg(sh_rg_A)
        generic map(
            size => 10
            )
        port map(
            clk => not_clk,
            rst =>  rst,
            enb => en_shift,
            LSin => PRNG_O,
            LSout => enc_8bit
        );
    

    PRNG_R : work.PRNG(PRNG7542)
        port map(
            clk => clk,
            rst => rst,
            enb => en_shift,
            PRNG_O => PRNG_O
        );
    enc_10b_sh : sh_ld_reg 
        generic map(
            SIZE => 11 
            )
        port map(
            clk => clk,
            enb => count(9),
            rst => rst,
            din_ld => enc_10bit
            sh_O => lvds_O
            ); 

    process (clk)
    begin
        
        if rising_edge(clk)  then 
            if enb = '1' and rst = '1' then 
                sh_rg_I <= (others => '0');
            elsif enb = '1' then 
                sh_rg_I <= LSin & Sh_rg_O(7 downto 1);
            end if;
        
        end if;
    end process;
    not_clk <= not clk; 
    en_shift <= not (count(1) or count(0));

    enc_10bit <= enc_10bit(9) & enc_10bit(8) & enc_10bit(7) & enc_10bit(6) & enc_10bit(5) & enc_10bit(4) 
        z& enc_10bit(3) & enc_10bit(2) & enc_10bit(1) & enc_10bit(0);

end rtl;
