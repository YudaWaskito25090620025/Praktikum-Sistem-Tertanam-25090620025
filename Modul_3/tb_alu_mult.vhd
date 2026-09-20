library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_alu_mult is
-- Kosong karena ini adalah testbench
end tb_alu_mult;

architecture behavior of tb_alu_mult is
    -- Memanggil komponen alu_mult
    component alu_mult
    Port ( a      : in  STD_LOGIC_VECTOR (3 downto 0);
           b      : in  STD_LOGIC_VECTOR (3 downto 0);
           opcode : in  STD_LOGIC_VECTOR (1 downto 0);
           result : out STD_LOGIC_VECTOR (7 downto 0);
           carry  : out STD_LOGIC );
    end component;

    -- Sinyal internal
    signal tb_a      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal tb_b      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal tb_opcode : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal tb_result : STD_LOGIC_VECTOR(7 downto 0);
    signal tb_carry  : STD_LOGIC;

begin
    -- Mapping port
    uut: alu_mult port map (
        a => tb_a,
        b => tb_b,
        opcode => tb_opcode,
        result => tb_result,
        carry => tb_carry
    );

    stim_proc: process
    begin
        wait for 10 ns;


        tb_opcode <= "10"; 
        tb_a <= "0100";    
        tb_b <= "0100";    
        wait for 10 ns;



        wait; 
    end process;
end behavior;