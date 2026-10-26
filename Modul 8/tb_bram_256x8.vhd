library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_bram_256x8 is
-- Testbench tidak memiliki port external
end tb_bram_256x8;

architecture Behavioral of tb_bram_256x8 is
    component bram_256x8
        Port (
            clk  : in  STD_LOGIC;
            we   : in  STD_LOGIC;
            addr : in  STD_LOGIC_VECTOR (7 downto 0);
            din  : in  STD_LOGIC_VECTOR (7 downto 0);
            dout : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    signal clk  : STD_LOGIC := '0';
    signal we   : STD_LOGIC := '0';
    signal addr : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal din  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal dout : STD_LOGIC_VECTOR(7 downto 0);

    constant clk_period : time := 10 ns;

begin
    -- Instansiasi Unit Under Test (UUT)
    uut: bram_256x8 Port Map (
        clk  => clk,
        we   => we,
        addr => addr,
        din  => din,
        dout => dout
    );

    -- Pembangkitan Clock (100 MHz)
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Proses Stimulus
    stim_proc: process
    begin
        wait for clk_period * 2;

        -- 1. Penulisan Data
        we <= '1';
        
        addr <= x"01"; din <= x"AB"; wait for clk_period;
        addr <= x"02"; din <= x"CD"; wait for clk_period;
        addr <= x"0F"; din <= x"55"; wait for clk_period;
        
        we <= '0';
        wait for clk_period;

        -- 2. Pembacaan dan Verifikasi
        addr <= x"01"; wait for clk_period * 2;
        assert (dout = x"AB") report "ERR: Alamat 0x01 tidak cocok!" severity failure;

        addr <= x"02"; wait for clk_period * 2;
        assert (dout = x"CD") report "ERR: Alamat 0x02 tidak cocok!" severity failure;

        addr <= x"0F"; wait for clk_period * 2;
        assert (dout = x"55") report "ERR: Alamat 0x0F tidak cocok!" severity failure;

        report "SIMULASI BRAM SUKSES! Seluruh data terverifikasi." severity note;
        wait;
    end process;

end Behavioral;