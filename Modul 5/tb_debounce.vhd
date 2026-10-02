library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debounce is
-- Testbench tidak memiliki port
end tb_debounce;

architecture Behavioral of tb_debounce is
    component debounce is
        Generic (
            CLK_FREQ_HZ : integer := 100_000_000;
            STABLE_MS   : integer := 10
        );
        Port (
            clk     : in  STD_LOGIC;
            btn_in  : in  STD_LOGIC;
            btn_out : out STD_LOGIC
        );
    end component;

    -- Signal internal
    signal clk     : STD_LOGIC := '0';
    signal btn_in  : STD_LOGIC := '0';
    signal btn_out : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns; -- Clock 100 MHz
begin
    -- Instansiasi UUT (Unit Under Test) dengan STABLE_MS kecil agar simulasi cepat
    uut: debounce
        generic map (
            CLK_FREQ_HZ => 100_000_000,
            STABLE_MS   => 1 
        )
        port map (
            clk     => clk,
            btn_in  => btn_in,
            btn_out => btn_out
        );

    -- Pembangkit Clock 100 MHz
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus Simulasi (Simulasi Tombol Bouncing)
    stim_proc: process
    begin
        wait for 100 ns;
        
        -- Simulasi Penekanan Tombol (Bouncing)
        btn_in <= '1'; wait for 50 us;
        btn_in <= '0'; wait for 30 us;
        btn_in <= '1'; wait for 40 us;
        btn_in <= '0'; wait for 20 us;
        
        -- Masukan stabil '1' selama lebih dari 1 ms
        btn_in <= '1'; wait for 2 ms;
        
        -- Simulasi Pelepasan Tombol (Bouncing)
        btn_in <= '0'; wait for 40 us;
        btn_in <= '1'; wait for 30 us;
        
        -- Masukan stabil '0'
        btn_in <= '0'; wait for 2 ms;

        wait;
    end process;
end Behavioral;