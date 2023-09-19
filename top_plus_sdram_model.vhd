use work.type_def_package.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- use work.sdr_par.all;


entity top_plus_sdram_model is
	port(
		i_clk   			: in std_logic;
		i_rst				 : in std_logic;
		
		m_sdr_addr          : in std_logic_vector (c_SDRAM_ADDR_DEPTH - 1 downto 0);
		-- m_ebr_addr          : in std_logic_vector (c_EBR_NUM_ADDR - 1 downto 0);
		m_BUSY              : out std_logic;
		m_ACK               : out std_logic;
		m_Read_Str          : in std_logic;
		m_Write_Str         : in std_logic;
		
		ebr_sdr_select      : in std_logic_vector(c_TOTAL_EBR_WIDTH-1 downto 0);
		ebr_user_select     : in std_logic_vector(c_TOTAL_EBR_WIDTH-1 downto 0);

		m_WrClockEn     : in std_logic;
        m_EBR_WrData    : in std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
        m_WrAddress     : in std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0);

		m_USER_RdAddress:   in std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
		m_USER_RdClockEn:   in std_logic; 
		m_USER_Q:           out std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0)
	);

end top_plus_sdram_model;	
	
architecture Behavioral of top_plus_sdram_model is
	
	signal i_send_start : STD_LOGIC;
	
	signal o_led : STD_LOGIC;
	
	signal o_sd_cke : STD_LOGIC;
	signal o_sd_ba : STD_LOGIC_VECTOR(1 downto 0);
	signal o_sd_cs0_l : STD_LOGIC;
	signal o_sd_ras_l : STD_LOGIC;
	signal o_sd_cas_l : STD_LOGIC;
	signal o_sd_we_l : STD_LOGIC;
	signal o_sd_add : STD_LOGIC_VECTOR(10 downto 0);
	signal o_sd_dqm  : STD_LOGIC_VECTOR(3 downto 0);
	signal o_ack_l : STD_LOGIC;
	signal io_sdram_setup : STD_LOGIC;

	signal o_sd_clk : STD_LOGIC;
	
	signal o_sd_dqm1  : STD_LOGIC;
	signal io_sd_data : STD_LOGIC_VECTOR(31 downto 0);

	component top
		port(
			i_clk   : in std_logic;
			i_rst : in std_logic;
			
			m_sdr_addr          : in std_logic_vector (c_SDRAM_ADDR_DEPTH - 1 downto 0);
	
			ebr_sdr_select      : in std_logic_vector(c_TOTAL_EBR_WIDTH-1 downto 0);
			ebr_user_select     : in std_logic_vector(c_TOTAL_EBR_WIDTH-1 downto 0);
	
			m_BUSY              : out std_logic;
			m_ACK               : out std_logic;
			m_Read_Str          : in std_logic;
			m_Write_Str         : in std_logic;
	
			io_DQ				:inout std_logic_vector(SDR_DATA_WIDTH-1 downto 0);
			o_A					:out std_logic_vector(11-1 downto 0);
			o_BA				:out std_logic_vector(1 downto 0);
			o_CKE				:out std_logic;
			o_CSn				:out std_logic;
			o_RASn				:out std_logic;
			o_CASn				:out std_logic;
			o_WEn				:out std_logic;
			o_DQM 				:out std_logic;
			o_CK				:out std_logic;
	
			m_USER_RdAddress:   in std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
			m_USER_RdClockEn:   in std_logic; 
			m_USER_Q:           out std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);       
	
			m_USER_WrClockEn     : in std_logic;
			m_USER_Data    : in std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
			m_USER_WrAddress     : in std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0)

		);
	end component;		
				
	component mt48lc2m32b2
		port(
			Dq:				inout 	std_logic_vector(31 downto 0);
			Addr:			in	std_logic_vector(10 downto 0);
			Ba:				in 	std_logic_vector(1 downto 0);
			Clk:			in 	std_logic;
			Cke:			in 	std_logic;
			Cs_n:			in 	std_logic;
			Ras_n:			in 	std_logic;
			Cas_n:			in	std_logic;
			We_n:			in	std_logic;
			Dqm:			in	std_logic_vector(3 downto 0)
		);
	end component;
	
begin	
	
	
	mt48lc2m32b2_inst : mt48lc2m32b2
		port map(
			Dq => io_sd_data,
			Addr => o_sd_add,
			Ba => o_sd_ba ,
			Clk => o_sd_clk,
			Cke => o_sd_cke,
			Cs_n => o_sd_cs0_l,
			Ras_n => o_sd_ras_l,
			Cas_n => o_sd_cas_l,
			We_n => o_sd_we_l,
			Dqm => (others => '0')
		);
		
	top_inst : top
		port map(
			i_clk => i_clk,
			i_rst => i_rst,
			
			m_sdr_addr      => m_sdr_addr,
		-- m_ebr_addr          : in std_logic_vector (c_EBR_NUM_ADDR - 1 downto 0);
			m_BUSY          => m_BUSY,
			m_ACK           => m_ACK,
			m_Read_Str      => m_Read_Str,
			m_Write_Str     => m_Write_Str,
		
			io_DQ	=> io_sd_data,
			o_A		=> o_sd_add,
			o_BA	=> o_sd_ba,
			o_CKE	=> o_sd_cke,
			o_CSn	=> o_sd_cs0_l,
			o_RASn	=> o_sd_ras_l,
			o_CASn	=> o_sd_cas_l,
			o_WEn	=> o_sd_we_l,
			o_DQM 	=> o_sd_dqm1,
			o_CK	=> o_sd_clk,

			ebr_sdr_select     => ebr_sdr_select,
			ebr_user_select    => ebr_user_select,

			m_USER_WrClockEn    => 	m_WrClockEn,
			m_USER_Data    		=> 	m_EBR_WrData,
			m_USER_WrAddress    =>	m_WrAddress,

			m_USER_RdAddress   => 	m_USER_RdAddress,
			m_USER_RdClockEn   => 	m_USER_RdClockEn,
			m_USER_Q           => 	m_USER_Q
		);
	
	o_sd_cke <= '1';
	o_sd_cs0_l <= '0';
	o_sd_dqm <= (others => '0');
	o_sd_dqm1 <= '0';
end Behavioral;