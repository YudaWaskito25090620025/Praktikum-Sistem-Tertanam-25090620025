library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_mult is
    Port ( a      : in  STD_LOGIC_VECTOR (3 downto 0);
           b      : in  STD_LOGIC_VECTOR (3 downto 0);
           opcode : in  STD_LOGIC_VECTOR (1 downto 0);
           result : out STD_LOGIC_VECTOR (7 downto 0);
           carry  : out STD_LOGIC );
end alu_mult;

architecture Behavioral of alu_mult is
    signal a_u, b_u : unsigned(3 downto 0);
begin
    a_u <= unsigned(a);
    b_u <= unsigned(b);

    process(a_u, b_u, opcode)
        variable v_sum : unsigned(4 downto 0);
        variable v_mul : unsigned(7 downto 0);
    begin
        carry <= '0';
        result <= (others => '0');
        v_sum := (others => '0');
        v_mul := (others => '0');

        if opcode = "00" then
            v_sum := ('0' & a_u) + ('0' & b_u);
            result(3 downto 0) <= std_logic_vector(v_sum(3 downto 0));
            carry <= v_sum(4);
        elsif opcode = "01" then
            v_sum := ('0' & a_u) - ('0' & b_u);
            result(3 downto 0) <= std_logic_vector(v_sum(3 downto 0));
            carry <= v_sum(4);
        elsif opcode = "10" then
            v_mul := a_u * b_u;
            result <= std_logic_vector(v_mul);
        end if;
    end process;
end Behavioral;