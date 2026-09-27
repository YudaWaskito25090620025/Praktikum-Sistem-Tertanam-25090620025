library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity piso_8bit_slow is
    Port ( clk  : in  STD_LOGIC;                      -- Clock 100 MHz dari Basys 3 (Pin W5)
           load : in  STD_LOGIC;                      -- Tombol btnC
           sw   : in  STD_LOGIC_VECTOR (7 downto 0);  -- Input switch 8-bit
           sout : out STD_LOGIC );                    -- Output ke led(0)
end piso_8bit_slow;

architecture Behavioral of piso_8bit_slow is
    -- Sinyal untuk Clock Divider
    -- Untuk membagi 100 MHz menjadi 1 Hz, kita menghitung sampai 50.000.000 (siklus 50%)
    signal counter : integer range 0 to 49999999 := 0;
    signal clk_1Hz : STD_LOGIC := '0';

    -- Sinyal internal untuk register PISO
    signal shift_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
begin

    -- Proses 1: Clock Divider (Membagi 100 MHz menjadi 1 Hz)
    process(clk)
    begin
        if rising_edge(clk) then
            if counter = 49999999 then
                counter <= 0;
                clk_1Hz <= not clk_1Hz; -- Toggle status clock setiap 0.5 detik (total periode 1 detik)
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Proses 2: Shift Register menggunakan clock lambat (1 Hz)
    process(clk_1Hz)
    begin
        if rising_edge(clk_1Hz) then
            if load = '1' then
                -- Load data dari switch secara paralel
                shift_reg <= sw;
            else
                -- Geser data (Shift Left) satu per satu
                shift_reg(7 downto 1) <= shift_reg(6 downto 0);
                shift_reg(0) <= '0';
            end if;
        end if;
    end process;

    -- Output serial
    sout <= shift_reg(7);

end Behavioral;