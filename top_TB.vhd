library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
-- use work.sdr_par.all;
use work.type_def_package.ALL;
entity top_TB is
end entity;

architecture behavioral of top_TB is 

	component top_plus_sdram_model 
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

	end component;


	signal i_rst : std_logic := '0' ;
	signal i_clk : std_logic := '0';
	signal i_sclk : std_logic ;
	signal i_cs : std_logic ;
	signal i_mosi : std_logic ;
	signal i_rx_buf : std_logic := '1';
	constant c_CLK_PERIOD : time := 40 ns;	
	
	constant c_PLL_CLK : time := tCK;

	signal	m_sdr_addr          :  std_logic_vector (c_SDRAM_ADDR_DEPTH - 1 downto 0);
	signal	m_Read_Str          :  std_logic;
	signal	m_Write_Str         :  std_logic;


	constant c_BR : integer :=10;
	signal 	i_send_start :  STD_LOGIC;
	signal io_DQ: std_logic_vector( SDR_DATA_WIDTH-1 downto 0);	
	signal	i_sw1 :  STD_LOGIC;
	signal	i_sw2 :  STD_LOGIC;
	signal	i_sw3 :  STD_LOGIC;
	signal	i_sw4 :  STD_LOGIC;
	signal	m_WrClockEn     :  std_logic := '0';
	signal	m_EBR_WrData    :  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0) := (others => '0') ;
	signal	m_WrAddress     :  std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0) :=((others => '0'));
	signal clk_init : std_Logic := '0';
	signal WrAddress : std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0) :=((others => '0'));
	
	signal	ebr_sdr_select      :  std_logic_vector(c_TOTAL_EBR_WIDTH-1 downto 0);
	signal	ebr_user_select     :  std_logic_vector(c_TOTAL_EBR_WIDTH-1 downto 0);
	
	signal	m_USER_RdAddress:    std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
	signal	m_USER_RdClockEn:    std_logic; 
	signal	m_USER_Q:            std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
	
	signal r_reg : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
	
	signal s_cnt : Natural range 0 to 1023 := 0;
begin	
	dut : top_plus_sdram_model 
		port map(
			i_clk => i_clk,
			i_rst => i_rst,

			m_sdr_addr => m_sdr_addr,
			m_Read_Str  =>  m_Read_Str,
			m_Write_Str =>  m_Write_Str,

			m_WrClockEn     => m_WrClockEn,
			m_EBR_WrData    => m_EBR_WrData,
			m_WrAddress     =>m_WrAddress,

			ebr_sdr_select      =>ebr_sdr_select,
			ebr_user_select     =>ebr_user_select,

			m_USER_RdAddress	=> m_USER_RdAddress,
			m_USER_RdClockEn	=>m_USER_RdClockEn,
			m_USER_Q			=> m_USER_Q

			);
	
	p_clk : process 
	begin
		i_clk <= '0';
		wait for c_CLK_PERIOD/2;
		i_clk <= '1';
		wait for c_CLK_PERIOD/2;
		
	end process;
	
	p_rst : process 
	begin
		i_rst <= '1';
		wait for 25 ns;	
		i_rst <= '0';
	    wait for 20 ms;
		i_rst <= '1';
		wait for 25 ns;	
		i_rst <= '0';
		wait;
	end process;
	
	p_rx : process
	begin

		ebr_sdr_select <= (0 => '1', others => '0'); 
		ebr_user_select <= (0 => '1', others => '0');
		m_Read_Str <=  '0';
		m_Write_Str <= '0';
		m_sdr_addr <= (11=>'1', 1=>'1',others => '0');
		wait for 1 us;
		-- r_reg <= STD_LOGIC_VECTOR(to_unsigned(s_cnt, r_reg'LENGTH));
		wait for (c_SDR_INIT_TIME+10)*c_PLL_CLK;
		
		wait for  4*c_PLL_CLK;	
		m_Write_Str <=  '1';
		wait for c_PLL_CLK;
		m_Write_Str <= '0';
		wait for 255*c_PLL_CLK;

		wait for  20*c_PLL_CLK;	
		m_READ_Str <=  '1';
		wait for c_PLL_CLK;
		m_READ_Str <= '0';
		wait for 255*c_PLL_CLK;


	end process;
	

	p_data_write : process 
	begin


		if s_cnt = 0 then
			m_WrClockEn  <= '1';	
			wait for 15*c_PLL_CLK;
			s_cnt <= s_cnt + 1;
		else
			if s_cnt < 257 then
				r_reg <= r_reg + "00000000000000000000000000000001";
				WrAddress <= WrAddress + "00000001";
				s_cnt <= s_cnt + 1;
				m_WrClockEn    <= '1';
				m_EBR_WrData   <= r_reg;
				m_WrAddress    <= WrAddress;
				wait for c_PLL_CLK;
			else
				m_WrClockEn    <= '0';
				wait for 10 ms;
			end if;

		end if;

	end process;
end Behavioral;
				