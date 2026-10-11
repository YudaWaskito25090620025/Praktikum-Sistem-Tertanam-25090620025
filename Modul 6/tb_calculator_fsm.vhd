library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_calculator_fsm is
end tb_calculator_fsm;

architecture sim of tb_calculator_fsm is
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '1';
    signal sw  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal op  : STD_LOGIC_VECTOR (1 downto 0) := "00";
    signal pu, pd, pc : STD_LOGIC := '0';
    signal result, disp : STD_LOGIC_VECTOR (15 downto 0);
    signal led : STD_LOGIC_VECTOR (3 downto 0);
    signal err : STD_LOGIC;

    procedure pulse(signal s : out STD_LOGIC) is
    begin
        wait until rising_edge(clk); s <= '1';
        wait until rising_edge(clk); s <= '0';
        wait until rising_edge(clk);
    end procedure;
begin
    clk <= not clk after 5 ns;

    UUT : entity work.calculator_fsm port map (
        clk => clk, rst => rst, sw => sw, op_in => op,
        p_load_a => pu, p_load_b => pd, p_calc => pc,
        result => result, disp => disp, err => err, state_led => led);

    process
        -- satu perhitungan penuh: muat A, muat B, pilih op, hitung, cek hasil
        procedure run_test(a, b : in STD_LOGIC_VECTOR(7 downto 0);
                           o    : in STD_LOGIC_VECTOR(1 downto 0);
                           expected : in STD_LOGIC_VECTOR(15 downto 0);
                           name : in string) is
        begin
            sw <= a; pulse(pu);
            sw <= b; pulse(pd);
            op <= o; wait until rising_edge(clk);
            pulse(pc);
            wait until led = "1000" for 500 ns;
            wait for 1 ns;
            assert led = "1000" report "GAGAL " & name & ": tidak sampai S_SHOW" severity error;
            assert result = expected report "GAGAL " & name & ": hasil salah" severity error;
            assert disp = expected report "GAGAL " & name & ": disp bukan hasil" severity error;
            report "OK " & name & " -> hasil (desimal) = " & integer'image(to_integer(unsigned(result)));
            pulse(pc);  -- kembali ke S_WAIT_A
            assert led = "0001" report "GAGAL " & name & ": tidak kembali ke S_WAIT_A" severity error;
        end procedure;
    begin
        wait for 33 ns; rst <= '0';
        wait until rising_edge(clk);

        run_test(x"19", x"11", "00", x"002A", "tambah 0x19+0x11");
        run_test(x"FF", x"FF", "00", x"01FE", "tambah 0xFF+0xFF");
        run_test(x"64", x"1E", "01", x"0046", "kurang 0x64-0x1E");
        run_test(x"05", x"0A", "01", x"FFFB", "kurang 0x05-0x0A (negatif)");
        run_test(x"AB", x"1C", "10", x"12B4", "kali 0xAB*0x1C");
        run_test(x"FF", x"FF", "10", x"FE01", "kali 0xFF*0xFF");
        run_test(x"DE", x"0F", "11", x"0C0E", "bagi 0xDE/0x0F (sisa 0C, hasil 0E)");
        run_test(x"64", x"07", "11", x"020E", "bagi 0x64/0x07 (sisa 02, hasil 0E)");
        run_test(x"FF", x"10", "11", x"0F0F", "bagi 0xFF/0x10 (sisa 0F, hasil 0F)");

        -- bagi dengan nol: harus EEEE dan err = '1'
        run_test(x"AB", x"00", "11", x"EEEE", "bagi dengan nol");
        assert err = '1' report "GAGAL: flag err tidak aktif saat bagi dengan nol" severity error;
        report "SIMULASI SELESAI";
        wait;
    end process;
end sim;
