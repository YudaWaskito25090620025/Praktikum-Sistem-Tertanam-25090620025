library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_i2c_master is
-- Testbench
end tb_i2c_master;

architecture Behavioral of tb_i2c_master is
    component i2c_master
        Generic (
            INPUT_CLK : integer := 100_000_000;
            BUS_CLK   : integer := 100_000
        );
        Port (
            clk       : in    STD_LOGIC;
            reset     : in    STD_LOGIC;
            ena       : in    STD_LOGIC;
            addr      : in    STD_LOGIC_VECTOR(6 downto 0);
            rw        : in    STD_LOGIC;
            data_wr   : in    STD_LOGIC_VECTOR(7 downto 0);
            data_rd   : out   STD_LOGIC_VECTOR(7 downto 0);
            busy      : out   STD_LOGIC;
            ack_error : out   STD_LOGIC;
            scl       : inout STD_LOGIC;
            sda       : inout STD_LOGIC
        );
    end component;

    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '1';
    signal ena       : STD_LOGIC := '0';
    signal addr      : STD_LOGIC_VECTOR(6 downto 0) := "1001000"; -- Alamat Slave (0x48)
    signal rw        : STD_LOGIC := '0';                         -- Write mode
    signal data_wr   : STD_LOGIC_VECTOR(7 downto 0) := x"A5";     -- Data dikirim
    signal data_rd   : STD_LOGIC_VECTOR(7 downto 0);
    signal busy      : STD_LOGIC;
    signal ack_error : STD_LOGIC;
    
    signal scl       : STD_LOGIC := 'H'; -- Signal Pull-Up Emulation
    signal sda       : STD_LOGIC := 'H'; -- Signal Pull-Up Emulation

    constant clk_period : time := 10 ns;

begin
    uut: i2c_master
        generic map (
            INPUT_CLK => 100_000_000,
            BUS_CLK   => 1_000_000 -- Dipercepat ke 1 MHz khusus simulasi
        )
        port map (
            clk       => clk,
            reset     => reset,
            ena       => ena,
            addr      => addr,
            rw        => rw,
            data_wr   => data_wr,
            data_rd   => data_rd,
            busy      => busy,
            ack_error => ack_error,
            scl       => scl,
            sda       => sda
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Emulasi Sinyal Slave ACK (Memberikan respons ACK '0' saat master membaca ACK)
    slave_ack_proc: process(scl)
    begin
        -- Tarik SDA ke '0' untuk memberikan sinyal ACK
        if falling_edge(scl) then
            if busy = '1' then
                sda <= '0'; 
            end if;
        end if;
    end process;

    stim_proc: process
    begin
        -- 1. Berikan reset terlebih dahulu
        reset <= '1';
        ena   <= '0';
        wait for 100 ns;
        
        -- 2. Lepas reset
        reset <= '0';
        wait for 100 ns;

        -- 3. Baru picu sinyal enable (ena)
        ena <= '1';
        wait for 500 ns; -- Tahan ena agar FSM sempat membaca kondisi '1'
        ena <= '0';

        wait;
    end process;

end Behavioral;