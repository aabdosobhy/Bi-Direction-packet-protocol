----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    28/6/2019 
-- Design Name:    Link training between ZYNQ and MAchXO2 fpga (ZYNQ side)
-- Module Name:    train  
-- Target Devices: Zynq-7000  xc7z020clg400-1
-- Tool versions:  xilinx vivado
-- Description:    generates bits using PRNG with a ploynomial of 5320 with 
--                 the using of and LFSR and the output is serialaized using 
--                 serializer module.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation, either version
-- 3 of the License, or (at your option) any later version.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity train is
    Generic(
        SEED : std_logic_vector(7 downto 0) := "11100111"
        );
    port (
        clk : in std_logic;
        rst : in std_logic;
        lvds_p : out std_logic;
        lvds_n : out std_logic;
        rst_o_p : out std_logic;
        rst_o_n : out std_logic
        );
end train; 
    
architecture rtl of train is    

    signal word_alignment : std_logic_vector(7 downto 0) := "11110000";
    signal rst_word : std_logic_vector(7 downto 0) := "00000000";
    signal clkfbout1, clk_20, clk_5, locked1 : std_logic;
    signal GND_sig : std_logic := '0';
    signal state : std_logic_vector(1 downto 0) := "00";
    signal shift_2bits : std_logic_vector(1 downto 0);
    signal rst_save : std_logic;
    signal enc_8bit : std_logic_vector(7 downto 0);
    signal enc_10bit : std_logic_vector(9 downto 0);
    signal word_8b_O, word_8b_I : std_logic_vector(7 downto 0);
    signal count : std_logic_vector(4 downto 0);
    signal count1_falling : std_logic := '0';
    signal loop_cnt : std_logic;
    signal PRNG_O : std_logic_vector(1 downto 0);
    Signal en_PRNG_shift, en_wdAlign_shift, en_shift_wd8b : std_logic;
    signal lvds_O : std_logic;

begin

    enc_8b_10b : entity work.enc_8b10b
        port map(
            RESET => rst,
            SBYTECLK => clk_20,
            KI => GND_sig,
            AI => enc_8bit(0),
            BI => enc_8bit(1),
            CI => enc_8bit(2),
            DI => enc_8bit(3),
            EI => enc_8bit(4),
            FI => enc_8bit(5),
            GI => enc_8bit(6),
            HI => enc_8bit(7),
            JO => enc_10bit(9),
            HO => enc_10bit(8),
            GO => enc_10bit(7),
            FO => enc_10bit(6),
            IO => enc_10bit(5),
            EO => enc_10bit(4),
            DO => enc_10bit(3),
            CO => enc_10bit(2),
            BO => enc_10bit(1),
            AO => enc_10bit(0)
        );

    count_r : entity work.sh_rg(sh_Count) 
        generic map(
            size => 5
            )
        port map(
            clk => clk_20,
            rst =>  rst_save,
            enb => '1',
            LSin => loop_cnt,
            LSout => count
        );

    PRNG_Reg : entity work.PRNG
        generic map (
            SEED => SEED
            )
        port map(
            clk => clk_20,
            rst => rst_save,
            enb => en_PRNG_shift,
            PRNG_O => PRNG_O
        );

    word_8b_Reg : entity work.sh_2b_rg
        generic map(
            SIZE => 8,
            SHIFT_BS => 2,
            RST_VALUE => "11110000"
            )
        port map(
            clk => clk_20,
            rst =>  rst_save,
            enb => en_PRNG_shift,
            LSin => PRNG_O,
            LSout => word_8b_I
        );
        
    enc8b_save: entity work.nRegister
        generic map(
            SIZE => 8
            )
        port map(
            clk => clk_20,
            enb => count1_falling,
            rst => rst_save,
            d => word_8b_I,
            q => word_8b_O
        ); 

    serdes: entity work.serializer 
        port map (
            clk => clk_20,
            clk_Div => clk_5,
            rst => rst,
            Din => enc_10bit,
            serial_O => lvds_O
        );

    data_inst : OBUFDS
        generic map (
            IOSTANDARD => "DEFAULT",
            SLEW => "SLOW"
            )
        port map (
            O => lvds_p,
            OB => lvds_n,
            I => lvds_O
        );

    rst_inst : OBUFDS
        generic map (
            IOSTANDARD => "DEFAULT",
            SLEW => "SLOW"
            )
        port map (
            O => rst_o_p,
            OB => rst_o_n,
            I => rst
        );        

    PLL_BASE_inst1 : PLLE2_BASE
        generic map (
            CLKFBOUT_MULT  => 20,     -- Multiplication factor for all output clocks
            CLKFBOUT_PHASE => 0.0,    -- Phase shift (degrees) of all output clocks
            CLKIN1_PERIOD  => 20.000, -- Clock period (ns) of input clock on CLKIN

            CLKOUT0_DIVIDE     => 20,  -- Division factor for CLKOUT0 (1 to 128)
            CLKOUT0_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT0 (0.01 to 0.99)
            CLKOUT0_PHASE      => 0.0, -- Phase shift (degrees) for CLKOUT0 (0.0 to 360.0)

            CLKOUT1_DIVIDE     => 100,   -- Division factor for CLKOUT1 (1 to 128)
            CLKOUT1_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT1 (0.01 to 0.99)
            CLKOUT1_PHASE      => 0.0, -- Phase shift (degrees) for CLKOUT1 (0.0 to 360.0)

            DIVCLK_DIVIDE => 1,           -- Division factor for all clocks (1 to 52)
            BANDWIDTH     => "OPTIMIZED", -- "HIGH", "LOW" or "OPTIMIZED"
            REF_JITTER1   => 0.0,       -- Input reference jitter (0.000 to 0.999 UI%)
            STARTUP_WAIT  => "FALSE"
            )
        port map (
            CLKFBOUT => clkfbout1,  -- General output feedback signal
            CLKFBIN  => clkfbout1,  -- Clock feedback input
            CLKIN1   => clk,    --pll0_clk,  -- Clock input
            CLKOUT0  => clk_20,   -- One of six general clock output signals
            CLKOUT1  => clk_5,  -- One of six general clock output signals
            LOCKED   => locked1,    -- Active high PLL lock signal
            PWRDWN   => '0',        -- Power Down PLL
            RST      => '0'         -- Asynchronous PLL reset
        );
    process(clk_20, rst)
        variable count_alignwd : integer range 0 to 42 := 0;        
    begin 
        if rising_edge(clk_20) then 
            if rst = '1' then 
                rst_save <= '1';

            else 
                rst_save <= '0';
            end if;

            if rst_save = '0' then 
                if count(0) = '1' and state(1) = '0' then
                    count_alignwd := count_alignwd +1;

                    if count_alignwd = 40 then
                        state <= "01";
                        
                    elsif count_alignwd = 41 then
                        state <= "10";
                    end if;
                end if;

            else 
                count_alignwd := 0;
                state <= "00";
            end if;
        end if;

        if falling_edge(clk_20) then 
            count1_falling <= count(1);
        end if;
    end process;

    en_shift_wd8b <= not count(0);

    en_PRNG_shift <= en_shift_wd8b and  state(1);

    loop_cnt <= count(0);

    enc_8bit <= word_alignment when state = "00" else 
            rst_word when state = "01" else 
            word_8b_O;

end rtl;