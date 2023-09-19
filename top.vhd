library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.type_def_package.all;

entity top is
    port (
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
end entity top;

architecture rtl of top is
    component PLL is
        port (
            CLKI: in  std_logic; 
            CLKOP: out  std_logic);
    end component;

    component SDR_Manager is
        port (
            m_clk   : in std_logic;
            i_rst   : in std_logic;
            
            
            SDRM_sdr_addr      : in std_logic_vector (c_SDRAM_ADDR_DEPTH - 1 downto 0);
            -- m_ebr_addr      : in std_logic_vector (c_EBR_NUM_ADDR - 1 downto 0);
            SDRM_BUSY          : out std_logic;
            SDRM_ACK           : out std_logic;
            SDRM_Read_Str      : in std_logic;
            SDRM_Write_Str     : in std_logic;

            io_DQ			:inout std_logic_vector(SDR_DATA_WIDTH-1 downto 0);
            sdr_A			:out std_logic_vector(10 downto 0);
            sdr_BA			:out std_logic_vector(1 downto 0);
            sdr_CKE			:out std_logic;
            sdr_CSn			:out std_logic;
            sdr_RASn		:out std_logic;
            sdr_CASn		:out std_logic;
            sdr_WEn			:out std_logic;
            sdr_DQM 		:out std_logic;
            sdr_CK          :out std_logic;


            SDRM_WrAddress     : out std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
            SDRM_RdAddress     : out std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 

            SDRM_WrClockEn     : out std_logic;
            SDRM_RdClockEn     : out std_logic;
            
            SDRM_EBR_WrData    : out std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
            SDRM_EBR_RdData    : in std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0)
        );
    end component;

    component bram_union is
        port (
            m_clk           : in std_logic;
            i_rst           : in std_logic;
    
            ebr_sdr_select : in std_logic_vector(c_TOTAL_EBR_WIDTH-1 downto 0);
            ebr_user_select : in std_logic_vector(c_TOTAL_EBR_WIDTH-1 downto 0);
    
            m_SDRAM_WrAddress: in std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
            m_SDRAM_RdAddress: in  std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0);
            m_SDRAM_Data: in  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
            m_SDRAM_RdClockEn: in  std_logic; 
            m_SDRAM_WrClockEn: in  std_logic; 
            m_SDRAM_Q: out  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
        
            m_USER_WrAddress: in std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
            m_USER_RdAddress: in  std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
            m_USER_Data: in  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
            m_USER_RdClockEn: in  std_logic; 
            m_USER_WrClockEn: in  std_logic; 
            m_USER_Q: out  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0)
            );
    end component;

    signal m_clk : std_logic;
    signal  m_WrAddress     :  std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
    signal  m_RdAddress     :  std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 

    signal  m_WrClockEn     :  std_logic;
    signal  m_RdClockEn     :  std_logic;
    
    signal  m_EBR_WrData    :  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
    signal  m_EBR_RdData    :  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);

    signal  ebr_select_add :    std_logic_vector(c_TOTAL_EBR_WIDTH-1 downto 0);
    signal  m_SDR_WrAddress:    std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
    signal  m_SDR_Data:         std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
    signal  m_SDR_WrClockEn:    std_logic; 
    signal  m_WrCMD         : std_logic;
    signal  m_RdCMD         : std_logic;
    
    signal  m_Q_TEST    :  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
begin

    pll_0_inst : pll
    port map (
        CLKI        => i_clk, 
        CLKOP       => m_clk
    );

    sdr_manager_inst: SDR_MANAGER
    port map (
        m_clk       => m_clk,
        i_rst       => i_rst,

        SDRM_sdr_addr      => m_sdr_addr,
        -- m_ebr_addr      => m_ebr_addr,
        SDRM_BUSY          => m_BUSY,
        SDRM_ACK           => m_ACK,
        SDRM_Read_Str      => m_Read_Str,
        SDRM_Write_Str     => m_Write_Str,

        io_DQ           => io_DQ,
        sdr_A			=> o_A,
        sdr_BA			=> o_BA,
        sdr_CKE			=> o_CKE,
        sdr_CSn			=> o_CSn,
        sdr_RASn		=> o_RASn,
        sdr_CASn		=> o_CASn,
        sdr_WEn			=> o_WEn,
        sdr_DQM 		=> o_DQM,
        sdr_CK            => o_CK,

        SDRM_WrAddress     => m_WrAddress,
        SDRM_RdAddress     => m_RdAddress, 

        SDRM_WrClockEn     => m_WrClockEn,
        SDRM_RdClockEn     => m_RdClockEn,
        
        SDRM_EBR_WrData    => m_EBR_WrData,
        SDRM_EBR_RdData    => m_EBR_RdData
    );

    bram_union_inst : bram_union 
    port map ( 
        m_clk               =>  m_clk,
        i_rst               =>  i_rst,
 
        ebr_sdr_select     =>  ebr_sdr_select,
        ebr_user_select    =>  ebr_user_select,

        m_SDRAM_WrAddress     =>  m_WrAddress,  
        m_SDRAM_RdAddress     =>  m_RdAddress,
        m_SDRAM_Data          =>  m_EBR_WrData,
        m_SDRAM_RdClockEn     =>  m_RdClockEn,
        m_SDRAM_WrClockEn     =>  m_WrClockEn,
        m_SDRAM_Q             =>  m_EBR_RdData,

        m_USER_WrAddress    =>  m_USER_WrAddress,  
        m_USER_RdAddress    =>  m_USER_RdAddress,
        m_USER_Data         =>  m_USER_Data,
        m_USER_RdClockEn    =>  m_USER_RdClockEn,
        m_USER_WrClockEn    =>  m_USER_WrClockEn,
        m_USER_Q            =>  m_USER_Q
        
    );


end architecture;