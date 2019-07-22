library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

LIBRARY machxo2;
USE machxo2.all;

entity test_CLKDIVC is
    port (
        e_clk : in std_logic;
        s_clk : out std_logic;
        rst    : in std_logic;
        word_align : in std_logic
    );
end test_CLKDIVC;

architecture rtl of test_CLKDIVC is 

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

    signal cDiv1_open : std_logic;
begin 

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

end rtl;
