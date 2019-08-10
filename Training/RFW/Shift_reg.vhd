----------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    26/7/2019 
-- Design Name:    shift register 1 bit.
-- Module Name:    sh_rg_A, sh_Count.
-- Target Devices: LCMXO2-1200HC
-- Package name:   TQFP100
-- grade: 		   4
-- Tool versions:  Lattice Diamond
-- Description
--     (sh_rg_A):  

--    (sh_Count):    
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

entity sh_rg is
    generic(
        SIZE : integer := 8
        );
    port (
        clk : in std_logic;
        rst : in std_logic;
        enb : in std_logic;
        LSin : in std_logic;
        LSout : out std_logic_vector(SIZE -1 downto 0)
    );
    end sh_rg; 
    
architecture sh_rg_A of sh_rg is
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

    signal sh_rg_I : std_logic_vector(SIZE -1 downto 0);
    signal Sh_rg_O : std_logic_vector(SIZE -1 downto 0);

begin
    shift_reg : nRegister 
        generic map(
            SIZE => SIZE)
        port map(
            clk => clk,
            enb => '1',
            rst => rst,
            d => sh_rg_I,
            q => Sh_rg_O
        );
    
    process (clk)
    begin      
	if rst = '1' then 
		sh_rg_I <= (others => '0');

        elsif rising_edge(clk) and enb = '1' then 
                sh_rg_I <= LSin & Sh_rg_O(7 downto 1);
            end if;
        
    end process;
    LSout <= Sh_rg_O;
end sh_rg_A;

architecture sh_Count of sh_rg is
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

    signal sh_rg_I : std_logic_vector(SIZE -1 downto 0);
    signal Sh_rg_O : std_logic_vector(SIZE -1 downto 0);

begin
    shift_reg : nRegister 
        generic map(
            SIZE => SIZE)
        port map(
            clk => clk,
            enb => '1',
            rst => rst,
            d => sh_rg_I,
            q => Sh_rg_O
        );
    
    process (clk, rst)
    begin
        
	if rst ='1' then 
		sh_rg_I <= (SIZE -1 => '1' , others => '0');
        elsif rising_edge(clk)  and enb = '1' then 
                sh_rg_I <= LSin & Sh_rg_O(SIZE -1 downto 1);
            end if;
        
    end process;
    LSout <= Sh_rg_O;
end sh_Count;