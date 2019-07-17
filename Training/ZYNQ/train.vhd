----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    28/6/2019 
-- Design Name:    Link training between ZYNQ and MAchXO2 fpga (ZYNQ side)
-- Module Name:    tain  
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
library UNISIM;
use UNISIM.VComponents.all;

entity train is
    Generic(
        SEED : std_logic_vector(7 downto 0) := "11100111"
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        lvds_p : out std_logic;
        lvds_n : out std_logic
        );
    end train; 
    
architecture rtl of train is
    
    component PRNG is
        Generic (
            SEED : std_logic_vector := "11100111"
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            enb : in std_logic;
            PRNG_O : out std_logic
        );
    end component;
    
    component enc_8b10b is	
        port(
            RESET : in std_logic;		-- Global asynchronous reset (active high) 
            SBYTECLK : in std_logic ;	-- Master synchronous send byte clock
            KI : in std_logic ;			-- Control (K) input(active high)
            AI, BI, CI, DI, EI, FI, GI, HI : in std_logic ;	-- Unencoded input data
            JO, HO, GO, FO, IO, EO, DO, CO, BO, AO : out std_logic 	-- Encoded out 
        );
    end component;

    component  serializer is
        port (
            clk : in std_logic;
            clk_Div : std_logic;
            rst : in std_logic;
            Din : std_logic_vector(9 downto 0);
            serial_O : out std_logic
            );
    end component; 


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

    signal rst_save : std_logic;
    signal enc_8bit : std_logic_vector(7 downto 0);
    signal enc_10bit : std_logic_vector(9 downto 0);
    signal word_8b : std_logic_vector(7 downto 0);
    signal not_clk : std_logic;
    signal count : std_logic_vector(9 downto 0);
    signal loop_cnt : std_logic;
    signal PRNG_O : std_logic;
    Signal en_shift : std_logic;
    signal lvds_O : std_logic;

begin
    
    enc_8b_10b : enc_8b10b
        port map(
            RESET => rst,
            SBYTECLK => clk,
            KI => '0',
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
            size => 10
            )
        port map(
            clk => clk,
            rst =>  rst_save,
            enb => '1',
            LSin => loop_cnt,
            LSout => count
        );
    
    word_8b_Reg : entity work.sh_rg(sh_rg_A)
        generic map(
            size => 8
            )
        port map(
            clk => not_clk,
            rst =>  rst_save,
            enb => en_shift,
            LSin => PRNG_O,
            LSout => enc_8bit
        );

    PRNG_Reg : PRNG
        generic map (
            SEED => SEED
            )
        port map(
            clk => clk,
            rst => rst_save,
            enb => en_shift,
            PRNG_O => PRNG_O
        );

    serdes: serializer 
        port map (
            clk => clk,
            clk_Div => count(9),
            rst => rst,
            Din => enc_10bit,
            serial_O => lvds_O
        );

    OBUFDS_inst : OBUFDS
        generic map (
            IOSTANDARD => "DEFAULT",
            SLEW => "SLOW"
            )
        port map (
            O => lvds_p,
            OB => lvds_n,
            I => lvds_O
        );

    process(clk)
    begin 
        if rising_edge(clk) then 
            if rst = '1' then 
                rst_save <= '1';
            else rst_save <= '0';
            end if;
        end if;
    end process;
            
    not_clk <= not clk; 
    en_shift <= not (count(1) or count(0));
    enc_10bit <= enc_10bit(9) & enc_10bit(8) & enc_10bit(7) & enc_10bit(6) & enc_10bit(5) & enc_10bit(4) 
        & enc_10bit(3) & enc_10bit(2) & enc_10bit(1) & enc_10bit(0);
    loop_cnt <= count(0);
end rtl;