library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debounce is
end tb_debounce;

architecture sim of tb_debounce is
    signal clk     : STD_LOGIC := '0';
    signal btn_in  : STD_LOGIC := '0';
    signal btn_out : STD_LOGIC;
begin
    uut: entity work.debounce
        generic map (CLK_FREQ_HZ => 1000, STABLE_MS => 10)
        port map (clk => clk, btn_in => btn_in, btn_out => btn_out);

    clk <= not clk after 5 ns;

    process
    begin
        wait for 100 ns;
        for i in 1 to 5 loop
            btn_in <= '1'; wait for 20 ns;
            btn_in <= '0'; wait for 20 ns;
        end loop;
        btn_in <= '1';
        wait for 500 ns;
        for i in 1 to 5 loop
            btn_in <= '0'; wait for 20 ns;
            btn_in <= '1'; wait for 20 ns;
        end loop;
        btn_in <= '0';
        wait for 500 ns;
        wait;
    end process;
end sim;
