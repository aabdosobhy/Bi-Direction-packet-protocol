library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity count_diff is
    port ( 
	A : in std_logic_vector (7 downto 0);
	B : in std_logic_vector (7 downto 0);
    difference : out  std_logic_vector (3 downto 0));
end count_diff;

architecture rtl of count_diff is
begin
    count_ones : process(A, B)
    variable count : unsigned(3 downto 0) := (others => '0');
    begin
        count := "0000";
        for i in 0 to 7 loop
            count := count + ("000" & (B(i) xor A(i)));
        end loop;
        difference <= std_logic_vector(count);
    end process;
end rtl;