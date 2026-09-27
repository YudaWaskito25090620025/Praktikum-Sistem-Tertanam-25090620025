library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_synchronizer is
    Port ( clk  : in STD_LOGIC;   -- Pin W5 (100 MHz)
           btnC : in STD_LOGIC;   -- Input asinkron dari tombol
           led  : out STD_LOGIC_VECTOR(0 downto 0)); -- LED 0
end top_synchronizer;

architecture Behavioral of top_synchronizer is
    component synchronizer_2ff
        Port ( clk      : in STD_LOGIC;
               async_in : in STD_LOGIC;
               sync_out : out STD_LOGIC);
    end component;

    signal sync_out_sig  : std_logic;
    signal sync_out_prev : std_logic := '0';
    signal led_state     : std_logic := '0';
begin
    -- Instansiasi Synchronizer
    UUT: synchronizer_2ff port map(
        clk => clk,
        async_in => btnC,
        sync_out => sync_out_sig
    );

    -- Process untuk deteksi transisi dan toggle LED
    process(clk)
    begin
        if rising_edge(clk) then
            -- Register pembanding nilai sebelumnya
            sync_out_prev <= sync_out_sig; 
            
            -- Deteksi transisi naik (dari '0' ke '1')
            if (sync_out_prev = '0' and sync_out_sig = '1') then
                led_state <= not led_state; -- Toggle LED
            end if;
        end if;
    end process;

    led(0) <= led_state;
end Behavioral;