library ieee;
    use ieee.std_logic_1164.all;

entity lfsr is
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
    end lfsr; 
    
architecture rtl of lfsr is
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

    signal lfsr_I : std_logic;
    signal lfsr_O : std_logic_vector(7 downto 0);
    signal 
begin
    lfsr_reg : nRegister 
        generic map (
            SIZE => size -1)
        port map (
            clk => clk,
            enb => '1',
            rst => rst,
            d => lfsr_I,
            q => lfsr_O
        );
    
    process (clk)
    begin
        
        if rising_edge(clk)  then 
            if enb = '1' and rst = '1' then 
                lfsr_I <= "01001110";       -- Seed no.
            elsif enb = '1' then 
                lfsr_I <= LSin & lfsr_O(7 downto 1);
            end if;
        
        end if;
    end process;
    LSout <= lfsr_O;
end rtl;