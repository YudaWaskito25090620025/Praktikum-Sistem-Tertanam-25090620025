library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Generic (
        DIGITS : integer := 4
    );
    Port (
        clk  : in  STD_LOGIC;
        data : in  STD_LOGIC_VECTOR(15 downto 0); -- 4 digit x 4-bit BCD/Hex
        seg  : out STD_LOGIC_VECTOR(6 downto 0);  -- Segmen gfedcba (aktif rendah)
        dp   : out STD_LOGIC;                     -- Titik desimal
        an   : out STD_LOGIC_VECTOR(3 downto 0)   -- Anoda digit (aktif rendah)
    );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is 
    -- Fungsi konversi BCD ke pola Seven-Segment (aktif rendah)
    function bcd_to_seg(digit : unsigned(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case digit is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when others => return "0111111"; -- '-'
        end case;
    end function;

    -- Pencacah pembagi clock (~1 kHz refresh digit)
    signal refresh_counter : unsigned(16 downto 0) := (others => '0');
    signal digit_select    : unsigned(1 downto 0) := "00";
    signal current_digit   : unsigned(3 downto 0);

begin
    dp <= '1'; -- Matikan titik desimal (aktif rendah)

    process(clk)
    begin
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    -- Ambil 2 bit teratas pembagi clock untuk memilih digit aktif
    digit_select <= refresh_counter(16 downto 15);

    -- Proses Multiplexing Anoda dan Pemilihan Data Digit
    process(digit_select, data)
    begin
        case digit_select is
            when "00" =>
                an <= "1110"; -- Digit 0 (Paling Kanan)
                current_digit <= unsigned(data(3 downto 0));
            when "01" =>
                an <= "1101"; -- Digit 1
                current_digit <= unsigned(data(7 downto 4));
            when "10" =>
                an <= "1011"; -- Digit 2
                current_digit <= unsigned(data(11 downto 8));
            when "11" =>
                an <= "0111"; -- Digit 3 (Paling Kiri)
                current_digit <= unsigned(data(15 downto 12));
            when others =>
                an <= "1111";
                current_digit <= "0000";
        end case;
    end process;

    -- Tampilkan pola ke segmen
    seg <= bcd_to_seg(current_digit);

end Behavioral;