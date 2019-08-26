----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    26/7/2019 
-- Design Name:    train.
-- Module Name:    train.
-- Target Devices: LCMXO2-1200HC
-- Package name:   TQFP100
-- grade: 		   6
-- Tool versions:  Lattice Diamond
-- Description:	   Receive the bits and compare them to the PRNG result and calculate BER.
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

library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library machxo2;
use machxo2.components.all;

entity train is
	Generic(
		SEED : std_logic_vector(7 downto 0) := "11011110"
		);
	port(
		clk : std_logic;
		datain : in std_logic;		
		rst : in std_logic;
		ec_0 : out std_logic;
		jtdo_O : out std_logic;
		temp_test : out std_logic
	);
end train;

architecture rtl of train is

	signal clk_pll_feed, clk_50, ECSOUT, e_clk, s_clk  : std_logic;
	signal dqsdel : std_logic;
	signal data_I_BUFF ,data_in_del : std_logic;
	signal cDiv1_open : std_logic;
	signal word_align : std_logic;
	signal not_clk : std_logic;
	signal dec_8b : std_logic_vector(7 downto 0);
	signal rst_sys , v_rst : std_logic;
	signal pdata2mux : std_logic_vector(7 downto 0);
	signal en_PRNG,	en_count : std_logic;
	signal finish_training : std_logic := '1';
	signal PRNG_O : std_logic_vector(1 downto 0);
	signal PRNG_8b : std_logic_vector(7 downto 0);	
	signal dqsdllc_lock : std_logic;
	signal BE_cnt: std_logic_vector(127 downto 0);
	signal jcnt : std_logic_vector(127 downto 0);
	signal jreg : std_logic_vector(127 downto 0);
	signal jtdi : std_logic;
	signal jtck : std_logic;
	signal jshift : std_logic;
	signal jrstn : std_logic;
	signal jupdate : std_logic;
	signal jce : std_logic_vector(2 downto 1);
	signal jtdo : std_logic_vector(2 downto 1);
	signal jrti : std_logic_vector(2 downto 1);
	signal temp_wd_align : std_logic;
begin

	data_IB : IB
		port map(
			I => datain,
			O => data_I_BUFF
			);

	delay_data : DELAYE
		generic map (
			DEL_VALUE => "DELAY0",
			DEL_MODE  => "ECLK_CENTERED"
			)
		port map (
			A => data_I_BUFF,
			Z => data_in_del
			);

	Inst_PLL : entity pll 
		port map(
			CLKI => clk,
			CLKOS => clk_pll_feed,
			CLKOP => clk_50
			);

	clk_SYNC_INST: ECLKSYNCA
		port map(
			ECLKI => clk_50,
			STOP  => '0',
			ECLKO => e_clk
			);

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

	deserilaizer_inst : entity deserializer 
		port map (
			e_clk => e_clk,
			s_clk => s_clk,			
			sdataIn => data_in_del,
			rst => rst,
			Dec_Data_O => dec_8b,
			word_align => word_align,
			v_rst => v_rst,
			en_PRNG => en_PRNG
			);

	PRNG_Reg : entity PRNG
		generic map (
			SEED => SEED
			)
		port map(
			clk => e_clk,
			rst => rst_sys,
			enb => en_PRNG,
			PRNG_O => PRNG_O
			);

	word_8b_r : entity sh_2b_rg 
		generic map(
			SIZE => 8,
			SHIFT_BS => 2,
			RST_VALUE => "01110000"
			)
		port map(
			clk => not_clk,
			rst =>  rst_sys,
			enb => en_PRNG,
			LSin => PRNG_O,
			LSout => PRNG_8b
			);

	count_error : entity count_diff 
		generic map(
			CMP_SIZE => 8,
			OUT_SIZE => 128
			)
		port map( 
			clk => s_clk,
			rst => rst_sys,
			enb => en_count,
			A => PRNG_8b,
			B => dec_8b,
			count_diff => BE_cnt
			);

	JTAGF_inst: JTAGF
		generic map (
			ER1 => "ENABLED",
			ER2 => "ENABLED" )
			port map (
			TCK => '0',
			TMS => '0',
			TDI => '0',
			TDO => open,
			--
			JTDI => jtdi,
			JTCK => jtck,
			--
			JSHIFT => jshift,
			JUPDATE => jupdate,
			JRSTN => jrstn,
			--
			JRTI1 => jrti(1),
			JRTI2 => jrti(2),
			--
			JTDO1 => jtdo(1),
			JTDO2 => jtdo(2),
			--
			JCE1 => jce(1),
			JCE2 => jce(2) 
			);

	process (s_clk)
		begin 
			if rising_edge(s_clk) and dec_8b = "11010110" then 
				finish_training <= '0';

			end if;
		end process;

	ce1_proc : process(e_clk, jrti(1))
		variable jce_v : std_logic := '0';
	begin
		if rising_edge(e_clk) then			
			if jrti(1) = '1' then
				jcnt <= BE_cnt;
			end if;
		end if;
	end process;

	er1_proc : process(jtck, jce(1))
	begin
		if falling_edge(jtck) then
			if jrstn = '0' then			-- Test Logic Reset

			elsif jce(1) = '1' then		-- Capture/Shift DR
				if jshift = '1' then	-- Shift DR
					jreg <= jtdi & jreg(127 downto 1);

				else					-- Capture DR
					jreg <= jcnt;

				end if;
			elsif jupdate = '1' then	-- update data

			elsif jrti(1) = '1' then	-- Run Test/Idle

			else						-- Last TDI bit
				jreg <= jtdi & jreg(127 downto 1);
			end if; 
		end if;
	end process;

	temp_test <= word_align;

	jtdo(1) <= jreg(0);
	en_count <= en_PRNG and finish_training;

	not_clk <= not e_clk;
	rst_sys <= rst or v_rst;	

	ec_0 <= BE_cnt(0);
	jtdo_O <= jreg(0);
	--jtdo_O <= jtdo(1);
			
end rtl;