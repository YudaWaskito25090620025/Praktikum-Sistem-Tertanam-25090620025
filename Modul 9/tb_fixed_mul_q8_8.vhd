library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fixed_mul_q8_8 is
end tb_fixed_mul_q8_8;

architecture sim of tb_fixed_mul_q8_8 is

    component fixed_mul_q8_8
        Port ( a      : in  STD_LOGIC_VECTOR (15 downto 0);
               b      : in  STD_LOGIC_VECTOR (15 downto 0);
               result : out STD_LOGIC_VECTOR (15 downto 0) );
    end component;

    signal a_tb, b_tb, result_tb : STD_LOGIC_VECTOR(15 downto 0);

    -- Prosedur bantu: cek hasil terhadap nilai yang diharapkan (dalam hex)
    procedure check(signal res : in STD_LOGIC_VECTOR(15 downto 0);
                     expected  : in STD_LOGIC_VECTOR(15 downto 0);
                     label_str : in STRING) is
    begin
        assert res = expected
            report "GAGAL (" & label_str & ") : hasil = " &
                   integer'image(to_integer(unsigned(res))) &
                   " , diharapkan = " &
                   integer'image(to_integer(unsigned(expected)))
            severity error;
        if res = expected then
            report "OK  (" & label_str & ") hasil = " &
                   integer'image(to_integer(unsigned(res))) & " (desimal/256)";
        end if;
    end procedure;

begin

    UUT : fixed_mul_q8_8
        port map ( a => a_tb, b => b_tb, result => result_tb );

    stim_proc : process
    begin
        -- Kasus 1 : 2.0 x 3.0 = 6.0
        -- 2.0 = 0x0200 , 3.0 = 0x0300 , 6.0 = 0x0600
        a_tb <= x"0200"; b_tb <= x"0300";
        wait for 10 ns;
        check(result_tb, x"0600", "2.0 x 3.0 = 6.0");

        -- Kasus 2 : 0.5 x 0.5 = 0.25
        -- 0.5 = 0x0080 , 0.25 = 0x0040
        a_tb <= x"0080"; b_tb <= x"0080";
        wait for 10 ns;
        check(result_tb, x"0040", "0.5 x 0.5 = 0.25");

        -- Kasus 3 : 1.5 x 2.5 = 3.75
        -- 1.5 = 0x0180 , 2.5 = 0x0280 , 3.75 = 0x03C0
        a_tb <= x"0180"; b_tb <= x"0280";
        wait for 10 ns;
        check(result_tb, x"03C0", "1.5 x 2.5 = 3.75");

        -- Kasus 4 : 10.0 x 10.0 = 100.0
        -- 10.0 = 0x0A00 , 100.0 = 0x6400
        a_tb <= x"0A00"; b_tb <= x"0A00";
        wait for 10 ns;
        check(result_tb, x"6400", "10.0 x 10.0 = 100.0");

        -- Kasus 5 : 15.0 x 15.0 = 225.0
        -- 15.0 = 0x0F00 , 225.0 = 0xE100
        a_tb <= x"0F00"; b_tb <= x"0F00";
        wait for 10 ns;
        check(result_tb, x"E100", "15.0 x 15.0 = 225.0");

        report "=== Simulasi tb_fixed_mul_q8_8 selesai ===";
        wait;
    end process;

end sim;
