library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Debounce + deteksi tepi naik (Jobsheet 5). Keluaran: pulsa 1 siklus clock.
-- N_STABLE = jumlah clock input harus stabil (1_000_000 = 10 ms @100 MHz)
entity debounce_edge is
    Generic ( N_STABLE : integer := 1_000_000 );
    Port (
        clk   : in  STD_LOGIC;
        btn   : in  STD_LOGIC;
        pulse : out STD_LOGIC
    );
end debounce_edge;

architecture Behavioral of debounce_edge is
    signal sync0, sync1 : STD_LOGIC := '0';
    signal stable, prev : STD_LOGIC := '0';
    signal cnt          : integer range 0 to N_STABLE := 0;
begin
    process (clk)
    begin
        if rising_edge(clk) then
            sync0 <= btn;
            sync1 <= sync0;
            if sync1 = stable then
                cnt <= 0;
            else
                if cnt = N_STABLE - 1 then
                    stable <= sync1;
                    cnt    <= 0;
                else
                    cnt <= cnt + 1;
                end if;
            end if;
            prev <= stable;
        end if;
    end process;
    pulse <= stable and (not prev);
end Behavioral;
