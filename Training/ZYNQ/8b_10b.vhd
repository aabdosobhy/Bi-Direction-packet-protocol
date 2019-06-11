library ieee;
    use ieee.std_logic_1164.all;

entity enc_8b_10b is

    port (
        clk : in std_logic;
        rst : in std_logic;
        enb : in std_logic;
        data_in : in std_logic_vector(7 downto 0);
        enc_10b : out std_logic_vector(9 downto 0)
    );
    end enc_8b_10b; 
    
architecture rtl of enc_8b_10b is
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

    
    signal data_8b_s : std_logic_vector(7 downto 0);
    signal enc_4b : std_logic_vector(3 downto 0);
    signal enc_6b : std_logic_vector(5 downto 0);
    signal enc_10b_in : std_logic_vector(9 downto 0);
    alias data_5b : std_logic_vector(7 downto 3) is data_in(7 downto 3);
    alias data_3b : std_logic_vector(2 downto 0) is data_in(2 downto 0);
    signal notclk; 
begin
    data_8b: nRegister 
        generic map (
            SIZE => 8)
        port map (
            clk => clk,
            enb => enb,
            rst => rst,
            d => data_in,
            q => data_8b_s
        );

    enc_10b : nRegister 
        generic map (
            SIZE => 10)
        port map (
            clk => clk,
            enb => '1',
            rst => rst,
            d => enc_10b_in,
            q => enc_10b
        );
    
    notclk <= not clk;

    process (clk)
    begin
        if rst ='1' then 
            sh_rg_I <= (others => '1');
        elsif rising_edge(clk) and enb ='1' then 
            case data_3b is
                when "000" => enc_4b <=  ;
                when "001" => enc_4b <=  ;
                when "010" => enc_4b <=  ;
                when "011" => enc_4b <=  ;
                when "100" => enc_4b <=  ;
                when "101" => enc_4b <=  ;
                when "110" => enc_4b <=  ;
                when others => enc_4b <=  ;
            end case;

            case data_5b is
                when "00000" => enc_6b <=  ;
                when "00001" => enc_6b <=  ;
                when "00010" => enc_6b <=  ;
                when "00011" => enc_6b <=  ;
                when "00100" => enc_6b <=  ;
                when "00101" => enc_6b <=  ;
                when "00110" => enc_6b <=  ;
                when "00111" => enc_6b <=  ;
                when "01000" => enc_6b <=  ;
                when "01001" => enc_6b <=  ;
                when "01010" => enc_6b <=  ;
                when "01011" => enc_6b <=  ;
                when "01100" => enc_6b <=  ;
                when "01101" => enc_6b <=  ;
                when "01110" => enc_6b <=  ;
                when "01111" => enc_6b <=  ;
                when "10000" => enc_6b <=  ;
                when "10001" => enc_6b <=  ;
                when "10010" => enc_6b <=  ;
                when "10011" => enc_6b <=  ;
                when "10100" => enc_6b <=  ;
                when "10101" => enc_6b <=  ;
                when "10110" => enc_6b <=  ;
                when "10111" => enc_6b <=  ;
                when "11000" => enc_6b <=  ;
                when "11001" => enc_6b <=  ;
                when "11010" => enc_6b <=  ;
                when "11011" => enc_6b <=  ;
                when "11100" => enc_6b <=  ;
                when "11101" => enc_6b <=  ;
                when "11110" => enc_6b <=  ;
                when others => enc_6b <=  ;
            end case;
        else
                sh_rg_I <= LSin & Sh_rg_O(7 downto 1);
        end if;
    end process;
    
    enc_4b <= 
    
    enc_10b_in <= enc6b & enc_4b;
end rtl;