library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity i2s is
    port
    (
        clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
        
        lrclk : in std_logic;
        bclk : in std_logic;
        sdi : in std_logic;
        
        adc_valid_l : out std_logic;
        adc_valid_r : out std_logic;
        adc_data : out std_logic_vector(23 downto 0)
    );
end i2s;

architecture rtl of i2s is

signal edge_ff_bclk : std_logic_vector(2 downto 0) := (others => '0');
signal bclk_rise : std_logic := '0';

signal edge_ff_lrclk : std_logic_vector(2 downto 0) := (others => '0');
signal lrclk_rise : std_logic := '0';
signal lrclk_fall : std_logic := '0';

signal adc_shr : std_logic_vector(23 downto 0) := (others => '0'); 
signal sdi_shift_ff : std_logic_vector(2 downto 0) := (others => '0');

begin

--Shift BCLK
proc_bclk: process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            edge_ff_bclk <= (others => '0');
            edge_ff_lrclk <= (others => '0');
        else
            --Shift BCLK
            edge_ff_bclk <= edge_ff_bclk(1 downto 0) & bclk;
            
            --Shift LRCLK
            edge_ff_lrclk <= edge_ff_lrclk(1 downto 0) & lrclk; 
            
            --Shift SDI
            sdi_shift_ff <= sdi_shift_ff(1 downto 0) & sdi;  
        end if;
    end if;
end process proc_bclk;

--Detect rise & fall
bclk_rise <= '1' when (edge_ff_bclk(2) = '0' and edge_ff_bclk(1) = '1') else '0';
lrclk_rise <= '1' when (edge_ff_lrclk(2) = '0' and edge_ff_lrclk(1) = '1') else '0';
lrclk_fall <= '1' when (edge_ff_lrclk(2) = '1' and edge_ff_lrclk(1) = '0') else '0';

--Shift ADC
proc_adc_shr : process(clk)
begin
    if(rising_edge(clk)) then
        if(bclk_rise = '1') then
            adc_shr <= adc_shr(22 downto 0) & sdi_shift_ff(2);
        end if;           
    end if;
end process proc_adc_shr;

--ADC Valid
adc_valid_r <= lrclk_rise and en;
adc_valid_l <= lrclk_fall and en;

--ADC Data
adc_data <= adc_shr;

end rtl;