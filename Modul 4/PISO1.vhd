library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity piso_8bit is
    Port ( clk  : in  STD_LOGIC;
           load : in  STD_LOGIC;                      -- Sinyal kontrol muat data (misal dihubungkan ke tombol/switch)
           sw   : in  STD_LOGIC_VECTOR (7 downto 0);  -- Input paralel 8-bit
           sout : out STD_LOGIC );                    -- Output serial ke led(0)
end piso_8bit;

architecture Behavioral of piso_8bit is
    -- Register internal untuk menyimpan dan menggeser data
    signal shift_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
                -- Memuat data 8-bit secara paralel dari sw ke register
                shift_reg <= sw;
            else
                -- Menggeser data ke kiri (Shift Left)
                -- Bit 6 s.d. 0 bergeser ke posisi 7 s.d. 1
                shift_reg(7 downto 1) <= shift_reg(6 downto 0);
                -- Bit paling kanan (LSB) diisi dengan '0'
                shift_reg(0) <= '0';
            end if;
        end if;
    end process;

    -- Output serial secara kontinu mengambil bit paling kiri (MSB) dari register
    sout <= shift_reg(7);

end Behavioral;