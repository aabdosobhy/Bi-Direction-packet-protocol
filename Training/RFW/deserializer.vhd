----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    26/7/2019 
-- Design Name:    Deserializer
-- Module Name:    deserializer  
-- Target Devices: LCMXO2-1200HC
-- Package name:   TQFP100
-- grade: 		   4
-- Tool versions:  Lattice Diamond
-- Description:    receive the inoput serial bit and generate a 4 words of 10 bits every 5 s_clk 
--                 cycles and decode every word by the falling edge of sclk to be the decoded 
--                 8 bits word.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 

----------------------------------------------------------------------------------
-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation, either version
-- 3 of the License, or (at your option) any later version.
----------------------------------------------------------------------------------

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
        Dec_Data_O : out std_logic_vector (7 downto 0);
        word_align : out std_logic;
        v_rst : out std_logic;        
        en_PRNG : out std_logic 
    );
end deserializer;

architecture rtl of deserializer is 
    
    signal word_align_en : std_logic := '0';
    signal gnd : std_logic := '0';
    signal pdata2mux : std_logic_vector(7 downto 0);
    signal state : std_logic_vector(2 downto 0);
    signal decoderIn : std_logic_vector(9 downto 0) := (others => '0');
    signal decoderOut : std_logic_vector(7 downto 0) := (others => '0');
    signal reg4W_10b : std_logic_vector(39 downto 0) := (others => '0');
    signal tempreg : std_logic_vector(9 downto 0) := (others => '1');
    signal setup_en : std_logic := '1';
    signal v_rst_sig : std_logic := '0';
    signal en_prng_sig : std_logic := '0';

begin 

    deserializer : entity work.IDDRX4B
        generic map (
            GSR => "ENABLED"
        )
        port map (
            d       => sdataIn,
            eclk    => e_clk,
            sclk    => s_clk,
            rst     => rst,
            alignwd => word_align_en,
            q0      => pdata2mux(7),
            q1      => pdata2mux(6),
            q2      => pdata2mux(5),
            q3      => pdata2mux(4),
            q4      => pdata2mux(3),
            q5      => pdata2mux(2),
            q6      => pdata2mux(1),
            q7      => pdata2mux(0)
        );

    decoder_10b_8b : entity work.dec_8b10b
        port map (
            RESET    => gnd,
            RBYTECLK => e_clk,
            AI       => decoderIn(9),
            BI       => decoderIn(8),
            CI       => decoderIn(7),
            DI       => decoderIn(6),
            EI       => decoderIn(5),
            II       => decoderIn(4),
            FI       => decoderIn(3),
            GI       => decoderIn(2),
            HI       => decoderIn(1),            
            JI       => decoderIn(0),
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
    begin
        if rst = '0' then
            if rising_edge(s_clk) then 

                v_rst_sig <= '0';
 
                if state = "000" then
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
            end if;	
            
            if falling_edge(s_clk) then 
				if decoderOut = "00000000" and setup_en = '1' and rst = '0' then 					
						v_rst_sig <= '1';
                        setup_en <= '0';   
                        
				end if;               
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
                    decoderIn <= tempreg;
                    en_prng_sig <= '0';

                end if;
                
            elsif falling_edge(e_clk) then -- e_clk falling edge
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
                end if;
            end if;
    end process;

    word_align_en <= '1' when  setup_en ='1' and (not (decoderOut = "11110000")) 
                    and  s_clk = '0' and state = "010"
                else '0';
                    
    word_align <= word_align_en;
    Dec_Data_O <= decoderOut;
    v_rst <= v_rst_sig;
    en_PRNG <= en_prng_sig;        

end rtl;