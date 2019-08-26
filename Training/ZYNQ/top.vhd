----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    28/6/2019 
-- Design Name:    top 
-- Module Name:    top  
-- Target Devices: Zynq-7000  xc7z020clg400-1
-- Tool versions:  xilinx vivado
-- Description:    top module that generates bits using PRNG with a ploynomial 
--                 of 5320 with the using of and LFSR and the output is serialaized  
--                 using serializer module.
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

library unisim;
use unisim.VCOMPONENTS.ALL;

entity top is
    port (
        clk_o : out std_logic;
        ser_data_O_p : out std_logic;
        ser_data_O_n : out std_logic;
        rst_o_p : out std_logic;
        rst_o_n : out std_logic;        
        i2c_scl : inout std_logic;	-- icsp clock
        i2c_sda : inout std_logic	-- icsp data
        );
end top; 
    
architecture rtl of top is    

    signal ps_fclk : std_logic_vector(3 downto 0);
    signal clk_50 : std_logic;
    signal ps_reset_n : std_logic_vector(3 downto 0);
    signal rst : std_logic;
    --------------------------------------------------------------------
    -- I2C Signals
    --------------------------------------------------------------------

    signal i2c_sda_i : std_logic;
    signal i2c_sda_o : std_logic;
    signal i2c_sda_t : std_logic;

    signal i2c_scl_i : std_logic;
    signal i2c_scl_o : std_logic;
    signal i2c_scl_t : std_logic;

    signal i2c1_sda_i : std_logic;
    signal i2c1_sda_o : std_logic;
    signal i2c1_sda_t : std_logic;
    signal i2c1_sda_t_n : std_logic;

    signal i2c1_scl_i : std_logic;
    signal i2c1_scl_o : std_logic;
    signal i2c1_scl_t : std_logic;
    signal i2c1_scl_t_n : std_logic;

begin

    ps7_stub_inst : entity work.ps7_stub
        port map (
            ps_fclk => ps_fclk,
            i2c1_sda_i => i2c1_sda_i,
            i2c1_sda_o => i2c1_sda_o,
            i2c1_sda_t_n => i2c1_sda_t_n,
            --
            i2c1_scl_i => i2c1_scl_i,
            i2c1_scl_o => i2c1_scl_o,
            i2c1_scl_t_n => i2c1_scl_t_n,
            ps_reset_n => ps_reset_n
            );

    BUFG_clk50_inst : BUFG
        port map (
            I => ps_fclk(0),
            O => clk_50 
            );

    train_inst : entity work.train 
        generic map (
            SEED => "11100111"
            )
        port map(
            clk => clk_50,
            rst => rst,                   
            ser_data_p => ser_data_O_p,
            ser_data_n => ser_data_O_n,
            rst_o_p => rst_o_p, 
            rst_o_n => rst_o_n
            );

        --------------------------------------------------------------------
    -- I2C Interface
    --------------------------------------------------------------------

    i2c_sda_o <= i2c1_sda_o;
    i2c_sda_t <= i2c1_sda_t;

    i2c1_sda_i <= i2c_sda_i;
    i2c1_sda_t <= not i2c1_sda_t_n;

    IOBUF_sda_inst : IOBUF
        port map (
            I => i2c_sda_o, O => i2c_sda_i,
            T => i2c_sda_t, IO => i2c_sda );

    PULLUP_sda_inst : PULLUP
        port map ( O => i2c_sda );

    i2c_scl_o <= i2c1_scl_o;
    i2c_scl_t <= i2c1_scl_t;

    i2c1_scl_i <= i2c_scl_i;
    i2c1_scl_t <= not i2c1_scl_t_n;

    IOBUF_scl_inst : IOBUF
        port map (
            I => i2c_scl_o, O => i2c_scl_i,
            T => i2c_scl_t, IO => i2c_scl );

    PULLUP_scl_inst : PULLUP
        port map ( O => i2c_scl );

    clk_o <= clk_50;
    rst <= ps_reset_n(0);
    
end rtl;
