library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity checkerboard_with_sw_box is
    Generic ( BLOCK_SIZE_BITS : integer := 5;   -- ukuran kotak catur = 2^5 = 32 px
              BOX_W           : integer := 32;  -- lebar kotak indikator
              BOX_H           : integer := 32;  -- tinggi kotak indikator
              BOX_Y            : integer := 420 ); -- posisi vertikal kotak indikator
    Port ( h_count : in  integer range 0 to 799;
           v_count : in  integer range 0 to 524;
           sw      : in  STD_LOGIC_VECTOR(3 downto 0);
           rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
end checkerboard_with_sw_box;

architecture Behavioral of checkerboard_with_sw_box is

    constant H_DISPLAY : integer := 640;
    constant SLOT_W     : integer := H_DISPLAY / 16;  -- 40 piksel per slot switch

    signal h_blk_bit, v_blk_bit : STD_LOGIC;
    signal checker              : STD_LOGIC;

    signal sw_val     : integer range 0 to 15;
    signal box_x_start, box_x_end : integer range 0 to 799;
    signal box_on      : STD_LOGIC;

begin

    h_blk_bit <= '1' when ((h_count / (2**BLOCK_SIZE_BITS)) mod 2) = 1 else '0';
    v_blk_bit <= '1' when ((v_count / (2**BLOCK_SIZE_BITS)) mod 2) = 1 else '0';
    checker   <= h_blk_bit xor v_blk_bit;

    sw_val <= to_integer(unsigned(sw));

    -- Kotak diletakkan di tengah slot ke-sw_val, lebar BOX_W
    box_x_start <= sw_val * SLOT_W + (SLOT_W - BOX_W)/2;
    box_x_end   <= box_x_start + BOX_W;

    box_on <= '1' when (h_count >= box_x_start) and (h_count < box_x_end) and
                        (v_count >= BOX_Y) and (v_count < BOX_Y + BOX_H)
              else '0';

    rgb <= "111100000000" when box_on = '1' else      -- merah: kotak indikator
           "111111111111" when checker = '0' else      -- putih: checkerboard
           "000000000000";                              -- hitam: checkerboard

end Behavioral;
