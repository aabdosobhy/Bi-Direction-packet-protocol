library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

LIBRARY machxo2;
USE machxo2.all;

entity deserializer is
    port (
        sdataIn  : in std_logic;
        rst    : in std_logic;
		clkout   : out std_logic;
        Dec_Data_O : out std_logic_vector (7 downto 0);
        freez : out std_logic
    );
end deserializer;

architecture rtl of deserializer is 
    
    component pll is
        port (
            CLKI: in  std_logic; 
            CLKOP: out  std_logic);
    end component;

    component IDDRX4B
        generic (
            GSR : string
        );
        port (
            D, ECLK, SCLK, RST, ALIGNWD : in std_logic;
            Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7 : out std_logic
        );
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
            CDIVX : out std_logic);
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

    signal clk_rec : std_logic;
    signal clk : std_logic;
    signal cDiv1_open : std_logic;
	signal pdata2mux : std_logic_vector(7 downto 0);
	signal decoderIn : std_logic_vector(9 downto 0) := (others => '0');
    signal decoderOut : std_logic_vector(7 downto 0) := (others => '0');
	signal reg4W_10W : std_logic_vector(39 downto 0) := (others => '0');
	signal tempreg : std_logic_vector(9 downto 0) := (others => '1');

begin 

    pll_inst : pll 
        port map(
            CLKI => sdataIn,
            CLKOP => clk_rec
        );

        clkdiv_inst : CLKDIVC
        generic map (
            DIV => "4.0",
            GSR => "ENABLED"
        )
        port map (
            RST     => rst,
            ALIGNWD => '1',
            CLKI    => clk_rec,
            CDIV1   => cDiv1_open,
            CDIVX   => clk
        );

    deserializer : IDDRX4B
        generic map (
            GSR => "ENABLED"
        )
        port map (
            D       => sdataIn,
            ECLK    => clk_rec,
            SCLK    => clk,
            RST     => rst,
            ALIGNWD => '1',
            Q0      => pdata2mux(0),
            Q1      => pdata2mux(1),
            Q2      => pdata2mux(2),
            Q3      => pdata2mux(3),
            Q5      => pdata2mux(4),
            Q4      => pdata2mux(5),
            Q6      => pdata2mux(6),
            Q7      => pdata2mux(7)
        );

    decoder_10b_8b : dec_8b10b
        port map (
            RESET    => rst,
            RBYTECLK => clk,
            AI       => decoderIn(0),
            BI       => decoderIn(1),
            CI       => decoderIn(2),
            DI       => decoderIn(3),
            EI       => decoderIn(4),
            FI       => decoderIn(5),
            GI       => decoderIn(6),
            HI       => decoderIn(7),
            II       => decoderIn(8),
            JI       => decoderIn(9),
            HO       => decoderOut(7),
            GO       => decoderOut(6),
            FO       => decoderOut(5),
            EO       => decoderOut(4),
            DO       => decoderOut(3),
            CO       => decoderOut(2),
            BO       => decoderOut(1),
            AO       => decoderOut(0)
        );

        deserialize_proc : process(clk, rst)
        variable state : integer range 0 to 4 := 4;
        begin
            if rst = '0' then
                if clk'event and clk = '1' then
                    if state = 4 then
                        state := 0;
                    else
                        state := state + 1;
                    end if;
                end if;
            else
                state := 4;
            end if;
            case state is
                when 0 =>
                    reg4W_10W(39 downto 32) <= pdata2mux;
                    decoderIn <= tempreg;
					freez <= '0';
                when 1 =>
                    reg4W_10W(31 downto 24) <= pdata2mux;
                    decoderIn <= reg4W_10W (39 downto 30);
                when 2 =>
                    reg4W_10W(23 downto 16) <= pdata2mux;
                    decoderIn <= reg4W_10W (29 downto 20);
                when 3 =>
                    reg4W_10W(15 downto 8) <= pdata2mux;
                    decoderIn <= reg4W_10W (19 downto 10);
                when 4 =>
                    reg4W_10W(7 downto 0) <= pdata2mux;
                    decoderIn <= reg4W_10W (9 downto 0);
            end case;
        end process;
        Dec_Data_O <= decoderOut;
        clkout   <= clk;
		
end rtl;