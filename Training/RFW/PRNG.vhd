    library ieee;
    use ieee.std_logic_1164.all;

entity PRNG is
    port (
        clk : in std_logic;
        rst : in std_logic;
        enb : in std_logic;
        PRNG_O : out std_logic
    );
    end PRNG; 
    
architecture PRNG7542 of PRNG is

    component lfsr is
            generic(
                size : integer := 8
                );
            port (
                clk : in std_logic;
                rst : in std_logic;
                enb : in std_logic;
                LSin : in std_logic;
                LSout : out std_logic_vector(size -1 downto 0)
            );         
    end component;

    signal lfsr_I : std_logic;
    signal lfsr_O : std_logic_vector(7 downto 0);
    signal feed_1 : std_logic;
    signal feed_2 : std_logic;
    signal feed_3 : std_logic;
    
begin
    lfsr_reg : lfsr 
        generic map (
            SIZE => 8)
        port map (
            clk => clk,
            enb => enb,
            rst => rst,
            LSin => lfsr_I,
            LSout => lfsr_O
        );
    
    feed_1 <= lfsr_O(0) xnor lfsr_O(2);
    feed_2 <= feed_1 xnor lfsr_O(3);
    feed_3 <= feed_2 xnor lfsr_O(5);
    lfsr_I <= feed_3;
end PRNG7542;