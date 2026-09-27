library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_piso_8bit_slow is
-- Testbench kosong
end tb_piso_8bit_slow;

architecture behavior of tb_piso_8bit_slow is
    -- Panggil modul utama
    component piso_8bit_slow
    Port ( clk  : in  STD_LOGIC;
           load : in  STD_LOGIC;
           sw   : in  STD_LOGIC_VECTOR (7 downto 0);
           sout : out STD_LOGIC );
    end component;

    signal clk  : std_logic := '0';
    signal load : std_logic := '0';
    signal sw   : std_logic_vector(7 downto 0) := (others => '0');
    signal sout : std_logic;

    -- Clock Basys 3 adalah 100 MHz (periode 10 ns)
    constant clk_period : time := 10 ns; 

begin
    -- Instansiasi
    uut: piso_8bit_slow PORT MAP (
          clk  => clk,
          load => load,
          sw   => sw,
          sout => sout
        );

    -- Bangkitkan clock 100 MHz
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Proses tes
    stim_proc: process
    begin
        wait for 40 ns;

        -- 1. Berikan data paralel
        sw <= "10101100";
        
        -- 2. Tekan tombol load
        load <= '1';
        -- Tahan agak lama agar clock divider yang lambat sempat merespons
        wait for clk_period * 20; 
        
        -- 3. Lepas tombol load, biarkan bergeser
        load <= '0';
        
        -- Tunggu proses geser (waktu tunggu disesuaikan dengan nilai counter simulasi)
        wait for clk_period * 200;
        
        wait;
    end process;
end behavior;