----------------------------------------------------------------------------
-- Jobsheet 7 - TUGAS PRAKTIKUM NOMOR 2
-- (dibangun di atas versi Tugas 1, fase all-red sudah termasuk)
-- File   : traffic_light_fsm.vhd
--
-- Tugas Praktikum butir 2:
--   "Ubah rancangan agar durasi fase hijau dapat diatur melalui switch
--    (misalnya sw(3 downto 0) menentukan durasi 5-20 detik), sehingga
--    timer tidak lagi berupa konstanta tetap."
--
-- Dibanding versi Tugas 1 (6-state + all-red, tapi durasi hijau masih
-- konstanta 10 detik), di sini DUR_HIJAU diganti sinyal green_duration
-- yang dibaca langsung dari port sw_green(3 downto 0):
--     sw_green = "0000" (0)  -> green_duration =  5 detik
--     sw_green = "1111" (15) -> green_duration = 20 detik
-- Durasi kuning (3s) & all-red (1s) tetap konstanta -- itu bukan bagian
-- yang diminta Tugas 2.
--
-- Gaya 2-process (sama seperti versi sebelumnya):
--   Process 1 : register state & timer (sequential)
--   Process 2 : next-state & next-timer logic (combinational)
--   Process 3 : decoding keluaran LED (Moore)
--
-- State & urutan (6 state, dari Tugas 1):
--   NS_HIJAU -> NS_KUNING -> ALLRED_1 -> EW_HIJAU -> EW_KUNING -> ALLRED_2 -> (ulang)
--
-- Pemetaan LED (6 bit, sama seperti sebelumnya):
--   led(2 downto 0) -> arah NS : bit0=hijau, bit1=kuning, bit2=merah
--   led(5 downto 3) -> arah EW : bit3=hijau, bit4=kuning, bit5=merah
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;              -- <<< Tugas 2: perlu to_integer/unsigned

entity traffic_light_fsm is
    Port ( clk      : in  STD_LOGIC;
           rst      : in  STD_LOGIC;
           tick     : in  STD_LOGIC;                     -- dari tick_1hz, 1 pulsa/detik
           sw_green : in  STD_LOGIC_VECTOR(3 downto 0);  -- <<< Tugas 2: atur durasi hijau
           led      : out STD_LOGIC_VECTOR(5 downto 0) );
end traffic_light_fsm;

architecture Behavioral of traffic_light_fsm is

    type state_t is (NS_HIJAU, NS_KUNING, ALLRED_1, EW_HIJAU, EW_KUNING, ALLRED_2);
    signal state_reg, state_next : state_t := NS_HIJAU;

    -- Durasi tetap (detik) untuk fase kuning & all-red (bukan bagian Tugas 2)
    constant DUR_KUNING : integer := 3;
    constant DUR_ALLRED : integer := 1;

    -- <<< Tugas 2: durasi fase hijau TIDAK LAGI konstanta, dibaca dari switch
    -- sw_green "0000"->5s ... "1111"->20s  (5 + nilai switch, 0..15)
    signal green_duration : integer range 5 to 20;

    -- Timer internal disimpan sbg (durasi_fase - 1): dikurangi tiap tick='1',
    -- transisi state terjadi saat timer mencapai 0.
    signal timer_reg, timer_next : integer range 0 to 19;

begin

    green_duration <= 5 + to_integer(unsigned(sw_green));   -- <<< Tugas 2

    ------------------------------------------------------------------
    -- Process 1 : register state & timer (sequential)
    ------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_reg <= NS_HIJAU;
                timer_reg <= green_duration - 1;   -- <<< Tugas 2: bukan lagi konstanta
            else
                state_reg <= state_next;
                timer_reg <= timer_next;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Process 2 : next-state & next-timer logic (combinational)
    ------------------------------------------------------------------
    process(state_reg, timer_reg, tick, green_duration)
    begin
        state_next <= state_reg;
        timer_next <= timer_reg;

        if tick = '1' then
            if timer_reg = 0 then
                case state_reg is
                    when NS_HIJAU =>
                        state_next <= NS_KUNING;
                        timer_next <= DUR_KUNING - 1;
                    when NS_KUNING =>
                        state_next <= ALLRED_1;                 -- (dari Tugas 1)
                        timer_next <= DUR_ALLRED - 1;
                    when ALLRED_1 =>                             -- (dari Tugas 1)
                        state_next <= EW_HIJAU;
                        timer_next <= green_duration - 1;        -- <<< Tugas 2
                    when EW_HIJAU =>
                        state_next <= EW_KUNING;
                        timer_next <= DUR_KUNING - 1;
                    when EW_KUNING =>
                        state_next <= ALLRED_2;                  -- (dari Tugas 1)
                        timer_next <= DUR_ALLRED - 1;
                    when ALLRED_2 =>                              -- (dari Tugas 1)
                        state_next <= NS_HIJAU;
                        timer_next <= green_duration - 1;        -- <<< Tugas 2
                end case;
            else
                timer_next <= timer_reg - 1;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Process 3 : decoding keluaran LED (Moore, hanya dari state_reg)
    ------------------------------------------------------------------
    process(state_reg)
    begin
        case state_reg is
            when NS_HIJAU  => led <= "100" & "001";  -- EW merah | NS hijau
            when NS_KUNING => led <= "100" & "010";  -- EW merah | NS kuning
            when ALLRED_1  => led <= "100" & "100";  -- EW merah | NS merah
            when EW_HIJAU  => led <= "001" & "100";  -- EW hijau | NS merah
            when EW_KUNING => led <= "010" & "100";  -- EW kuning| NS merah
            when ALLRED_2  => led <= "100" & "100";  -- EW merah | NS merah
        end case;
    end process;

end Behavioral;
