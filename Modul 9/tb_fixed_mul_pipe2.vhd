library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fixed_mul_pipe2 is
end tb_fixed_mul_pipe2;

architecture sim of tb_fixed_mul_pipe2 is

    component fixed_mul_pipe2
        Port ( clk    : in  STD_LOGIC;
               a      : in  STD_LOGIC_VECTOR (15 downto 0);
               b      : in  STD_LOGIC_VECTOR (15 downto 0);
               result : out STD_LOGIC_VECTOR (15 downto 0) );
    end component;

    constant CLK_PERIOD : time := 10 ns;

    signal clk          : STD_LOGIC := '0';
    signal a_tb, b_tb    : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal result_tb     : STD_LOGIC_VECTOR(15 downto 0);

    type vec_array is array (natural range <>) of STD_LOGIC_VECTOR(15 downto 0);

    -- Stimulus sama persis dengan tb_fixed_mul_q8_8
    constant A_IN : vec_array(0 to 4) := ( x"0200", x"0080", x"0180", x"0A00", x"0F00" );
    constant B_IN : vec_array(0 to 4) := ( x"0300", x"0080", x"0280", x"0A00", x"0F00" );
    -- Hasil Q8.8 yang diharapkan untuk tiap pasangan (dihitung manual, sama dengan Prosedur 1)
    constant EXP  : vec_array(0 to 4) := ( x"0600", x"0040", x"03C0", x"6400", x"E100" );

    signal cycle_count : integer := 0;

begin

    UUT : fixed_mul_pipe2
        port map ( clk => clk, a => a_tb, b => b_tb, result => result_tb );

    -- Pembangkit clock 100 MHz (periode 10 ns)
    clk_gen : process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- Penghitung siklus (untuk referensi waveform)
    cycle_proc : process(clk)
    begin
        if rising_edge(clk) then
            cycle_count <= cycle_count + 1;
        end if;
    end process;

    -- Pemberi stimulus: satu pasangan BARU setiap siklus (streaming, throughput tinggi)
    stim_proc : process
    begin
        wait until rising_edge(clk);
        for i in 0 to 4 loop
            a_tb <= A_IN(i);
            b_tb <= B_IN(i);
            wait until rising_edge(clk);
        end loop;
        -- 2 siklus kosong agar hasil terakhir sempat keluar dari pipa
        a_tb <= (others => '0'); b_tb <= (others => '0');
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        report "=== Simulasi tb_fixed_mul_pipe2 selesai ===";
        wait;
    end process;

    check_proc : process
    begin
        wait until rising_edge(clk); wait for 1 ps;  -- siklus 1
        wait until rising_edge(clk); wait for 1 ps;  -- siklus 2: product_reg (pasangan-0) terisi
        wait until rising_edge(clk); wait for 1 ps;  -- siklus 3: result_reg terisi -> hasil pasangan ke-0 valid
        for i in 0 to 4 loop
            assert result_tb = EXP(i)
                report "GAGAL pada pasangan ke-" & integer'image(i) &
                       " : hasil = " & integer'image(to_integer(unsigned(result_tb))) &
                       " , diharapkan = " & integer'image(to_integer(unsigned(EXP(i))))
                severity error;
            if result_tb = EXP(i) then
                report "OK  pasangan ke-" & integer'image(i) &
                       " -> hasil muncul 2 siklus setelah input (latency=2, throughput=1/siklus)";
            end if;
            wait until rising_edge(clk); wait for 1 ps;
        end loop;
        wait;
    end process;

end sim;
