library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity updown_counter is
    Port (
        clk     : in  STD_LOGIC;
        inc     : in  STD_LOGIC; -- Pulsa tambah (btnU)
        dec     : in  STD_LOGIC; -- Pulsa kurang (btnD)
        reset   : in  STD_LOGIC; -- Pulsa reset (btnC)
        count_o : out STD_LOGIC_VECTOR(15 downto 0)
    );
end updown_counter;

architecture Behavioral of updown_counter is
    signal count_reg : unsigned(15 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count_reg <= (others => '0');
            elsif inc = '1' then
                count_reg <= count_reg + 1;
            elsif dec = '1' then
                count_reg <= count_reg - 1;
            end if;
        end if;
    end process;

    count_o <= std_logic_vector(count_reg);
end Behavioral;