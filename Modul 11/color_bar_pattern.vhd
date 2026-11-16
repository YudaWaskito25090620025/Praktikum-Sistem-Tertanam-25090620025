library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity color_bar_pattern is
    Port ( h_count : in  integer range 0 to 799;
           v_count : in  integer range 0 to 524;
           rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
end color_bar_pattern;

architecture Behavioral of color_bar_pattern is

    constant H_DISPLAY : integer := 640;
    constant ZONE_W    : integer := H_DISPLAY / 8;  -- 80 piksel per zona

    signal zone : integer range 0 to 7;

begin

    zone <= h_count / ZONE_W when h_count < H_DISPLAY else 0;

    process(zone)
    begin
        case zone is
            when 0 => rgb <= "111111111111"; -- Putih
            when 1 => rgb <= "111111110000"; -- Kuning
            when 2 => rgb <= "000011111111"; -- Cyan
            when 3 => rgb <= "000011110000"; -- Hijau
            when 4 => rgb <= "111100001111"; -- Magenta
            when 5 => rgb <= "111100000000"; -- Merah
            when 6 => rgb <= "000000001111"; -- Biru
            when others => rgb <= "000000000000"; -- Hitam
        end case;
    end process;

end Behavioral;
