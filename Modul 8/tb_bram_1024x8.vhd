library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_bram_1024x8 is
-- Testbench tidak memiliki port eksternal
end tb_bram_1024x8;

architecture Behavioral of tb_bram_1024x8 is
    -- Pemanggilan Komponen bram_1024x8
    component bram_1024x8
        Port (
            clk  : in  STD_LOGIC;
            we   : in  STD_LOGIC;
            addr : in  STD_LOGIC_VECTOR (9 downto 0); -- Disesuaikan jadi 10 bit
            din  : in  STD_LOGIC_VECTOR (7 downto 0);
            dout : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    signal clk  : STD_LOGIC := '0';
    signal we   : STD_LOGIC := '0';
    signal addr : STD_LOGIC_VECTOR(9 downto 0) := (others => '0'); -- 10 bit
    signal din  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal dout : STD_LOGIC_VECTOR(7 downto 0);

    constant clk_period : time := 10 ns;

begin
    -- Instansiasi UUT
    uut: bram_1024x8 Port Map (
        clk  => clk,
        we   => we,
        addr => addr,
        din  => din,
        dout => dout
    );

    -- Clock Process (100 MHz)
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        wait for clk_period * 2;

        -- 1. Penulisan Data ke Alamat Rendah dan Alamat Tinggi (>255)
        we <= '1';
        
        addr <= "0000000001"; din <= x"AB"; wait for clk_period; -- Alamat 1
        addr <= "0011111111"; din <= x"CD"; wait for clk_period; -- Alamat 255
        addr <= "1111111111"; din <= x"55"; wait for clk_period; -- Alamat 1023 (Alamat Maksimal)
        
        we <= '0';
        wait for clk_period;

        -- 2. Pembacaan dan Verifikasi Data
        addr <= "0000000001"; wait for clk_period * 2;
        assert (dout = x"AB") report "ERR: Alamat 1 tidak cocok!" severity failure;

        addr <= "0011111111"; wait for clk_period * 2;
        assert (dout = x"CD") report "ERR: Alamat 255 tidak cocok!" severity failure;

        addr <= "1111111111"; wait for clk_period * 2;
        assert (dout = x"55") report "ERR: Alamat 1023 tidak cocok!" severity failure;

        report "SIMULASI BRAM 1024x8 SUKSES!" severity note;
        wait;
    end process;

end Behavioral;