library ieee;
    use ieee.std_logic_1164.all;

entity sh_rg is
    generic(
        SIZE : integer := 8
        );
    port (
        clk : in std_logic;
        rst : in std_logic;
        enb : in std_logic;
        LSin : in std_logic;
        LSout : out std_logic_vector(SIZE -1 downto 0)
    );
    end sh_rg; 
    
architecture sh_rg_A of sh_rg is
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

    signal sh_rg_I : std_logic_vector(SIZE -1 downto 0);
    signal Sh_rg_O : std_logic_vector(SIZE -1 downto 0);

begin
    shift_reg : nRegister 
        generic map(
            SIZE => SIZE)
        port map(
            clk => clk,
            enb => '1',
            rst => rst,
            d => sh_rg_I,
            q => Sh_rg_O
        );
    
    process (clk)
    begin       
        if rising_edge(clk)  then 
            if rst = '1' then 
                sh_rg_I <= (others => '0');
            elsif enb = '1' then 
                sh_rg_I <= LSin & Sh_rg_O(7 downto 1);
            end if;
        
        end if;
    end process;
    LSout <= Sh_rg_O;
end sh_rg_A;

architecture sh_Count of sh_rg is
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

    signal sh_rg_I : std_logic_vector(SIZE -1 downto 0);
    signal Sh_rg_O : std_logic_vector(SIZE -1 downto 0);

begin
    shift_reg : nRegister 
        generic map(
            SIZE => SIZE)
        port map(
            clk => clk,
            enb => '1',
            rst => rst,
            d => sh_rg_I,
            q => Sh_rg_O
        );
    
    process (clk)
    begin
        
        if rising_edge(clk)  then 
            if rst = '1' then 
                sh_rg_I <= (SIZE -1 => '1' , others => '0');
            elsif enb = '1' then 
                sh_rg_I <= LSin & Sh_rg_O(7 downto 1);
            end if;
        
        end if;
    end process;
    LSout <= Sh_rg_O;
end sh_Count;