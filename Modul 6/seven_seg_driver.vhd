library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Driver 4 digit seven-segment Basys 3 (common anode, aktif-rendah), tampil heksadesimal
entity seven_seg_driver is
    Port (
        clk  : in  STD_LOGIC;
        data : in  STD_LOGIC_VECTOR (15 downto 0);
        seg  : out STD_LOGIC_VECTOR (6 downto 0); -- seg(0)=CA ... seg(6)=CG
        an   : out STD_LOGIC_VECTOR (3 downto 0);
        dp   : out STD_LOGIC
    );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is
    signal refresh : unsigned(17 downto 0) := (others => '0');
    signal sel     : unsigned(1 downto 0);
    signal nibble  : STD_LOGIC_VECTOR (3 downto 0);
begin
    process (clk)
    begin
        if rising_edge(clk) then
            refresh <= refresh + 1;
        end if;
    end process;
    sel <= refresh(17 downto 16);

    process (sel, data)
    begin
        case sel is
            when "00"   => an <= "1110"; nibble <= data(3 downto 0);
            when "01"   => an <= "1101"; nibble <= data(7 downto 4);
            when "10"   => an <= "1011"; nibble <= data(11 downto 8);
            when others => an <= "0111"; nibble <= data(15 downto 12);
        end case;
    end process;

    process (nibble)
    begin
        case nibble is            -- gfedcba, aktif rendah
            when x"0" => seg <= "1000000";
            when x"1" => seg <= "1111001";
            when x"2" => seg <= "0100100";
            when x"3" => seg <= "0110000";
            when x"4" => seg <= "0011001";
            when x"5" => seg <= "0010010";
            when x"6" => seg <= "0000010";
            when x"7" => seg <= "1111000";
            when x"8" => seg <= "0000000";
            when x"9" => seg <= "0010000";
            when x"A" => seg <= "0001000";
            when x"B" => seg <= "0000011";
            when x"C" => seg <= "1000110";
            when x"D" => seg <= "0100001";
            when x"E" => seg <= "0000110";
            when others => seg <= "0001110";
        end case;
    end process;
    dp <= '1';
end Behavioral;
