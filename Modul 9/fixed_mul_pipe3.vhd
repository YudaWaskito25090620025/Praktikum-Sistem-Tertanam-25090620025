library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fixed_mul_pipe3 is
    Port ( clk    : in  STD_LOGIC;
           a      : in  STD_LOGIC_VECTOR (15 downto 0); -- format Q8.8
           b      : in  STD_LOGIC_VECTOR (15 downto 0); -- format Q8.8
           result : out STD_LOGIC_VECTOR (15 downto 0) ); -- format Q8.8
end fixed_mul_pipe3;

architecture Behavioral of fixed_mul_pipe3 is

    signal pp_lo_reg : unsigned(23 downto 0); -- a_lo(8) * b(16) -> 24 bit
    signal pp_hi_reg : unsigned(23 downto 0); -- a_hi(8) * b(16) -> 24 bit

    signal product_reg : unsigned(31 downto 0);

    signal result_reg : STD_LOGIC_VECTOR(15 downto 0);

    -- sinyal kombinasional pembantu tahap 1
    signal a_hi, a_lo : unsigned(7 downto 0);
    signal b_u         : unsigned(15 downto 0);

begin

    a_hi <= unsigned(a(15 downto 8));
    a_lo <= unsigned(a(7 downto 0));
    b_u  <= unsigned(b);

    stage1 : process(clk)
    begin
        if rising_edge(clk) then
            pp_lo_reg <= a_lo * b_u;  -- kontribusi 8 bit LSB dari a
            pp_hi_reg <= a_hi * b_u;  -- kontribusi 8 bit MSB dari a (perlu digeser 8 bit)
        end if;
    end process;

    stage2 : process(clk)
    begin
        if rising_edge(clk) then
            product_reg <= resize(pp_lo_reg, 32) +
                           shift_left(resize(pp_hi_reg, 32), 8);
        end if;
    end process;

    stage3 : process(clk)
    begin
        if rising_edge(clk) then
            result_reg <= STD_LOGIC_VECTOR(product_reg(23 downto 8));
        end if;
    end process;

    result <= result_reg;
end Behavioral;
