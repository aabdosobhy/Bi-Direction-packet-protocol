library ieee;
use ieee.std_logic_1164.all;

entity PRNG is
    Generic (
        SEED : std_logic_vector := "01001110"
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        enb : in std_logic;
        PRNG_O : out std_logic
    );
    end PRNG; 
    
architecture PRNG7542 of PRNG is

	signal feed : std_logic;
    signal lfsr : std_logic_vector(7 downto 0) := SEED;
    
begin
    
    process(clk, rst)
    begin
        if rst = '1' then
            lfsr <= SEED;
        elsif rst = '0' and rising_edge(clk) then
            lfsr <= feed & lfsr(7 downto 1);
        end if;
    end process;

    feed <= lfsr(0) xnor lfsr(2) xnor lfsr(3) xnor lfsr(5);
    PRNG_O <= lfsr(0);

end PRNG7542;