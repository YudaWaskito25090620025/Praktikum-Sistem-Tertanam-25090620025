library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fixed_mul_4bit_sw is
end tb_fixed_mul_4bit_sw;

architecture sim of tb_fixed_mul_4bit_sw is

    component fixed_mul_4bit_sw
        Port ( clk : in  STD_LOGIC;
               sw  : in  STD_LOGIC_VECTOR (7 downto 0);
               seg : out STD_LOGIC_VECTOR (6 downto 0);
               dp  : out STD_LOGIC;
               an  : out STD_LOGIC_VECTOR (3 downto 0) );
    end component;

    signal clk_tb : STD_LOGIC := '0';
    signal sw_tb  : STD_LOGIC_VECTOR(7 downto 0);
    signal seg_tb : STD_LOGIC_VECTOR(6 downto 0);
    signal dp_tb  : STD_LOGIC;
    signal an_tb  : STD_LOGIC_VECTOR(3 downto 0);

begin

    UUT : fixed_mul_4bit_sw
        port map ( clk => clk_tb, sw => sw_tb, seg => seg_tb, dp => dp_tb, an => an_tb );

    clk_proc : process
    begin
        clk_tb <= '0'; wait for 5 ns;
        clk_tb <= '1'; wait for 5 ns;
    end process;

    -- Stimulus: 6 pasang nilai dari tabel kebenaran
    -- Amati seg/an/dp pada waveform untuk tiap nilai sw
    stim_proc : process
    begin
        sw_tb <= "01000100"; wait for 1 us; -- 1.0 x 1.0 = 1.0
        sw_tb <= "10001000"; wait for 1 us; -- 2.0 x 2.0 = 4.0
        sw_tb <= "11111111"; wait for 1 us; -- 3.75 x 3.75 = 14.0625
        sw_tb <= "01001111"; wait for 1 us; -- 1.0 x 3.75 = 3.75
        sw_tb <= "01010101"; wait for 1 us; -- 1.25 x 1.25 = 1.5625
        sw_tb <= "10100011"; wait for 1 us; -- 2.5 x 0.75 = 1.875

        report "=== Simulasi tb_fixed_mul_4bit_sw selesai ===";
        wait;
    end process;

end sim;