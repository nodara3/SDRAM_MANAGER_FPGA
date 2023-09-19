library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.type_def_package.all;

entity SDR_Write is
    port (
        i_rst : IN STD_LOGIC;
        m_clk : IN STD_LOGIC;

        SDRM_sdram_addr          : in std_logic_vector (c_SDRAM_ADDR_DEPTH - 1 downto 0);
        SDRM_SDR_WrData        : in std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
        SDRM_bram_read         : out std_logic;
        SDRM_write_command     : in std_logic;
        SDRM_Busy_Write        : out std_logic;

        sys_R_Wn			:out std_logic;							--read/write signal, high indicates reading and low indicates writing
        sys_ADSn			:out std_logic;							--active low address strobe
        sys_REF_REQ			:out std_logic;							--active high SDRAM refresh request
        sys_REF_ON			:in std_logic;							--active high refresh request acknowledge
        sys_A				:out std_logic_vector( RA_MSB downto CA_LSB);	--address bus
        sys_D				:INOUT std_logic_vector( SYS_DATA_WIDTH-1 downto 0);	--data bus
        sys_CYC_END			:IN std_logic							--active high signal indicates that read/write cycle has been finished 
        
    );
end entity SDR_Write;

architecture rtl of SDR_Write is
    type 	t_machine is  (s_idle, s_bram_enable,  s_SDRAM_Strobe, s_SDRAM_Write,  s_SDRAM_cyc_end ,s_Refresh, s_REF_DONE);

	signal s_prev_state, s_next_state : t_machine;
	signal s_machine_counter : NATURAL range 0 to 500;

	signal s_D_deter: STD_LOGIC; -- signal that enables tri state data bus registering
	signal s_add_en : std_logic;
	signal s_burst_cnt : NATURAL range 0 to 300;
	signal s_burst_enable : STD_LOGIC;
	signal sys_REF_ON_1 : STD_LOGIC;
    signal s_write_command :std_logic;
	


