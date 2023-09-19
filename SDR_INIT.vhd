library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.type_def_package.all;

entity SDR_INIT is

    port (
        m_clk           : in std_logic;
        i_rst           : in std_logic;
        sys_DLY_100US   : out std_logic    
    );
end entity;

architecture rtl of SDR_INIT is
    signal s_init_cnt : natural range 0 to c_SDR_INIT_TIME-1 ;
begin
 
    p_sdr_in : process (all) is
    begin
        if i_rst = '1' then		
			sys_DLY_100US <= '0';
			
		elsif falling_edge (m_clk) then
					
			if s_init_cnt < c_SDR_INIT_TIME-1 then
				s_init_cnt <= s_init_cnt + 1;
			else
				sys_DLY_100US <= '1';
			end if;		
		
		end if;
    end process;
    

end architecture;

