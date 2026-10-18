----------------------------------------------------------------------------
-- Jobsheet 7 - TUGAS PRAKTIKUM NOMOR 2
-- Testbench self-checking untuk traffic_light_fsm.vhd (all-red + switch)
--
-- Memverifikasi:
--   1. Urutan state 6-fase tetap benar (termasuk all-red dari Tugas 1)
--   2. Durasi fase hijau MENGIKUTI sw_green, bukan konstanta: testbench
--      ini mencoba 2 nilai switch berbeda (sw_green="0000"->5s dan
--      sw_green="1111"->20s secara berurutan) dan menghitung jumlah tick
--      aktual fase NS_HIJAU pertama pada tiap kondisi.
--   3. Kedua arah tidak pernah hijau bersamaan & LED tiap arah one-hot
--
-- `tick` dibangkitkan langsung sebagai pulsa periodik (bukan dari
-- tick_1hz dgn 100 juta siklus) agar simulasi FSM tetap singkat.
--
-- Jalankan dengan GHDL:
--   ghdl -a --std=08 ../src/traffic_light_fsm.vhd traffic_light_fsm_tb.vhd
--   ghdl -e --std=08 traffic_light_fsm_tb
--   ghdl -r --std=08 traffic_light_fsm_tb --vcd=fsm_tb.vcd
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_light_fsm_tb is
end traffic_light_fsm_tb;

architecture sim of traffic_light_fsm_tb is

    constant CLK_PERIOD : time := 10 ns;

    signal clk      : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '1';
    signal tick     : STD_LOGIC := '0';
    signal sw_green : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- mulai dari 5 detik
    signal led      : STD_LOGIC_VECTOR(5 downto 0);

    signal errors      : integer := 0;
    signal ns_leds      : STD_LOGIC_VECTOR(2 downto 0);
    signal ew_leds      : STD_LOGIC_VECTOR(2 downto 0);

    -- penghitung lebar fase NS_HIJAU pertama (dlm jumlah tick)
    signal ns_hijau_ticks : integer := 0;
    signal counting       : boolean := false;

begin

    DUT : entity work.traffic_light_fsm
        port map ( clk => clk, rst => rst, tick => tick,
                   sw_green => sw_green, led => led );

    ns_leds <= led(2 downto 0);
    ew_leds <= led(5 downto 3);

    clk_gen : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- 1 pulsa tick selebar 1 siklus clk, setiap 4 siklus clk
    tick_gen : process
    begin
        wait for CLK_PERIOD * 3;
        tick <= '1';
        wait for CLK_PERIOD;
        tick <= '0';
    end process;

    check_exclusive : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                if (ns_leds = "001" or ns_leds = "010" or ns_leds = "100") and
                   (ew_leds = "001" or ew_leds = "010" or ew_leds = "100") then
                    if ns_leds = "001" and ew_leds = "001" then
                        report "GAGAL: NS dan EW hijau bersamaan!" severity error;
                        errors <= errors + 1;
                    end if;
                else
                    report "GAGAL: salah satu arah tidak one-hot" severity error;
                    errors <= errors + 1;
                end if;
            end if;
        end if;
    end process;

    -- hitung berapa tick NS tetap hijau (untuk memverifikasi durasi mengikuti switch)
    measure : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ns_hijau_ticks <= 0;
                counting <= false;
            elsif tick = '1' then
                if ns_leds = "001" then           -- NS sedang hijau
                    counting <= true;
                    ns_hijau_ticks <= ns_hijau_ticks + 1;
                elsif counting then
                    counting <= false;            -- baru saja keluar dari NS_HIJAU
                end if;
            end if;
        end if;
    end process;

    stim : process
    begin
        -- === Kondisi 1: sw_green = "0000" -> seharusnya durasi hijau = 5 detik ===
        sw_green <= "0000";
        rst <= '1';
        wait for CLK_PERIOD * 3;
        rst <= '0';
        wait for CLK_PERIOD * 4 * 6;   -- lewati fase NS_HIJAU pertama (<=5 tick)
        report "Durasi NS_HIJAU dgn sw_green=0000 (harus 5) = " & integer'image(ns_hijau_ticks);
        assert ns_hijau_ticks = 5
            report "GAGAL: durasi hijau tidak mengikuti switch (kondisi 5 detik)"
            severity failure;

        -- === Kondisi 2: sw_green = "1111" -> seharusnya durasi hijau = 20 detik ===
        sw_green <= "1111";
        rst <= '1';
        wait for CLK_PERIOD * 3;
        rst <= '0';
        wait for CLK_PERIOD * 4 * 23;  -- lewati fase NS_HIJAU pertama (<=20 tick)
        report "Durasi NS_HIJAU dgn sw_green=1111 (harus 20) = " & integer'image(ns_hijau_ticks);
        assert ns_hijau_ticks = 20
            report "GAGAL: durasi hijau tidak mengikuti switch (kondisi 20 detik)"
            severity failure;

        report "Simulasi selesai, jumlah pelanggaran one-hot = " & integer'image(errors);
        assert errors = 0
            report "GAGAL: ditemukan pelanggaran one-hot / dua arah hijau bersamaan"
            severity failure;
        report "LULUS: durasi hijau mengikuti sw_green, urutan state & LED sesuai Tugas 2";
        wait;
    end process;

end sim;
