----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    26/7/2019 
-- Design Name:    train.
-- Module Name:    train.
-- Target Devices: LCMXO2-1200HC
-- Package name:   TQFP100
-- grade: 		   4
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
use machxo2.all;

entity train is
	Generic(
		SEED : std_logic_vector(7 downto 0) := "11011110"
		);
	port(
		clk : std_logic;
		datain : in std_logic;		-- clock
		rst : in std_logic;
		ec_0 : out std_logic;
		jtdo_O : out std_logic
		);
end train;

architecture rtl of train is
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
	
	component deserializer is
		port (
			e_clk : in std_logic;
			s_clk : in std_logic;
			sdataIn  : in std_logic;
			rst    : in std_logic;
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
	end component;

	component IB
		port (
			I : in  std_logic;
			O : out std_logic
			);
	end component;

	component ECLKSYNCA
		port (
			ECLKI : in std_logic;
			STOP  : in std_logic;
			ECLKO : out std_logic
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
			CDIVX : out std_logic
			);
	end component;

	component DQSDLLC
		generic (
			FORCE_MAX_DELAY  : in String;
			FIN              : in String;
			LOCK_SENSITIVITY : in String
			);
		port (
			CLK      : in  std_logic;
			RST      : in  std_logic;
			UDDCNTLN : in  std_logic;
			FREEZE   : in  std_logic;
			LOCK     : out std_logic;
			DQSDEL   : out std_logic
			);
	end component;

	component DLLDELC
		port (
			CLKI   : in  std_logic;
			DQSDEL : in  std_logic;
			CLKO   : out std_logic
			);
	end component;

	component DELAYE
        generic (
            DEL_VALUE : in String;
            DEL_MODE  : in String
        	);
        port (
            A : in  std_logic;
            Z : out std_logic
        	);
	end component;
	
	component pll is
		port (
			CLKI: in  std_logic; 
			CLKOP: out  std_logic);
		end component;

	component PRNG is
		Generic (
			SEED : std_logic_vector := "11100111"
			);
		port (
			clk : in std_logic;
			rst : in std_logic;
			enb : in std_logic;
			PRNG_O : out std_logic_vector (1 downto 0)
			);
	end component;

	component count_diff is
		generic (
			CMP_SIZE : integer  := 8;
			OUT_SIZE : integer  := 32
			);
		port ( 
			clk : in std_logic;
			rst : in std_logic;
			enb : in std_logic;
			A : in std_logic_vector (CMP_SIZE -1 downto 0);
			B : in std_logic_vector (CMP_SIZE -1 downto 0);
			count_diff : out std_logic_vector (OUT_SIZE -1 downto 0)
			);
	end component;

	component sh_2b_rg is
		generic(
			SIZE : integer := 8;
			SHIFT_BS : integer := 2
			);
		port (
			clk : in std_logic;
			rst : in std_logic;
			enb : in std_logic;
			LSin : in std_logic_vector(SHIFT_BS -1 downto 0);
			LSout : out std_logic_vector(SIZE -1 downto 0)
			);
	end component; 

	component  sh_ld_rg is
		generic(
			SIZE : integer := 8
			);
		port (
			clk : in std_logic;
			rst : in std_logic;
			enb : in std_logic;
			load : in std_logic_vector(SIZE -1 downto 0);
			LSout : out std_logic
		);
	end component; 
	
	component JTAGF is
		generic (
			ER1 : string;
			ER2 : string
			);
		port  (
			TCK : in std_logic;
			TMS : in std_logic;
			TDI : in std_logic;
			JTDO2 : in std_logic;
			JTDO1 : in std_logic;
			TDO : out std_logic;
			JTDI : out std_logic;
			JTCK : out std_logic;
			JRTI2 : out std_logic;
			JRTI1 : out std_logic;
			JSHIFT : out std_logic;
			JRSTN : out std_logic;
			JUPDATE : out std_logic;
			JCE1 : out std_logic;
			JCE2 : out std_logic
			);
	end component;

	
	signal clk_BUFF, clk_pll, d_clk, e_clk, s_clk  : std_logic;
	signal dqsdel : std_logic;
	signal data_I_BUFF ,data_in_del : std_logic;
	signal cDiv1_open : std_logic;
	signal word_align : std_logic;
	signal not_clk : std_logic;
	signal dec_8b : std_logic_vector(7 downto 0);
	signal rst_sys , v_rst : std_logic;
	signal pdata2mux : std_logic_vector(7 downto 0);
	signal state : std_logic_vector(2 downto 0);
	signal decoderIn : std_logic_vector(9 downto 0);
	signal decoderOut : std_logic_vector(7 downto 0);
	signal reg4W_10b : std_logic_vector(39 downto 0);	
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
	
begin

	data_IB : IB
		port map(
			I => datain,
			O => data_I_BUFF
			);


	delay_data : DELAYE
		generic map (
			DEL_VALUE => "DELAY0",
			DEL_MODE  => "ECLK_ALIGNED"
			)
		port map (
			A => data_I_BUFF,
			Z => data_in_del
			);


	-- clk_IB : IB
	-- 	port map(
	-- 		I => clk,
	-- 		O => clk_BUFF
	-- 		);

	-- delay_clk : DELAYE
	-- generic map (
	-- 	DEL_VALUE => "DELAY0",
	-- 	DEL_MODE  => "ECLK_CENTERED"
	-- 	)
	-- port map (
	-- 	A => clk_BUFF,
	-- 	Z => d_clk
	-- 	);		

	-- Inst_PLL : pll 
	-- 	port map(
	-- 		CLKI => clk_BUFF, 
	-- 		CLKOP => clk_pll
	-- 		);

	Inst_DLLDELC : DLLDELC
		port map (
			CLKI   => clk,
			DQSDEL => dqsdel,
			CLKO   => d_clk
			);

	Inst_DQSDLLC : DQSDLLC
		generic map (FORCE_MAX_DELAY => "NO",
			FIN              => "50.0",
			LOCK_SENSITIVITY => "LOW"
			)
		port map (
			CLK      => e_clk,
			RST      => rst,
			UDDCNTLN => '0',
			FREEZE   => '0',
			LOCK     => dqsdllc_lock,
			DQSDEL   => dqsdel
			);

	clk_SYNC_INST: ECLKSYNCA
		port map(
			ECLKI => d_clk, --d_clk,
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
			   
	deserilaizer_inst : deserializer 
		port map (
			e_clk => e_clk,
			s_clk => s_clk,			
			sdataIn => data_in_del,
			rst => rst,
			Dec_Data_O => dec_8b,
			word_align => word_align,
			v_rst => v_rst,
			pdata2mux_s => pdata2mux,
			state_s => state,
			decoderIn_s => decoderIn,
			decoderOut_s => decoderOut,
			reg4W_10b_s => reg4W_10b,
			en_PRNG => en_PRNG
			);

	PRNG_Reg : PRNG
		generic map (
			SEED => SEED
			)
		port map(
			clk => e_clk,
			rst => rst_sys,
			enb => en_PRNG,
			PRNG_O => PRNG_O
			);

	word_8b_r : sh_2b_rg 
		generic map(
			SIZE => 8,
			SHIFT_BS => 2
			)
		port map(
			clk => not_clk,
			rst =>  rst_sys,
			enb => en_PRNG,
			LSin => PRNG_O,
			LSout => PRNG_8b
			);
	
	count_error : count_diff 
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

	-- final_result_jtag: sh_ld_rg 
	-- 	generic map(
	-- 		SIZE => 13
	-- 		)
	-- 	port map(
	-- 		clk => e_clk,
	-- 		rst => rst,
	-- 		enb => JRTI1,
	-- 		load => BE_cnt,
	-- 		LSout => shift_count_o
	-- 	);

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
			JCE2 => jce(2) );

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
			if jrstn = '0' then		-- Test Logic Reset

			elsif jce(1) = '1' then	-- Capture/Shift DR
				if jshift = '1' then	-- Shift DR
					jreg <= jtdi & jreg(127 downto 1);

				else			-- Capture DR
					jreg <= jcnt;
				end if;

			elsif jupdate = '1' then
			-- 	led(7 downto 0) <= jreg(7 downto 0);
			-- 	rst <= jreg(8);
			elsif jrti(1) = '1' then	-- Run Test/Idle

			else			-- Last TDI bit
				jreg <= jtdi & jreg(127 downto 1);
			end if; 
		end if; 
    end process;

    jtdo(1) <= jreg(0);
	--jtdo(1) <= e_clk;
	en_count <= en_PRNG and finish_training;

	not_clk <= not e_clk;
	rst_sys <= rst or v_rst;	

	ec_0 <= BE_cnt(0);
	jtdo_O <= jtdo(1);
			
end rtl;
