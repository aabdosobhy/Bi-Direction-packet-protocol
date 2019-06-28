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

    signal sh_rg : std_logic_vector(SIZE -1 downto 0);
begin

    process (clk)
    begin       
        if rising_edge(clk)  then 
            if rst = '1' then 
                sh_rg <= (others => '0');
            elsif enb = '1' then 
                sh_rg <= LSin & Sh_rg(7 downto 1);
            end if;
        
        end if;
    end process;
    LSout <= Sh_rg;
end sh_rg_A;

architecture sh_Count of sh_rg is
    
    signal sh_rg_C : std_logic_vector(SIZE -1 downto 0);

begin
    
    process (clk)
    begin
        
        if rising_edge(clk)  then 
            if rst = '1' then 
                sh_rg_C <= (SIZE -1 => '1' , others => '0');
            elsif enb = '1' then 
                sh_rg_C <= LSin & sh_rg_C(SIZE -1 downto 1);
            end if;
        
        end if;
    end process;
    LSout <= sh_rg_C;
end sh_Count;