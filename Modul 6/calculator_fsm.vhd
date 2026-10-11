library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- FSM Moore (2-process style) + datapath kalkulator 4 operasi.
-- Selektor operasi 2-bit dari switch (sw[9:8]) dibaca saat btnC ditekan di S_WAIT_B:
--   00 = tambah, 01 = kurang, 10 = kali, 11 = bagi
-- Format hasil pada layar:
--   tambah / kurang / kali : 16 bit hasil langsung
--   bagi                   : RRQQ  (RR = sisa, QQ = hasil bagi)
--   bagi dengan B = 0      : EEEE dan err = '1'
entity calculator_fsm is
    Port (
        clk, rst   : in  STD_LOGIC;
        sw         : in  STD_LOGIC_VECTOR (7 downto 0);  -- operand
        op_in      : in  STD_LOGIC_VECTOR (1 downto 0);  -- selektor operasi (sw[9:8])
        p_load_a   : in  STD_LOGIC; -- btnU
        p_load_b   : in  STD_LOGIC; -- btnD
        p_calc     : in  STD_LOGIC; -- btnC
        result     : out STD_LOGIC_VECTOR (15 downto 0);
        disp       : out STD_LOGIC_VECTOR (15 downto 0);
        err        : out STD_LOGIC;
        state_led  : out STD_LOGIC_VECTOR (3 downto 0)
    );
end calculator_fsm;

architecture Behavioral of calculator_fsm is
    type calc_state is (S_WAIT_A, S_WAIT_B, S_COMPUTE, S_SHOW);
    signal state, next_state : calc_state := S_WAIT_A;

    signal reg_a, reg_b : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal op_sel       : STD_LOGIC_VECTOR (1 downto 0) := "00";
    signal alu_y        : STD_LOGIC_VECTOR (15 downto 0);
    signal reg_res      : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal err_r        : STD_LOGIC := '0';

    -- pembagi sekuensial (restoring division): 1 bit per siklus, 8 siklus
    signal cnt   : unsigned(2 downto 0) := (others => '0');
    signal rem_r : unsigned(8 downto 0) := (others => '0');
    signal quo_r : unsigned(7 downto 0) := (others => '0');
    signal done  : STD_LOGIC;

    -- keluaran Moore (hanya fungsi state)
    signal do_compute, show_res : STD_LOGIC;

    component alu8 is
        Port ( a, b : in STD_LOGIC_VECTOR (7 downto 0);
               op   : in STD_LOGIC_VECTOR (1 downto 0);
               y    : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
begin
    ---------------- Process 1: register state (sinkron) ----------------
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= S_WAIT_A;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    ---------------- Process 2: next_state + output Moore (kombinasional) --
    process (state, p_load_a, p_calc, done)
    begin
        next_state <= state;
        do_compute <= '0';
        show_res   <= '0';
        state_led  <= "0000";
        case state is
            when S_WAIT_A =>
                state_led <= "0001";
                if p_load_a = '1' then next_state <= S_WAIT_B; end if;
            when S_WAIT_B =>
                state_led <= "0010";
                if p_calc = '1' then next_state <= S_COMPUTE; end if;
            when S_COMPUTE =>
                state_led  <= "0100";
                do_compute <= '1';
                if done = '1' then next_state <= S_SHOW; end if;
            when S_SHOW =>
                state_led <= "1000";
                show_res  <= '1';
                if p_calc = '1' then next_state <= S_WAIT_A; end if;
        end case;
    end process;

    done <= '1' when cnt = 7 else '0';

    ---------------- Datapath ----------------
    U_ALU : alu8 port map (a => reg_a, b => reg_b, op => op_sel, y => alu_y);

    process (clk)
        variable r  : unsigned(8 downto 0);
        variable qn : unsigned(7 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg_a <= (others => '0'); reg_b <= (others => '0');
                op_sel <= "00"; reg_res <= (others => '0');
                err_r <= '0'; cnt <= (others => '0');
                rem_r <= (others => '0'); quo_r <= (others => '0');
            else
                if state = S_WAIT_A and p_load_a = '1' then
                    reg_a <= sw;
                    err_r <= '0';
                end if;

                if state = S_WAIT_B then
                    if p_load_b = '1' then reg_b <= sw; end if;
                    if p_calc = '1' then
                        op_sel <= op_in;          -- kunci operasi
                        rem_r  <= (others => '0'); -- inisialisasi pembagi
                        quo_r  <= unsigned(reg_a);
                        cnt    <= (others => '0');
                    end if;
                end if;

                if do_compute = '1' then
                    -- satu langkah restoring division (hanya dipakai bila op = "11")
                    r  := rem_r(7 downto 0) & quo_r(7);
                    qn := quo_r(6 downto 0) & '0';
                    if r >= resize(unsigned(reg_b), 9) then
                        r     := r - resize(unsigned(reg_b), 9);
                        qn(0) := '1';
                    end if;
                    rem_r <= r;
                    quo_r <= qn;
                    cnt   <= cnt + 1;

                    if cnt = 7 then               -- siklus terakhir: simpan hasil
                        if op_sel = "11" then
                            if reg_b = x"00" then
                                reg_res <= x"EEEE";
                                err_r   <= '1';
                            else
                                reg_res <= std_logic_vector(r(7 downto 0)) & std_logic_vector(qn);
                            end if;
                        else
                            reg_res <= alu_y;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    result <= reg_res;
    err    <= err_r;
    disp   <= reg_res when show_res = '1' else reg_a & reg_b;
end Behavioral;
