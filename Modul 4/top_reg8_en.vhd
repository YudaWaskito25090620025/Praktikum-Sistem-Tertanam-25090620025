library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_reg8_en is
    Port ( clk  : in  STD_LOGIC;                      -- W5 (100 MHz)
           sw   : in  STD_LOGIC_VECTOR (7 downto 0);  -- Switch
           btnC : in  STD_LOGIC;                      -- en
           btnU : in  STD_LOGIC;                      -- rst
           led  : out STD_LOGIC_VECTOR (7 downto 0)); -- Output LED
end top_reg8_en;

architecture Behavioral of top_reg8_en is
    -- Deklarasi komponen reg8_en (Kode 4.2 dari modul)
    component reg8_en
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               en  : in STD_LOGIC;
               d   : in STD_LOGIC_VECTOR (7 downto 0);
               q   : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
begin
    -- Mapping port sesuai instruksi praktikum
    UUT: reg8_en port map (
        clk => clk,
        rst => btnU,
        en  => btnC,
        d   => sw,
        q   => led
    );
end Behavioral;