library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_leading_one_detector is
-- Testbench tidak memiliki port
end tb_leading_one_detector;

architecture behavior of tb_leading_one_detector is

    -- Deklarasi komponen yang akan diuji (Unit Under Test)
    component leading_one_detector
    Generic (WIDTH: integer := 8);
    Port (
        din   : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        pos   : out STD_LOGIC_VECTOR (2 downto 0);
        valid : out STD_LOGIC
    );
    end component;

    -- Sinyal internal untuk menyambungkan testbench ke komponen
    signal tb_din   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tb_pos   : STD_LOGIC_VECTOR(2 downto 0);
    signal tb_valid : STD_LOGIC;

begin

    -- Menyambungkan sinyal testbench ke port komponen
    uut: leading_one_detector
    generic map (WIDTH => 8)
    port map (
        din   => tb_din,
        pos   => tb_pos,
        valid => tb_valid
    );

    -- Proses untuk memberikan input (stimulus)
    stim_proc: process
    begin
        wait for 10 ns; -- Jeda awal

        -- Kasus 1: Tidak ada bit '1' sama sekali
        tb_din <= "00000000";
        wait for 10 ns;
        assert (tb_pos = "000" and tb_valid = '0')
        report "GAGAL Kasus 1: Input 00000000" severity error;

        -- Kasus 2: Bit '1' pertama ada di ujung paling kiri (indeks 7)
        tb_din <= "10000000";
        wait for 10 ns;
        assert (tb_pos = "111" and tb_valid = '1')
        report "GAGAL Kasus 2: Input 10000000" severity error;

        -- Kasus 3: Bit '1' pertama ada di tengah (indeks 5)
        tb_din <= "00100111";
        wait for 10 ns;
        assert (tb_pos = "101" and tb_valid = '1')
        report "GAGAL Kasus 3: Input 00100111" severity error;

        -- Kasus 4: Bit '1' pertama ada di ujung paling kanan (indeks 0)
        tb_din <= "00000001";
        wait for 10 ns;
        assert (tb_pos = "000" and tb_valid = '1')
        report "GAGAL Kasus 4: Input 00000001" severity error;

        -- Kasus 5: Banyak bit '1', sistem harus mendeteksi yang paling kiri (indeks 6)
        tb_din <= "01111111";
        wait for 10 ns;
        assert (tb_pos = "110" and tb_valid = '1')
        report "GAGAL Kasus 5: Input 01111111" severity error;

        -- Pesan ini hanya akan muncul jika semua pengujian di atas berhasil
        report "Simulasi selesai! Jika tidak ada pesan GAGAL (error) di atas, berarti rangkaian Anda sudah benar." severity note;
        
        wait; -- Menghentikan proses agar tidak looping
    end process;

end behavior;