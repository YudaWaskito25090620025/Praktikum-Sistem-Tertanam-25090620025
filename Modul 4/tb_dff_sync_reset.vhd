library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_dff_sync_reset is
-- Testbench tidak memiliki port
end tb_dff_sync_reset;

architecture behavior of tb_dff_sync_reset is
    -- Deklarasi komponen untuk Unit Under Test (UUT)
    component dff_sync_reset
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           d   : in STD_LOGIC;
           q   : out STD_LOGIC);
    end component;

    -- Sinyal internal untuk dihubungkan ke UUT
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal d   : std_logic := '0';
    signal q   : std_logic;

    -- Definisi periode clock (20 ns sesuai modul)
    constant clk_period : time := 20 ns;

begin
    -- Instansiasi UUT
    uut: dff_sync_reset PORT MAP (
          clk => clk,
          rst => rst,
          d => d,
          q => q
        );

    -- Proses pembangkitan sinyal Clock
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Proses stimulus untuk memberi nilai rst dan d
    stim_proc: process
    begin
        -- Tahan reset aktif selama 40 ns
        rst <= '1';
        wait for 40 ns;
        rst <= '0';
        wait for 20 ns;

        -- Variasi input d di waktu sembarang (asinkron terhadap clock)
        d <= '1';
        wait for 15 ns; -- d berubah sebelum tepi naik, lihat apakah q langsung berubah (seharusnya tidak)
        wait for 25 ns;
        
        d <= '0';
        wait for 30 ns;
        
        d <= '1';
        wait for 10 ns;
        
        rst <= '1'; -- Uji reset sinkron saat d = 1
        wait for 30 ns;
        
        wait;
    end process;
end behavior;