library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_alu_signed is
-- Testbench kosong
end tb_alu_signed;

architecture behavior of tb_alu_signed is
    -- Memanggil modul alu_signed
    component alu_signed
    Port ( a      : in  STD_LOGIC_VECTOR (3 downto 0);
           b      : in  STD_LOGIC_VECTOR (3 downto 0);
           opcode : in  STD_LOGIC;
           result : out STD_LOGIC_VECTOR (3 downto 0);
           carry  : out STD_LOGIC );
    end component;

    -- Sinyal internal simulasi
    signal tb_a      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal tb_b      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal tb_opcode : STD_LOGIC := '0';
    signal tb_result : STD_LOGIC_VECTOR(3 downto 0);
    signal tb_carry  : STD_LOGIC;

begin
    -- Mapping port
    UUT: alu_signed port map (
        a => tb_a,
        b => tb_b,
        opcode => tb_opcode,
        result => tb_result,
        carry => tb_carry
    );

    -- Proses pemberian input sakelar
    stim_proc: process
    begin
        wait for 10 ns;

        -- Kasus 2: BUKTI OVERFLOW POSITIF (+7 + +7 = -2)
        tb_opcode <= '1';
        tb_a <= "1000"; -- Angka +7 (Maksimal positif 4-bit)
        tb_b <= "0001"; -- Angka +7
        wait for 30 ns;
        -- Hasil result akan menjadi "1110" (-2). 
        -- Bit paling kiri berubah jadi '1' (negatif).


        wait;
    end process;
end behavior;