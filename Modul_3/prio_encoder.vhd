library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_encoder is
    Port ( sw  : in  STD_LOGIC_VECTOR (7 downto 0);
           led : out STD_LOGIC_VECTOR (3 downto 0));
end top_encoder;

architecture Behavioral of top_encoder is
begin
    -- Memanggil modul leading_one_detector yang sudah ada
    UUT: entity work.leading_one_detector
        generic map (WIDTH => 8)
        port map (
            din   => sw,             -- Input 8-bit disambung ke switch 7 hingga 0
            pos   => led(2 downto 0),-- Output 3-bit posisi disambung ke LED 2, 1, 0
            valid => led(3)          -- Output 1-bit penanda 'valid' ke LED 3
        );
end Behavioral;