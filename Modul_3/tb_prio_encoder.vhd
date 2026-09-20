library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_top_encoder is
-- Testbench tidak memiliki port
end tb_top_encoder;

architecture behavior of tb_top_encoder is
    -- Memanggil modul top_encoder
    component top_encoder
        Port ( sw  : in  STD_LOGIC_VECTOR (7 downto 0);
               led : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    -- Sinyal internal simulasi
    signal tb_sw  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal tb_led : STD_LOGIC_VECTOR (3 downto 0);

begin
    -- Mapping port
    UUT: top_encoder port map (
        sw  => tb_sw,
        led => tb_led
    );

    -- Proses pemberian input sakelar
    stim_proc: process
    begin
        wait for 10 ns;

        -- Kasus 1: Semua sakelar mati
        tb_sw <= "00000000";
        wait for 10 ns;
        -- Hasil: led(3) mati (tidak valid). led = "0000"

        -- Kasus 2: Sakelar paling kiri (indeks 7) aktif
        tb_sw <= "10000000";
        wait for 10 ns;
        -- Hasil: led(3) menyala (valid). Posisi 7 (111). led = "1111"

        -- Kasus 3: Sakelar indeks 5 aktif, bersamaan dengan sakelar 0, 1, 2
        tb_sw <= "00100111";
        wait for 10 ns;
        -- Hasil: Prioritas ada di indeks 5. Posisi 5 (101). led = "1101"

        -- Kasus 4: Hanya sakelar paling kanan (indeks 0) yang aktif
        tb_sw <= "00000001";
        wait for 10 ns;
        -- Hasil: led(3) menyala (valid). Posisi 0 (000). led = "1000"

        wait;
    end process;
end behavior;