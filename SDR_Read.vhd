library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.type_def_package.all;

entity SDR_Read is
    port (
        i_rst           : IN STD_LOGIC;
        m_clk           : IN STD_LOGIC;

        SDRM_sdram_addr          : in std_logic_vector (c_SDRAM_ADDR_DEPTH - 1 downto 0);
        SDRM_SDR_RdData        : out std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
        SDRM_bram_write        : out std_logic;
        SDRM_read_command      : in std_logic;
        SDRM_Busy_Read         : out std_logic;

        sys_R_Wn			:OUT std_logic;							--read/write signal, high indicates reading and low indicates writing
        sys_ADSn			:OUT std_logic;							--active low address strobe
        sys_REF_REQ			:OUT std_logic;							--active high SDRAM refresh request
        sys_REF_ON			:IN std_LOGIC;
        sys_D_valid			:IN std_logic;
        sys_A				:OUT std_logic_vector( RA_MSB downto CA_LSB);	--address bus
        sys_D				:IN std_logic_vector(SYS_DATA_WIDTH-1 downto 0);	--data bus
        sys_CYC_END			:IN std_logic							--active high signal indicates that read/write cycle has been finished 

        
    );
end entity SDR_Read;

architecture rtl of SDR_Read is

	type t_machine is  (s_Idle, s_SDRAM_Strobe, s_SDRAM_Rd, s_Check_Valid, s_SDRAM_VALID , s_Refresh, s_REF_DONE);
	signal s_prev_state, s_next_state : t_machine ;
	signal s_machine_counter : NATURAL range 0 to 500;
    signal s_read_command : std_logic;
	signal r_data_reg : STD_LOGIC_VECTOR (SYS_DATA_WIDTH-1 downto 0);
	signal s_add_en : STD_LOGIC;
	signal s_burst_cnt: NATUrAL range 0 to 300;
	signal s_burst_enable : STD_LOGIC;
	signal sys_REF_ON_1 : STD_LOGIC;

begin
    
    p_flopping : process (m_clk, i_rst)
	begin
		if i_rst = '1' then
			s_read_command <= '0';
            sys_REF_ON_1 <= '0';
            -- m_bram_write <= '0';
		elsif falling_edge(m_clk) then
			s_read_command <= SDRM_read_command;
			sys_REF_ON_1	<= sys_REF_ON; 
            -- m_bram_write    <= sys_D_valid; 

		end if;
	end process;
    
    p_counter : process (m_clk, i_rst)
    begin
        if i_rst = '1' then
            s_burst_cnt <= 0;
			s_machine_counter <= 0;
			s_prev_state <= s_idle;
            r_data_reg <= (others => '0'); 

        elsif falling_edge(m_clk) then
			
			if SDRM_read_command = '1' then        

                r_data_reg <= sys_D;
             
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
        case s_prev_State is 
			when s_idle =>	

                if s_read_command = '0' and SDRM_read_command = '1' then
				    s_next_state <= s_SDRAM_Strobe;		
                    SDRM_Busy_Read <= '1';
		    	else
                    SDRM_Busy_Read <= '0';
                    s_next_state <= s_idle;
                end if;

				sys_R_Wn <= '0';
				sys_ADSn <= '1';
				s_burst_enable <= '0';
				sys_REF_REQ <= '0';
				s_add_en <= '0';
	
				
			when s_SDRAM_Strobe =>

				if s_machine_counter = 2 then
					sys_ADSn <= '0';
					s_add_en <= '1';	
					s_next_state <= s_SDRAM_Rd;
				else
					sys_ADSn <= '1';		
					s_add_en <= '0';
					s_next_state <= s_SDRAM_Strobe;
				end if;		

				SDRM_Busy_Read <= '1';
                s_burst_enable <= '0';
                sys_R_Wn <= '0';	
                sys_REF_REQ <= '0';	

			when s_SDRAM_Rd => 
	
				if s_machine_counter = c_STROBE_COUNTER and sys_CYC_END = '0' then
					sys_R_Wn <= '1';
					s_next_state <= s_Check_Valid;
				else
					sys_R_Wn <= '0';
					s_next_state <= s_SDRAM_Rd;
				end if;

                SDRM_Busy_Read <= '1';
                s_burst_enable <= '0';
                s_add_en <= '1';
                sys_REF_REQ <= '0';	
                sys_ADSn <= '1';

			when s_Check_Valid => 

				if sys_D_valid  = '1' then				
					s_next_state <= s_SDRAM_VALID;
					s_burst_enable <= '1';	
				else
					s_burst_enable <= '0';	
					s_next_state <= s_Check_Valid;
				end if;
		    	
				SDRM_Busy_Read <= '1';
				sys_R_Wn <= '0';
				sys_ADSn <= '1';
				s_burst_enable <= '0';
				s_add_en <= '1';
				sys_REF_REQ <= '0';	
		
			when s_SDRAM_VALID =>
				
				if sys_D_valid = '1' then
					s_next_state <= s_SDRAM_VALID;
					s_burst_enable <= '1';	
				else
					s_next_state <= s_refresh;
					s_burst_enable <= '0';	
				end if;			
		    	
                SDRM_Busy_Read <= '1';
				sys_ADSn <= '1';			
				sys_R_Wn <= '0';				
				s_add_en <= '0';
				sys_REF_REQ <= '0';	

			when s_refresh => 

				if s_machine_counter = 2 then
					sys_REF_REQ <= '1';
					s_next_state <= s_REF_DONE;	
				else
					sys_REF_REQ <= '0';
					s_next_state <= s_refresh;	
				end if;

                SDRM_Busy_Read <= '1';
				sys_R_Wn <= '0';
				sys_ADSn <= '1';
				s_burst_enable <= '0';
				s_add_en <= '0';
				
			when s_REF_DONE => 
				
				if sys_REF_ON_1 = '1' and 	 sys_REF_ON = '0' then
					sys_REF_REQ <= '0';
					s_next_state <= s_Idle;	
                    SDRM_Busy_Read <= '0';

				elsif sys_REF_ON = '1' then
				
                    SDRM_Busy_Read <= '1';
					sys_REF_REQ <= '0';
					s_next_state <= s_REF_DONE;	
				else
                    SDRM_Busy_Read <= '1';
					sys_REF_REQ <= '0';
					s_next_state <= s_REF_DONE;	
				end if;

				sys_R_Wn <= '0';
				sys_ADSn <= '1';
				s_burst_enable <= '0';
				s_add_en <= '0';
			
			when others => NULL;
				
		end case;
    end process;

    sys_A(CA_MSB downto CA_LSB) <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8)) when s_add_en = '1' else (others => '1');
    sys_A(BA_MSB downto BA_LSB) <= SDRM_sdram_addr(c_SDRAM_ADDR_DEPTH-1 downto c_SDRAM_ROW_BITS) when s_add_en = '1' else (others => '1');
    sys_A(RA_MSB downto RA_LSB) <= SDRM_sdram_addr(c_SDRAM_ROW_BITS - 1 downto 0) when s_add_en = '1' else (others => '1');
		SDRM_bram_write <= s_burst_enable;                                    
		SDRM_SDR_RdData <= r_data_reg(c_EBR_DATA_WIDTH - 1 downto 0) when SDRM_bram_write = '1' else (others => '0');	

end architecture;