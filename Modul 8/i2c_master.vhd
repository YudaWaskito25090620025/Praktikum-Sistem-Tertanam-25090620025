library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_master is
    Generic (
        INPUT_CLK : integer := 100_000_000; -- 100 MHz
        BUS_CLK   : integer := 100_000      -- 100 kHz I2C SCL
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
end i2c_master;

architecture Behavioral of i2c_master is
    constant DIVIDER : integer := (INPUT_CLK / BUS_CLK) / 4;
    
    type i2c_state is (S_IDLE, S_START, S_ADDR, S_ADDR_ACK, S_DATA, S_DATA_ACK, S_STOP);
    signal state : i2c_state := S_IDLE;

    signal clk_count : integer range 0 to DIVIDER*4 := 0;
    signal data_clk  : STD_LOGIC := '0';
    signal scl_ena   : STD_LOGIC := '0';
    
    signal sda_i     : STD_LOGIC := '1';
    signal sda_ena   : STD_LOGIC := '0';
    
    signal addr_rw   : STD_LOGIC_VECTOR(7 downto 0);
    signal data_tx   : STD_LOGIC_VECTOR(7 downto 0);
    signal bit_cnt   : integer range 0 to 7 := 7;

begin
    -- Pembangkit Clock Divider I2C
    process(clk, reset)
    begin
        if reset = '1' then
            clk_count <= 0;
            data_clk <= '0';
        elsif rising_edge(clk) then
            if clk_count = DIVIDER*4 - 1 then
                clk_count <= 0;
            else
                clk_count <= clk_count + 1;
            end if;
            
            if clk_count < DIVIDER*2 then
                data_clk <= '1';
            else
                data_clk <= '0';
            end if;
        end if;
    end process;

    -- Kontrol SCL (Open-Drain Driver)
    scl <= '0' when (scl_ena = '1' and data_clk = '0') else 'Z';

    -- Kontrol SDA (Tri-State Driver)
    sda <= '0' when (sda_ena = '1' and sda_i = '0') else 'Z';

    -- Mesin State FSM I2C
    process(clk, reset)
    begin
        if reset = '1' then
            state <= S_IDLE;
            busy <= '0';
            scl_ena <= '0';
            sda_ena <= '0';
            sda_i <= '1';
            ack_error <= '0';
            bit_cnt <= 7;
        elsif rising_edge(clk) then
            if clk_count = DIVIDER - 1 then -- Transisi pada quarter-cycle
                case state is
                    when S_IDLE =>
                        busy <= '0';
                        scl_ena <= '0';
                        sda_ena <= '1';
                        sda_i <= '1';
                        if ena = '1' then
                            busy <= '1';
                            addr_rw <= addr & rw;
                            data_tx <= data_wr;
                            state <= S_START;
                        end if;

                    when S_START =>
                        sda_i <= '0'; -- Kondisi START (SDA turun saat SCL tinggi)
                        scl_ena <= '1';
                        bit_cnt <= 7;
                        state <= S_ADDR;

                    when S_ADDR =>
                        sda_i <= addr_rw(bit_cnt);
                        if bit_cnt = 0 then
                            state <= S_ADDR_ACK;
                        else
                            bit_cnt <= bit_cnt - 1;
                        end if;

                    when S_ADDR_ACK =>
                        sda_ena <= '0'; -- Pelepasan SDA untuk membaca ACK dari slave
                        bit_cnt <= 7;
                        if sda = '0' then
                            ack_error <= '0';
                            state <= S_DATA;
                        else
                            ack_error <= '1';
                            state <= S_STOP;
                        end if;

                    when S_DATA =>
                        sda_ena <= '1';
                        sda_i <= data_tx(bit_cnt);
                        if bit_cnt = 0 then
                            state <= S_DATA_ACK;
                        else
                            bit_cnt <= bit_cnt - 1;
                        end if;

                    when S_DATA_ACK =>
                        sda_ena <= '0'; -- Pelepasan SDA untuk membaca ACK
                        if sda /= '0' then
                            ack_error <= '1';
                        end if;
                        state <= S_STOP;

                    when S_STOP =>
                        sda_ena <= '1';
                        sda_i <= '0';
                        if data_clk = '1' then
                            sda_i <= '1'; -- Kondisi STOP (SDA naik saat SCL tinggi)
                            state <= S_IDLE;
                        end if;

                    when others =>
                        state <= S_IDLE;
                end case;
            end if;
        end if;
    end process;

end Behavioral;