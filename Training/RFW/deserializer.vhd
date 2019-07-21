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
        sdataIn : in std_logic;
        rst : in std_logic;
        -- word_align_en : in std_logic;
        Dec_Data_O : out std_logic_vector (7 downto 0);
        word_align : out std_logic;
        v_rst : out std_logic;
        
        pdata2mux_s : out std_logic_vector(7 downto 0);
        state_s : out std_logic_vector(2 downto 0);
        decoderIn_s : out std_logic_vector(9 downto 0);
        decoderOut_s : out std_logic_vector(7 downto 0);
        reg4W_10b_s : out std_logic_vector(39 downto 0);

        en_PRNG : out std_logic
    );
end deserializer;

architecture rtl of deserializer is 
    
    component iddrx4b
        generic (
            GSR : string
        );
        port (
            d, eclk, sclk, rst, alignwd : in std_logic;
            q0, q1, q2, q3, q4, q5, q6, q7 : out std_logic
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

    signal word_align_mask : std_logic := '0';
    signal rst_wd_mask : std_logic := '0';
    signal word_align_en : std_logic := '0';
    signal pdata2mux : std_logic_vector(7 downto 0);
    signal state : std_logic_vector(2 downto 0);
	signal decoderIn : std_logic_vector(9 downto 0) := (others => '0');
    signal decoderOut : std_logic_vector(7 downto 0) := (others => '0');
	signal reg4W_10b : std_logic_vector(39 downto 0) := (others => '0');
    signal tempreg : std_logic_vector(9 downto 0) := (others => '1');
    signal setup_en : std_logic := '1';
    signal v_rst_sig : std_logic := '0';
    signal en_prng_sig : std_logic := '0';
    -- signal flag_append_en : std_logic := '0';
    -- signal flag_rst_append : std_logic := '0';


begin 


    deserializer : IDDRX4B
        generic map (
            GSR => "ENABLED"
        )
        port map (
            d       => sdataIn,
            eclk    => e_clk,
            sclk    => s_clk,
            rst     => rst,
            alignwd => word_align_en,
            q0      => pdata2mux(0),
            q1      => pdata2mux(1),
            q2      => pdata2mux(2),
            q3      => pdata2mux(3),
            q4      => pdata2mux(4),
            q5      => pdata2mux(5),
            q6      => pdata2mux(6),
            q7      => pdata2mux(7)
        );

    decoder_10b_8b : dec_8b10b
        port map (
            RESET    => rst,
            RBYTECLK => e_clk,
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
        -- variable state : integer range 0 to 4 := 4;
        begin
            if rst = '0' then
                if rising_edge(s_clk) then 
                
                -- flag_append_en <= '1';

                    if decoderOut = "00000000" and setup_en = '1' then 
                        v_rst_sig <= '1';
                        state <= "000";
                        setup_en <= '0';
                    
                        --word_align_en <= '0';
                    

                    elsif state = "000" then
                        state <= "001";

                    
                    elsif state = "001" then 
                        state <= "010";

                    
                    elsif state = "010" then
                        state <= "011";

                    
                    elsif state = "011" then
                        state <= "100";

                    
                    elsif state = "100" then
                        state <= "000";
                    
                    else 
                    state <= "000";
                                        
                    end if;
                    -- word_align_en <= '0';

                elsif falling_edge(s_clk) then    --falling edge

                    -- word_align_mask <= '1';
                --     word_align_en <= '1' when  setup_en ='1' and not (decoderOut = "11110000")
                --     else '0';
                        
                end if;
            else
                state <= "000";
            end if;
            

        end process;
        
        process (e_clk)
        begin 
                if rising_edge(e_clk) then 
                   
                    if state = "001" then 
                        decoderIn <= reg4W_10b (39 downto 30);
                         en_prng_sig<= '1';

                    elsif state = "010" then 
                        decoderIn <= reg4W_10b (29 downto 20);
                        en_prng_sig <= '1';

                    elsif state = "011" then 
                        decoderIn <= reg4W_10b (19 downto 10);
                        en_prng_sig <= '1';

                    elsif state = "100" then 
                        decoderIn <= reg4W_10b (9 downto 0);
                        en_prng_sig <= '1';
                    else 
                        en_prng_sig <= '0';
                    end if;
                    
                    
                    if word_align_mask = '1' then 
                        rst_wd_mask <= '1';
                    end if;
                    if s_clk = '1' then 
                        rst_wd_mask <= '0';
                    end if;
                else  -- falling edge
                    if s_clk = '1' then 
                        if state = "001" then                             
                            reg4W_10b(31 downto 24) <= pdata2mux;

                        elsif state = "010" then                             
                            reg4W_10b(23 downto 16) <= pdata2mux;
                           
                        elsif state = "011" then                             
                            reg4W_10b(15 downto 8) <= pdata2mux;

                        elsif state = "100" then 
                            reg4W_10b(7 downto 0) <= pdata2mux;

                        else 
                            reg4W_10b(39 downto 32) <= pdata2mux;
                        
                        end if;
                    -- elsif s_clk = '0' then 
                    --     if setup_en = '1' and not (decoderOut = "11110000") then 
                    --         word_align_en <= '1';
                    --     -- else 
                    --     --    word_align_en <= '0';
                    --     end if;
                    else 
                        if word_align_mask = '0' and rst_wd_mask = '0' then 
                            word_align_mask <= '1';
                        else 
                            word_align_mask <= '0';
                        end if;

                    end if;

                    -- if word_align_mask = '1' then 
                    --     rst_wd_mask <= '1';
                    -- -- else word_align_mask <= '0';
                    -- end if;

                end if;
        end process;
        word_align_en <= '1' when  setup_en ='1' and (not (decoderOut = "11110000")) and  word_align_mask = '1'
                    else '0';
                    
        word_align <= word_align_en;
        Dec_Data_O <= decoderOut;
        v_rst <= v_rst_sig;
        en_PRNG <= en_prng_sig;
        
        pdata2mux_s <= pdata2mux;
        state_s <= state;
        decoderIn_s <= decoderIn;
        decoderOut_s <= decoderOut;
        reg4W_10b_s <= reg4W_10b;

end rtl;