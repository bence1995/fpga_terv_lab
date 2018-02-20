----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/15/2018 08:06:11 PM
-- Design Name: 
-- Module Name: i2s - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2s is
    port
    (
        clk : in std_logic;
        rst : in std_logic;
        
        lrclk : in std_logic;
        bclk : in std_logic;
        sdi : in std_logic;
        
        en : out std_logic;
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

begin

--Shift BCLK
proc_bclk: process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            edge_ff_bclk <= (others => '0');
        else
            --Shift
            edge_ff_bclk <= edge_ff_bclk(1 downto 0) & bclk;
           
        end if;
    end if;
end process proc_bclk;

--Detect rise
bclk_rise <= '1' when (edge_ff_bclk(2) = '0' and edge_ff_bclk(1) = '1') else '0';


--Shift LRCLK
proc_lrclk: process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            edge_ff_lrclk <= (others => '0');
        else
            --Shift
            edge_ff_lrclk <= edge_ff_lrclk(1 downto 0) & lrclk;                        
        end if;
    end if;
end process proc_lrclk;

--Detect rise
lrclk_rise <= '1' when (edge_ff_lrclk(2) = '0' and edge_ff_lrclk(1) = '1') else '0';

--Detect fall
lrclk_fall <= '1' when (edge_ff_lrclk(2) = '1' and edge_ff_lrclk(1) = '0') else '0';

--Shift SDI
proc_adc_shr : process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            adc_shr <= (others => '0');
        else
            --Shift
            if(bclk_rise = '1') then
                adc_shr <= adc_shr(22 downto 0) & sdi;
            end if;           
        end if;
    end if;
end process proc_adc_shr;

--Enable
en <= lrclk_rise or lrclk_fall;

--ADC Valid
adc_valid_r <= lrclk_rise;
adc_valid_l <= lrclk_fall;

--ADC Data
adc_data <= adc_shr;

end rtl;
