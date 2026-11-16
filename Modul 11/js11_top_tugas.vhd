library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity js11_top_tugas is
    Port ( clk100MHz : in  STD_LOGIC;
           btnC       : in  STD_LOGIC;
           sw         : in  STD_LOGIC_VECTOR(3 downto 0);

           vgaRed     : out STD_LOGIC_VECTOR(3 downto 0);
           vgaGreen   : out STD_LOGIC_VECTOR(3 downto 0);
           vgaBlue    : out STD_LOGIC_VECTOR(3 downto 0);
           Hsync      : out STD_LOGIC;
           Vsync      : out STD_LOGIC );
end js11_top_tugas;

architecture Behavioral of js11_top_tugas is

    component clk_wiz_0
        port ( clk_in1  : in  STD_LOGIC;
               reset    : in  STD_LOGIC;
               clk_out1 : out STD_LOGIC;
               locked   : out STD_LOGIC );
    end component;

    component vga_sync
        Port ( pclk     : in  STD_LOGIC;
               rst      : in  STD_LOGIC;
               hsync    : out STD_LOGIC;
               vsync    : out STD_LOGIC;
               video_on : out STD_LOGIC;
               h_count  : out integer range 0 to 799;
               v_count  : out integer range 0 to 524 );
    end component;

    component checkerboard_with_sw_box
        Generic ( BLOCK_SIZE_BITS : integer := 5;
                  BOX_W           : integer := 32;
                  BOX_H           : integer := 32;
                  BOX_Y           : integer := 420 );
        Port ( h_count : in  integer range 0 to 799;
               v_count : in  integer range 0 to 524;
               sw      : in  STD_LOGIC_VECTOR(3 downto 0);
               rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
    end component;

    signal pclk_25MHz  : STD_LOGIC;
    signal mmcm_locked : STD_LOGIC;
    signal rst_sync    : STD_LOGIC;

    signal video_on_i  : STD_LOGIC;
    signal h_count_i   : integer range 0 to 799;
    signal v_count_i   : integer range 0 to 524;

    signal rgb_pattern : STD_LOGIC_VECTOR(11 downto 0);
    signal rgb_out     : STD_LOGIC_VECTOR(11 downto 0);

begin

    rst_sync <= btnC or (not mmcm_locked);

    CLK_WIZ_INST: clk_wiz_0
        port map ( clk_in1  => clk100MHz,
                   reset    => btnC,
                   clk_out1 => pclk_25MHz,
                   locked   => mmcm_locked );

    SYNC_INST: vga_sync
        port map ( pclk     => pclk_25MHz,
                   rst      => rst_sync,
                   hsync    => Hsync,
                   vsync    => Vsync,
                   video_on => video_on_i,
                   h_count  => h_count_i,
                   v_count  => v_count_i );

    PATTERN_INST: checkerboard_with_sw_box
        generic map ( BLOCK_SIZE_BITS => 5,
                      BOX_W           => 32,
                      BOX_H           => 32,
                      BOX_Y           => 420 )
        port map ( h_count => h_count_i,
                   v_count => v_count_i,
                   sw      => sw,
                   rgb     => rgb_pattern );

    rgb_out <= rgb_pattern when video_on_i = '1' else (others => '0');

    vgaRed   <= rgb_out(11 downto 8);
    vgaGreen <= rgb_out(7 downto 4);
    vgaBlue  <= rgb_out(3 downto 0);

end Behavioral;
