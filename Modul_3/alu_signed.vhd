library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_signed is
    Port ( a      : in  STD_LOGIC_VECTOR (3 downto 0);
           b      : in  STD_LOGIC_VECTOR (3 downto 0);
           opcode : in  STD_LOGIC; -- '0'=tambah, '1'=kurang
           result : out STD_LOGIC_VECTOR (3 downto 0);
           carry  : out STD_LOGIC ); -- Sekarang port ini berfungsi sebagai indikator OVERFLOW
end alu_signed;

architecture Behavioral of alu_signed is
    signal a_s, b_s : signed (3 downto 0);
begin
    a_s <= signed(a);
    b_s <= signed(b);

    process(a_s, b_s, opcode)
        variable v_sum : signed(4 downto 0);
    begin
        if opcode = '0' then
            -- resize() otomatis melakukan sign-extension
            v_sum := resize(a_s, 5) + resize(b_s, 5);
        else
            v_sum := resize(a_s, 5) - resize(b_s, 5);
        end if;
        
        result <= std_logic_vector(v_sum(3 downto 0));
        
        -- Logika pendeteksi Overflow otomatis menggunakan XOR
        -- Membandingkan bit ke-5 (Tanda Asli) dengan bit ke-4 (Tanda Hasil)
        carry  <= v_sum(4) xor v_sum(3);
        
    end process;
end Behavioral;