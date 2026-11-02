library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fixed_mul_4bit_sw is
    Port ( clk : in  STD_LOGIC;
           sw  : in  STD_LOGIC_VECTOR (7 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           dp  : out STD_LOGIC;
           an  : out STD_LOGIC_VECTOR (3 downto 0) );
end fixed_mul_4bit_sw;

architecture Behavioral of fixed_mul_4bit_sw is

    -- a = sw(7..4), b = sw(3..0), format Q2.2 (4-bit unsigned)
    signal a, b      : unsigned(3 downto 0);
    signal product   : unsigned(7 downto 0); -- Q4.4

    signal int_part  : unsigned(3 downto 0);
    signal frac_part : unsigned(3 downto 0);

    signal tens_digit, ones_digit, tenths_digit : unsigned(3 downto 0);

    signal refresh_cnt : unsigned(17 downto 0) := (others => '0');
    signal digit_sel    : STD_LOGIC_VECTOR(1 downto 0);

    signal digit_value  : unsigned(3 downto 0);
    signal seg_i        : STD_LOGIC_VECTOR(6 downto 0);

begin

    -----------------------------------------------------------------
    -- Perkalian fixed-point 4-bit x 4-bit
    -----------------------------------------------------------------
    a <= unsigned(sw(7 downto 4));
    b <= unsigned(sw(3 downto 0));
    product <= a * b;

    int_part  <= product(7 downto 4);
    frac_part <= product(3 downto 0);

    -----------------------------------------------------------------
    -- Pemisahan digit puluhan / satuan / persepuluhan
    -----------------------------------------------------------------
    process(clk)
        variable frac_x10 : unsigned(7 downto 0);
    begin
        if rising_edge(clk) then
            tens_digit <= to_unsigned((to_integer(int_part) / 10) mod 10, 4);
            ones_digit <= to_unsigned(to_integer(int_part) mod 10, 4);
            frac_x10 := frac_part * to_unsigned(10, 4);
            tenths_digit <= frac_x10(7 downto 4);
        end if;
    end process;

    -----------------------------------------------------------------
    -- Pembagi clock + pencacah pemilih digit
    -----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            refresh_cnt <= refresh_cnt + 1;
        end if;
    end process;

    digit_sel <= std_logic_vector(refresh_cnt(17 downto 16));

    -----------------------------------------------------------------
    -- Pemilihan anode & nilai digit yang ditampilkan
    -----------------------------------------------------------------
    process(digit_sel, tens_digit, ones_digit, tenths_digit)
    begin
        case digit_sel is
            when "00" =>
                an <= "1110";
                digit_value <= tenths_digit;
                dp <= '1';
            when "01" =>
                an <= "1101";
                digit_value <= ones_digit;
                dp <= '0';
            when "10" =>
                an <= "1011";
                digit_value <= tens_digit;
                dp <= '1';
            when others =>
                an <= "0111";
                digit_value <= "0000";
                dp <= '1';
        end case;
    end process;

    -----------------------------------------------------------------
    -- Dekoder BCD ke 7-segmen
    -----------------------------------------------------------------
    process(digit_value)
    begin
        case to_integer(digit_value) is
            when 0 => seg_i <= "1000000";
            when 1 => seg_i <= "1111001";
            when 2 => seg_i <= "0100100";
            when 3 => seg_i <= "0110000";
            when 4 => seg_i <= "0011001";
            when 5 => seg_i <= "0010010";
            when 6 => seg_i <= "0000010";
            when 7 => seg_i <= "1111000";
            when 8 => seg_i <= "0000000";
            when 9 => seg_i <= "0010000";
            when others => seg_i <= "1111111";
        end case;
    end process;

    seg <= seg_i;

end Behavioral;
