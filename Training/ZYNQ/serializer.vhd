library ieee;
use ieee.std_logic_1164.all;
library UNISIM;
use UNISIM.VComponents.all;

entity serializer is
    port (
        clk : in std_logic;
        clk_Div : std_logic;
        rst : in std_logic;
        Din : std_logic_vector(9 downto 0);
        serial_O : out std_logic
        );
    end serializer; 
    
architecture rtl of serializer is

    signal SHIFT1 : std_logic := '0'; 
    signal SHIFT2 : std_logic := '0';

begin

    master : OSERDESE2 
        generic map ( 
            DATA_RATE_OQ => "SDR", -- DDR, SDR 
            DATA_RATE_TQ => "SDR", -- DDR, BUF, SDR 
            DATA_WIDTH => 10, -- Parallel data width (2-8,10,14) 
            INIT_OQ => '0', -- Initial value of OQ output (1'b0,1'b1) 
            INIT_TQ => '0', -- Initial value of TQ output (1'b0,1'b1) 
            SERDES_MODE => "MASTER", -- MASTER, SLAVE 
            SRVAL_OQ => '0', -- OQ output value when SR is used (1'b0,1'b1) 
            SRVAL_TQ => '0', -- TQ output value when SR is used (1'b0,1'b1) 
            TBYTE_CTL => "FALSE", -- Enable tristate byte operation (FALSE, TRUE) 
            TBYTE_SRC => "FALSE", -- Tristate byte source (FALSE, TRUE) 
            TRISTATE_WIDTH => 1 -- 3-state converter width (1,4) 
            ) 
        port map (
            OFB => open, -- 1-bit output: Feedback path for data 
            OQ => serial_O, -- 1-bit output: Data path output 
            -- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each) 
            SHIFTOUT1 => open, 
            SHIFTOUT2 => open, 
            TBYTEOUT => open, -- 1-bit output: Byte group tristate 
            TFB => open, -- 1-bit output: 3-state control 
            TQ => open, -- 1-bit output: 3-state control 
            CLK => clk, -- 1-bit input: High speed clock 
            CLKDIV => clk_Div, -- 1-bit input: Divided clock 
            -- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each) 
            D1 => Din(0), 
            D2 => Din(1), 
            D3 => Din(2), 
            D4 => Din(3), 
            D5 => Din(4), 
            D6 => Din(5), 
            D7 => Din(6), 
            D8 => Din(7),  
            OCE => '1', -- 1-bit input: Output data clock enable 
            RST => rst, -- 1-bit input: Reset 
            -- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each) 
            SHIFTIN1 => SHIFT1, 
            SHIFTIN2 => SHIFT2, -- T1 - T4: 1-bit (each) input: Parallel 3-state inputs 
            T1 => '0', 
            T2 => '0', 
            T3 => '0', 
            T4 => '0', 
            TBYTEIN => '0', -- 1-bit input: Byte group tristate 
            TCE => '0' -- 1-bit input: 3-state clock enable 
        );


    slave : OSERDESE2 
        generic map ( 
            DATA_RATE_OQ => "SDR", -- DDR, SDR 
            DATA_RATE_TQ => "SDR", -- DDR, BUF, SDR 
            DATA_WIDTH => 10, -- Parallel data width (2-8,10,14) 
            INIT_OQ => '1', -- Initial value of OQ output (1'b0,1'b1) 
            INIT_TQ => '1', -- Initial value of TQ output (1'b0,1'b1) 
            SERDES_MODE => "SLAVE", -- MASTER, SLAVE 
            SRVAL_OQ => '0', -- OQ output value when SR is used (1'b0,1'b1) 
            SRVAL_TQ => '0', -- TQ output value when SR is used (1'b0,1'b1) 
            TBYTE_CTL => "FALSE", -- Enable tristate byte operation (FALSE, TRUE) 
            TBYTE_SRC => "FALSE", -- Tristate byte source (FALSE, TRUE) 
            TRISTATE_WIDTH => 1 -- 3-state converter width (1,4) 
            ) 
        port map (
            OFB => open, -- 1-bit output: Feedback path for data 
            OQ => open, -- 1-bit output: Data path output 
            -- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each) 
            SHIFTOUT1 => SHIFT1, 
            SHIFTOUT2 => SHIFT2, 
            TBYTEOUT => open, -- 1-bit output: Byte group tristate 
            TFB => open, -- 1-bit output: 3-state control 
            TQ => open, -- 1-bit output: 3-state control 
            CLK => clk, -- 1-bit input: High speed clock 
            CLKDIV => clk_Div, -- 1-bit input: Divided clock 
            -- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each) 
            D1 => '0', 
            D2 => '0', 
            D3 => Din(8), 
            D4 => Din(9), 
            D5 => '0', 
            D6 => '0', 
            D7 => '0', 
            D8 => '0',  
            OCE => '1', -- 1-bit input: Output data clock enable 
            RST => rst, -- 1-bit input: Reset 
            -- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each) 
            SHIFTIN1 => '0', 
            SHIFTIN2 => '0', -- T1 - T4: 1-bit (each) input: Parallel 3-state inputs 
            T1 => '0', 
            T2 => '0', 
            T3 => '0', 
            T4 => '0', 
            TBYTEIN => '0', -- 1-bit input: Byte group tristate 
            TCE => '0' -- 1-bit input: 3-state clock enable 
        );

end rtl;