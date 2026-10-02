library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js05_top is
    Port (
        clk  : in  STD_LOGIC;
        btnU : in  STD_LOGIC; -- Tombol Up
        btnD : in  STD_LOGIC; -- Tombol Down
        btnC : in  STD_LOGIC; -- Tombol Reset/Center
        seg  : out STD_LOGIC_VECTOR(6 downto 0);
        dp   : out STD_LOGIC;
        an   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end js05_top;

architecture Behavioral of js05_top is

    -- Komponen Debounce
    component debounce is
        Generic ( CLK_FREQ_HZ : integer := 100_000_000; STABLE_MS : integer := 10 );
        Port ( clk : in STD_LOGIC; btn_in : in STD_LOGIC; btn_out : out STD_LOGIC );
    end component;

    -- Komponen Edge Detector
    component edge_detect is
        Port ( clk : in STD_LOGIC; sig_in : in STD_LOGIC; pulse : out STD_LOGIC );
    end component;

    -- Komponen Up/Down Counter
    component updown_counter is
        Port ( clk : in STD_LOGIC; inc : in STD_LOGIC; dec : in STD_LOGIC; reset : in STD_LOGIC; count_o : out STD_LOGIC_VECTOR(15 downto 0) );
    end component;

    -- Komponen Seven Segment Driver
    component seven_seg_driver is
        Generic ( DIGITS : integer := 4 );
        Port ( clk : in STD_LOGIC; data : in STD_LOGIC_VECTOR(15 downto 0); seg : out STD_LOGIC_VECTOR(6 downto 0); dp : out STD_LOGIC; an : out STD_LOGIC_VECTOR(3 downto 0) );
    end component;

    -- Sinyal Antar-Modul
    signal btnU_db, btnD_db, btnC_db : STD_LOGIC;
    signal pulseU, pulseD            : STD_LOGIC;
    signal count_val                 : STD_LOGIC_VECTOR(15 downto 0);

begin

    -- Instansiasi Debouncer untuk ketiga tombol
    db_u : debounce generic map(CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10) port map(clk => clk, btn_in => btnU, btn_out => btnU_db);
    db_d : debounce generic map(CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10) port map(clk => clk, btn_in => btnD, btn_out => btnD_db);
    db_c : debounce generic map(CLK_FREQ_HZ => 100_000_000, STABLE_MS => 10) port map(clk => clk, btn_in => btnC, btn_out => btnC_db);

    -- Instansiasi Edge Detector untuk tombol Up dan Down
    ed_u : edge_detect port map(clk => clk, sig_in => btnU_db, pulse => pulseU);
    ed_d : edge_detect port map(clk => clk, sig_in => btnD_db, pulse => pulseD);

    -- Instansiasi Counter
    counter_inst : updown_counter port map(clk => clk, inc => pulseU, dec => pulseD, reset => btnC_db, count_o => count_val);

    -- Instansiasi Seven Segment Display Driver
    seg_driver_inst : seven_seg_driver generic map(DIGITS => 4) port map(clk => clk, data => count_val, seg => seg, dp => dp, an => an);

end Behavioral;