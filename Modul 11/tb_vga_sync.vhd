library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_vga_sync is
end tb_vga_sync;

architecture sim of tb_vga_sync is

    component vga_sync is
        Port ( pclk     : in  STD_LOGIC;
               rst      : in  STD_LOGIC;
               hsync    : out STD_LOGIC;
               vsync    : out STD_LOGIC;
               video_on : out STD_LOGIC;
               h_count  : out integer range 0 to 799;
               v_count  : out integer range 0 to 524 );
    end component;

    -- Periode pixel clock 25 MHz -> 40 ns
    constant PCLK_PERIOD : time := 40 ns;

    signal pclk     : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '1';
    signal hsync    : STD_LOGIC;
    signal vsync    : STD_LOGIC;
    signal video_on : STD_LOGIC;
    signal h_count  : integer range 0 to 799;
    signal v_count  : integer range 0 to 524;

    -- Parameter acuan (Tabel 11.1), dipakai untuk assert
    constant H_DISPLAY : integer := 640;
    constant H_FPORCH  : integer := 16;
    constant H_SYNC    : integer := 96;
    constant H_TOTAL   : integer := 800;

    constant V_DISPLAY : integer := 480;
    constant V_FPORCH  : integer := 10;
    constant V_SYNC    : integer := 2;
    constant V_TOTAL   : integer := 525;

begin

    DUT: vga_sync
        port map ( pclk     => pclk,
                   rst      => rst,
                   hsync    => hsync,
                   vsync    => vsync,
                   video_on => video_on,
                   h_count  => h_count,
                   v_count  => v_count );

    -- Pembangkit pixel clock
    clk_gen: process
    begin
        pclk <= '0';
        wait for PCLK_PERIOD/2;
        pclk <= '1';
        wait for PCLK_PERIOD/2;
    end process;

    -- Proses reset
    rst_gen: process
    begin
        rst <= '1';
        wait for PCLK_PERIOD*4;
        rst <= '0';
        wait;
    end process;

    -- Proses pemantauan & assert
    check_proc: process
        variable hsync_low_count : integer := 0;
        variable vsync_low_count : integer := 0;
    begin
        wait until rst = '0';
        wait until rising_edge(pclk);

        wait until hsync = '0';
        hsync_low_count := 0;
        while hsync = '0' loop
            hsync_low_count := hsync_low_count + 1;
            wait until rising_edge(pclk);
        end loop;

        assert hsync_low_count = H_SYNC
            report "GAGAL: lebar pulsa HSYNC = " &
                   integer'image(hsync_low_count) &
                   " siklus, seharusnya " & integer'image(H_SYNC)
            severity error;

        if hsync_low_count = H_SYNC then
            report "OK: lebar pulsa HSYNC = " & integer'image(H_SYNC) &
                   " siklus pixel clock (sesuai Tabel 11.1)"
                severity note;
        end if;

        wait until h_count = H_DISPLAY;  -- tepat setelah piksel aktif terakhir
        assert video_on = '0'
            report "GAGAL: video_on masih aktif di luar H_DISPLAY"
            severity error;

        wait until vsync = '0';
        -- lebar pulsa vsync diukur dalam satuan BARIS (bukan pixel clock)
        vsync_low_count := 1;
        while vsync = '0' loop
            wait until (h_count = 0) and rising_edge(pclk);
            if vsync = '0' then
                vsync_low_count := vsync_low_count + 1;
            end if;
        end loop;

        assert vsync_low_count = V_SYNC
            report "GAGAL: lebar pulsa VSYNC = " &
                   integer'image(vsync_low_count) &
                   " baris, seharusnya " & integer'image(V_SYNC)
            severity error;

        if vsync_low_count = V_SYNC then
            report "OK: lebar pulsa VSYNC = " & integer'image(V_SYNC) &
                   " baris horizontal (sesuai Tabel 11.1)"
                severity note;
        end if;

        report "SIMULASI SELESAI: semua assert lolos jika tidak ada pesan GAGAL di atas."
            severity note;

        wait; -- hentikan proses
    end process;

end sim;
