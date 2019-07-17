library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

LIBRARY machxo2;
USE machxo2.all;

entity deserializer is
    port (
        e_clk : in std_logic;
        s_clk : in std_logic;
        sdataIn  : in std_logic;
        rst    : in std_logic;
        Dec_Data_O : out std_logic_vector (7 downto 0);
        word_align : out std_logic;
        v_rst : out std_logic;
        en_PRNG : out std_logic
    );
end deserializer;

architecture rtl of deserializer is 
    
    component IDDRX4B
        generic (
            GSR : string
        );
        port (
            D, ECLK, SCLK, RST, ALIGNWD : in std_logic;
            Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7 : out std_logic
        );
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

    signal word_align_en : std_logic;
	signal pdata2mux : std_logic_vector(7 downto 0);
	signal decoderIn : std_logic_vector(9 downto 0) := (others => '0');
    signal decoderOut : std_logic_vector(7 downto 0) := (others => '0');
	signal reg4W_10b : std_logic_vector(39 downto 0) := (others => '0');
    signal tempreg : std_logic_vector(9 downto 0) := (others => '1');
    signal setup_en : std_logic := '1';


begin 


    deserializer : IDDRX4B
        generic map (
            GSR => "ENABLED"
        )
        port map (
            D       => sdataIn,
            ECLK    => e_clk,
            SCLK    => s_clk,
            RST     => rst,
            ALIGNWD => word_align_en,
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
            RBYTECLK => s_clk,
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

        deserialize_proc : process(s_clk, rst)
        variable state : integer range 0 to 4 := 4;
        begin
            if rst = '0' then
                if s_clk'event and s_clk = '1' then
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
                    reg4W_10b(39 downto 32) <= pdata2mux;
					en_PRNG <= '0';
                when 1 =>
                    reg4W_10b(31 downto 24) <= pdata2mux;
                    decoderIn <= reg4W_10b (39 downto 30);
                    en_PRNG <= '1';
                when 2 =>
                    reg4W_10b(23 downto 16) <= pdata2mux;
                    decoderIn <= reg4W_10b (29 downto 20);
                    en_PRNG <= '1';
                when 3 =>
                    reg4W_10b(15 downto 8) <= pdata2mux;
                    decoderIn <= reg4W_10b (19 downto 10);
                    en_PRNG <= '1';

                when 4 =>
                    reg4W_10b(7 downto 0) <= pdata2mux;
                    decoderIn <= reg4W_10b (9 downto 0);
                    en_PRNG <= '1';

            end case;
        end process;
        
        process (e_clk)
        begin 
                if decoderOut = "11111111" and setup_en = '1' then 
                    v_rst <= '1';
                    setup_en <= '0';
                else
                    v_rst <= '0';
                end if;
        end process;
        word_align_en <= '1' when  setup_en ='1' and not (decoderOut = "11110000")
					else '0';
        word_align <= word_align_en;
        Dec_Data_O <= decoderOut;

		
end rtl;