begin

	p_flopping : process (m_clk, i_rst)
	begin
		if i_rst = '1' then
			s_write_command <= '0';
			
		elsif falling_edge(m_clk) then
			s_write_command <= SDRM_write_command;
			sys_REF_ON_1	<= sys_REF_ON;

			if s_write_command = '0' and SDRM_write_command = '1' then
					
			end if;

		end if;
	end process;
    
    p_counter : process (m_clk, i_rst)
    begin
        if i_rst = '1' then
            s_burst_cnt <= 0;
			s_machine_counter <= 0;
			s_prev_state <= s_idle;

        elsif falling_edge(m_clk) then
			
			if SDRM_write_command = '1' then        -- needs changing , wrong condition

				if s_burst_enable = '1' then
					s_burst_cnt <= s_burst_cnt +1;
				else
					s_burst_cnt <= 0;
				end if;
		
				if s_prev_state = s_next_state then 
					s_machine_counter <= s_machine_counter + 1;
				else 
					s_prev_state <= s_next_state;
					s_machine_counter <= 0;
				end if;

			end if;
            
        end if;
    end process;


    p_FSM : process (all)
    begin
        case s_prev_state is 

			when s_idle =>
			
				if s_write_command = '0' and SDRM_write_command = '1' then
					s_next_state <= s_SDRAM_Strobe;
					SDRM_Busy_Write <= '1';
				else
					SDRM_Busy_Write <= '0';
					s_next_state <= s_idle;
				end if;

                sys_R_Wn <= '1';
				sys_ADSn <= '1';
				sys_REF_REQ <= '0';
				s_D_deter <= '0';
				s_add_en <= '0';
				s_burst_enable <= '0';
				SDRM_bram_read <= '0';

			when s_SDRAM_Strobe =>

				if s_machine_counter = 2 then
					
					sys_ADSn <= '0';
					s_next_state <= s_SDRAM_Write;
                else
					
					sys_ADSn <= '1';
					s_next_state <= s_SDRAM_Strobe;
				end if;
				
				SDRM_bram_read <= '0';
				sys_REF_REQ <= '0';
                sys_R_Wn <= '1';
				SDRM_Busy_Write <= '1';	
				s_add_en <= '1';
				s_D_deter <= '0';	
		
				s_burst_enable <= '0';

			when s_SDRAM_Write => 
				       
                if s_machine_counter = c_STROBE_COUNTER then
                    sys_R_Wn <= '0';
                    s_next_state <= s_bram_enable; 
                else
                    sys_R_Wn <= '1';
                    s_next_state <= s_SDRAM_Write;
                
                end if;
				
				sys_REF_REQ <= '0';
				sys_ADSn <= '1';
				SDRM_Busy_Write <= '1';
				SDRM_bram_read <= '0';
				s_add_en <= '1';	
	
				s_D_deter <= '0'; 
				s_burst_enable <= '0';
				
			when s_bram_enable =>

				if s_machine_counter > 0 then 
					s_D_deter <= '1';
				else
					s_D_deter <= '0';
				end if;
				
				if s_burst_cnt < c_Page_size   then
					SDRM_bram_read <= '1'; 
					s_next_state <= s_bram_enable;
					s_burst_enable <= '1';
				else
					SDRM_bram_read <= '0';
					s_next_state <= s_SDRAM_cyc_end;
					s_burst_enable <= '0';
				end if;
				
                sys_R_Wn <= '1';
				sys_ADSn <= '1';
                sys_REF_REQ <= '0';
				SDRM_Busy_Write <= '1';
				s_add_en <= '1';

			
			when s_SDRAM_cyc_end =>

				if sys_CYC_END = '1' then
					s_next_state <= s_refresh;					
				else					
					s_next_state <= s_SDRAM_cyc_end;
				end if;

				SDRM_bram_read <= '0';
				SDRM_Busy_Write <= '1';
				sys_R_Wn <= '1';
				sys_ADSn <= '1';				
				sys_REF_REQ <='0';	
		
				s_add_en <= '0';
				s_D_deter <= '0';
				s_burst_enable <= '0';
			
			when s_refresh => 

			    SDRM_bram_read <= '0';
				SDRM_Busy_Write <= '1';
                s_next_state <= s_REF_DONE;
				sys_REF_REQ <= '1';
                sys_ADSn <= '1';
                sys_R_Wn <= '1';					

				s_add_en <= '0';
				s_D_deter <= '0';
				s_burst_enable <= '0';
				
			when s_REF_DONE => 

				if sys_REF_ON_1 = '1'  and  sys_REF_ON = '0' then
					sys_REF_REQ <= '0';
					SDRM_Busy_Write <= '0';
					s_next_state <= s_idle;	
				elsif sys_REF_ON = '1' then
					sys_REF_REQ <= '0';
					s_next_state <= s_REF_DONE;
					SDRM_Busy_Write <= '1';	
				else
					SDRM_Busy_Write <= '1';
					sys_REF_REQ <= '0';
					s_next_state <= s_REF_DONE;	
				end if;

				
				SDRM_bram_read <= '0';
                sys_ADSn <= '1';
                sys_R_Wn <= '1';

                s_add_en <= '0';
                s_D_deter <= '0';	
                s_burst_enable <= '0';
                

			when others => NULL;
		end case;
    end process;
	
    sys_A(CA_MSB downto CA_LSB) <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8)) when s_add_en = '1' else (others => '1');
    sys_A(BA_MSB downto BA_LSB) <= SDRM_sdram_addr(c_SDRAM_ADDR_DEPTH-1 downto c_SDRAM_ROW_BITS) when s_add_en = '1' else (others => '1');
    sys_A(RA_MSB downto RA_LSB) <= SDRM_sdram_addr(c_SDRAM_ROW_BITS - 1 downto 0) when s_add_en = '1' else (others => '1');
 
    sys_D <= SDRM_SDR_WrData when s_D_deter = '1' else (others => 'Z');


end architecture;