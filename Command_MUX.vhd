library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.type_def_package.all;

entity Command_MUX is
    port (
        SDRM_mux_addr      :in std_Logic_vector(1 downto 0);
        SDRM_BUSY_RW       :out std_logic;
        SDRM_Busy_write    :in std_logic;
        SDRM_Busy_Read     :in std_logic;       
        SDRM_read_command  :out std_logic;
        SDRM_write_command :out std_logic

    );
end entity Command_MUX;

architecture rtl of Command_MUX is

begin

    SDRM_write_command <= '1'  when SDRM_mux_addr = "01"  else '0';
    SDRM_read_command  <= '1'  when SDRM_mux_addr = "10"  else '0';
    SDRM_BUSY_RW       <= '1'  when SDRM_Busy_Read  = '1'  else
                       '1'  when SDRM_Busy_write = '1' else '0';
         

end architecture;