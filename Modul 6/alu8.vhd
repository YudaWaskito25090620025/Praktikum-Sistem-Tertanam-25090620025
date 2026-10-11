library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ALU 8-bit, keluaran 16 bit.
-- op = "00" : tambah   y = a + b
-- op = "01" : kurang   y = a - b  (two's complement 16 bit)
-- op = "10" : kali     y = a * b
-- op = "11" : (bagi dikerjakan oleh pembagi sekuensial di calculator_fsm)
entity alu8 is
    Port (
        a  : in  STD_LOGIC_VECTOR (7 downto 0);
        b  : in  STD_LOGIC_VECTOR (7 downto 0);
        op : in  STD_LOGIC_VECTOR (1 downto 0);
        y  : out STD_LOGIC_VECTOR (15 downto 0)
    );
end alu8;

architecture Behavioral of alu8 is
begin
    process (a, b, op)
        variable ua, ub : unsigned(15 downto 0);
    begin
        ua := resize(unsigned(a), 16);
        ub := resize(unsigned(b), 16);
        case op is
            when "00"   => y <= std_logic_vector(ua + ub);
            when "01"   => y <= std_logic_vector(ua - ub);
            when "10"   => y <= std_logic_vector(unsigned(a) * unsigned(b));
            when others => y <= (others => '0');
        end case;
    end process;
end Behavioral;
