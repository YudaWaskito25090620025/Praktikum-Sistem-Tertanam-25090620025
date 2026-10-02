library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js05_top is
    Port (
        clk  : in  STD_LOGIC;
        sw   : in  STD_LOGIC_VECTOR(0 downto 0); -- Tambahan untuk Tugas 2 (Freeze/Pause)
        btnU : in  STD_LOGIC;
        btnD : in  STD_LOGIC;
        btnC : in  STD_LOGIC;
        seg  : out STD_LOGIC_VECTOR(6 downto 0);
        dp   : out STD_LOGIC;
        an   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end js05_top;

architecture Behavioral of js05_top is
    signal u_clean, d_clean, rst : STD_LOGIC;
    signal u_pulse, d_pulse      : STD_LOGIC;
    signal inc_en, dec_en        : STD_LOGIC;
    signal count                 : STD_LOGIC_VECTOR(15 downto 0);
begin
    -- Instansiasi Debounce
    deb_u: entity work.debounce port map (clk => clk, btn_in => btnU, btn_out => u_clean);
    deb_d: entity work.debounce port map (clk => clk, btn_in => btnD, btn_out => d_clean);
    deb_c: entity work.debounce port map (clk => clk, btn_in => btnC, btn_out => rst);

    -- Instansiasi Edge Detector
    edge_u: entity work.edge_detect port map (clk => clk, sig_in => u_clean, pulse => u_pulse);
    edge_d: entity work.edge_detect port map (clk => clk, sig_in => d_clean, pulse => d_pulse);

    -- Logika Freeze: Bila sw(0) = '1', pulsa tambah/kurang diabaikan (Freeze)
    inc_en <= u_pulse and (not sw(0));
    dec_en <= d_pulse and (not sw(0));

    -- Instansiasi Up/Down Counter
    cntr: entity work.updown_counter
        port map (clk => clk, rst => rst, inc => inc_en, dec => dec_en, count => count);

    -- Instansiasi Seven Segment Driver (sudah menggunakan hex_to_seg dari Tugas 1)
    disp: entity work.seven_seg_driver
        generic map (DIGITS => 4)
        port map (clk => clk, data => count, seg => seg, dp => dp, an => an);
end Behavioral;