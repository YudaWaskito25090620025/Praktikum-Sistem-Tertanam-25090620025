----------------------------------------------------------------------------
-- Jobsheet 7 - Testbench untuk tick_1hz.vhd (Prosedur Praktikum butir 2)
--
-- CLK_FREQ_HZ diperkecil menjadi 10 (bukan 100_000_000) khusus untuk
-- simulasi, sesuai saran modul, supaya periode tick dapat diverifikasi
-- tanpa simulasi yang memakan waktu lama. Clock simulasi dibuat dengan
-- periode 10 ns, sehingga tick seharusnya muncul setiap 10 x 10 ns = 100 ns
-- (1 siklus tinggi, lebar 1 periode clk).
--
-- Jalankan dengan GHDL, contoh:
--   ghdl -a --std=08 ../src/tick_1hz.vhd tick_1hz_tb.vhd
--   ghdl -e --std=08 tick_1hz_tb
--   ghdl -r --std=08 tick_1hz_tb --vcd=tick_1hz_tb.vcd --stop-time=500ns
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;

entity tick_1hz_tb is
end tick_1hz_tb;

architecture sim of tick_1hz_tb is

    constant CLK_PERIOD   : time    := 10 ns;
    constant SIM_DIVISOR  : integer := 10;   -- generic CLK_FREQ_HZ yang diperkecil

    signal clk        : STD_LOGIC := '0';
    signal rst         : STD_LOGIC := '1';
    signal tick         : STD_LOGIC;

    signal tick_count   : integer := 0;
    signal last_tick_t  : time    := 0 ns;
    signal period_ok     : boolean := true;

begin

    -- DUT (Device Under Test)
    DUT : entity work.tick_1hz
        generic map ( CLK_FREQ_HZ => SIM_DIVISOR )
        port map ( clk => clk, rst => rst, tick => tick );

    -- Pembangkit clock
    clk_gen : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- Stimulus: lepas reset setelah beberapa siklus, lalu biarkan berjalan
    stim : process
    begin
        rst <= '1';
        wait for CLK_PERIOD * 3;
        rst <= '0';
        wait for CLK_PERIOD * (SIM_DIVISOR * 8);   -- amati +/- 8 periode tick
        report "Simulasi selesai. Jumlah tick teramati = " &
                integer'image(tick_count);
        assert tick_count >= 7
            report "GAGAL: jumlah tick lebih sedikit dari yang diharapkan"
            severity failure;
        assert period_ok
            report "GAGAL: periode antar-tick tidak konsisten"
            severity failure;
        report "LULUS: tick_1hz menghasilkan pulsa periodik sesuai CLK_FREQ_HZ yang diset";
        wait;
    end process;

    -- Pemeriksa: hitung tick dan cek periode antar-tick = SIM_DIVISOR * CLK_PERIOD
    checker : process(clk)
    begin
        if rising_edge(clk) then
            if tick = '1' then
                if tick_count > 0 then
                    if (now - last_tick_t) /= CLK_PERIOD * SIM_DIVISOR then
                        period_ok <= false;
                    end if;
                end if;
                last_tick_t <= now;
                tick_count  <= tick_count + 1;
            end if;
        end if;
    end process;

end sim;
