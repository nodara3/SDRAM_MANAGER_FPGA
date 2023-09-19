library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.type_def_package.all;

entity SDR_Manager is
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
end entity;

architecture rtl of SDR_Manager is

    component Command_Decoder is
        port (
            m_clk           : in std_logic;
            i_rst           : in std_logic;
            
            -- m_ebr_addr      : in std_logic_vector (c_EBR_NUM_ADDR - 1 downto 0);
            SDRM_BUSY          : out std_logic;
            SDRM_ACK           : out std_logic;
            SDRM_Read_Str      : in std_logic;
            SDRM_Write_Str     : in std_logic;
            SDRM_mux_addr      : out std_logic_vector(1 downto 0);                     --"10" is read comand and "01" is write comand
            SDRM_BUSY_RW       : in std_logic;
        
            SDRM_SDRAM_addr    : out std_logic_vector (c_SDRAM_ADDR_DEPTH - 1 downto 0);
            SDRM_sdr_addr      : in std_logic_vector (c_SDRAM_ADDR_DEPTH - 1 downto 0);
            sys_INIT_Done   : in std_logic  ---sdr init done
        );
    end component;

    component Command_MUX is
        port (
            SDRM_mux_addr      :in std_Logic_vector(1 downto 0);
            SDRM_BUSY_RW       :out std_logic;
            SDRM_Busy_write    :in std_logic;
            SDRM_Busy_Read     :in std_logic;       
            SDRM_read_command  :out std_logic;
            SDRM_write_command :out std_logic
            
        );
    end component;

    component SDR_INIT is
        port (
            m_clk           : in std_logic;
            i_rst           : in std_logic;
            sys_DLY_100US   : out std_logic  
            
        );
    end component;

    component SDR_Write is
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
    end component;

    component SDR_Read is
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
    end component;

    component sdr_top is
        port (
            sys_R_Wn		:in std_logic;							--read/write signal, high indicates reading and low indicates writing
			sys_ADSn		:in std_logic;							--active low address strobe
			sys_DLY_100US	:in std_logic;							--active high signal notifys controller that sdram has gone through stabilization
			sys_CLK			:in std_logic;							--main clock of system
			sys_RESET		:in std_logic;							--active high signal resets controller to the initial state
			sys_REF_REQ		:in std_logic;							--active high SDRAM refresh request
			sys_REF_ACK		:out std_logic;							--active high refresh request acknowlede
			sys_A			:in std_logic_vector( RA_MSB downto CA_LSB);	--address bus
			sys_D_VALID		:out std_logic;							--active high when reading inicates that data is valid on sys_D 
			sys_CYC_END		:out std_logic;							--active high signal indicates that read/write cycle has been finished 
			sys_INIT_DONE	:out std_logic;							--active high signal indicates finish of SDRAM initialization
			sys_REF_ON		:OUT std_logic;		-- added cause sys_REF_ACK wasn't stayng high during whole refresh cycle, whereas sys_REF_ON becomes high when sys_REF_ACK becomes high stays that way until refresh cycle is over
			
			sdr_A			:out std_logic_vector(10 downto 0);
			sdr_BA			:out std_logic_vector(1 downto 0);
			sdr_CKE			:out std_logic;
			sdr_CSn			:out std_logic;
			sdr_RASn		:out std_logic;
			sdr_CASn		:out std_logic;
			sdr_WEn			:out std_logic;
			sdr_DQM 		:out std_logic
            
        );
    end component;

    component SDR_MUX is
        port (
		
            sys_R_Wn		:OUT std_logic;							
            sys_ADSn		:OUT std_logic;							
            sys_A			:OUT std_logic_vector( RA_MSB downto CA_LSB);	
            sys_REF_REQ 	:OUT STD_LOGIC;			
        
            sys_R_Wn1		:IN std_logic;							
            sys_ADSn1		:IN std_logic;							
            sys_A1			:IN std_logic_vector( RA_MSB downto CA_LSB);
            sys_REF_REQ1 	:IN STD_LOGIC;
        
            sys_R_Wn2		:IN std_logic;							
            sys_ADSn2		:IN std_logic;							
            sys_A2			:IN std_logic_vector( RA_MSB downto CA_LSB);	
            sys_REF_REQ2 	:IN STD_LOGIC;	
            
            SDRM_sdr_mux		:IN STD_LOGIC_VECTOR(1 downto 0)
            
        );
    end component;

    component Ebr_Manager is
        port (
            m_clk           : in std_logic;
            i_rst           : in std_logic;
    
            SDRM_bram_read     : in std_logic;
            SDRM_bram_write    : in std_logic;
    
            SDRM_WrAddress     : out std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
            SDRM_RdAddress     : out std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
    
            SDRM_WrClockEn     : out std_logic;
            SDRM_RdClockEn     : out std_logic;
         
            SDRM_EBR_WrData    : out std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
            SDRM_EBR_RdData    : in std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
    
            SDRM_SDR_WrData    : out std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
            SDRM_SDR_RdData    : in std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0)

        );
    end component;


    -----=========== PORT MAP SIGNALS =============================----------

    
    ----- command decoder ----

    signal m_mux_addr           : std_logic_vector(1 downto 0);
    signal m_BUSY_RW            : std_logic;
    signal m_sdram_addr         : std_logic_vector (c_SDRAM_ADDR_DEPTH - 1 downto 0);
    
    ----- command mux ------
    signal m_Busy_Read          : std_logic;
    signal m_Busy_write         : std_logic;
    signal m_read_command       : std_logic;
    signal m_write_command      : std_logic;

    -----   sdr mux -----
    signal  sys_R_Wn1			: std_logic;							
    signal  sys_ADSn1			: std_logic;							
    signal  sys_A1				: std_logic_vector( RA_MSB downto CA_LSB);
    signal  sys_REF_REQ1 		: STD_LOGIC;

    signal  sys_R_Wn2			: std_logic;							
    signal  sys_ADSn2			: std_logic;							
    signal  sys_A2				: std_logic_vector( RA_MSB downto CA_LSB);	
    signal  sys_REF_REQ2 		: STD_LOGIC;	


    ---------sdr controller-------------
    signal  sys_R_Wn			: std_logic;							
    signal  sys_ADSn			: std_logic;							
    signal  sys_DLY_100US		: std_logic;							
							
    signal  sys_REF_REQ			: std_logic;							
    signal  sys_REF_ACK			: std_logic;							
    signal  sys_A				: std_logic_vector( RA_MSB downto CA_LSB);	
    signal  sys_D_VALID			: std_logic;							
    signal  sys_CYC_END			: std_logic;							
    signal  sys_INIT_DONE		: std_logic;							
    signal  sys_REF_ON			: std_logic;

    ---------- ebr manager ---------------
    signal  m_bram_read         : std_logic;
    signal  m_bram_write        : std_logic;
   
    signal  m_SDR_WrData        : std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
    signal  m_SDR_RdData        : std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);

      
begin

    comm_dec_inst : Command_Decoder
    port map (
        m_clk           =>  m_clk,
        i_rst           =>  i_rst,
  
        SDRM_BUSY          =>  SDRM_BUSY,
        SDRM_ACK           =>  SDRM_ACK,
        SDRM_Read_Str      =>  SDRM_Read_Str,
        SDRM_Write_Str     =>  SDRM_Write_Str,
        SDRM_mux_addr      =>  m_mux_addr,
        SDRM_BUSY_RW       =>  m_BUSY_RW,
        SDRM_sdram_addr    =>  m_sdram_addr,
        SDRM_sdr_addr      =>  SDRM_sdr_addr,
        sys_INIT_Done   =>  sys_INIT_Done
    );

    comm_mux_inst : Command_Mux
    port map (
        SDRM_mux_addr      =>  m_mux_addr,
        SDRM_BUSY_RW       =>  m_BUSY_RW,
        SDRM_Busy_write    =>  m_Busy_write,
        SDRM_Busy_Read     =>  m_Busy_Read,
        SDRM_read_command  =>  m_read_command,
        SDRM_write_command =>  m_write_command
    );

    sdr_init_inst : SDR_INIT 
    port map (
        m_clk           =>  m_clk,
        i_rst           =>  i_rst,
        sys_DLY_100US   =>  sys_DLY_100US
    );


    sdr_write_inst: SDR_Write
    port map (
        i_rst               => i_rst,
        m_clk               => m_clk,

        SDRM_sdram_addr          => m_sdram_addr,
        SDRM_SDR_WrData        => m_SDR_WrData,
        SDRM_bram_read         => m_bram_read,
        SDRM_write_command     => m_write_command,
        SDRM_Busy_Write        => m_Busy_Write,

        sys_R_Wn			=> sys_R_Wn1,
        sys_ADSn			=> sys_ADSn1,
        sys_REF_REQ			=> sys_REF_REQ1,
        sys_REF_ON			=> sys_REF_ON,
        sys_A				=> sys_A1,
        sys_D				=> io_Dq,
        sys_CYC_END			=> sys_CYC_END
        
    );
        
    sdr_read_inst : SDR_Read
    port map (
        i_rst               => i_rst,
        m_clk               => m_clk,

        SDRM_sdram_addr        => m_sdram_addr,
        SDRM_SDR_RdData        => m_SDR_RdData,
        SDRM_bram_write        => m_bram_write,
        SDRM_read_command      => m_read_command,
        SDRM_Busy_Read         => m_Busy_Read,

        sys_R_Wn			=> sys_R_Wn2,
        sys_ADSn			=> sys_ADSn2,
        sys_REF_REQ			=> sys_REF_REQ2,
        sys_REF_ON			=> sys_REF_ON,
        sys_D_valid         => sys_D_valid,
        sys_A				=> sys_A2,
        sys_D				=> io_Dq,
        sys_CYC_END			=> sys_CYC_END

    );


    sdr_mux_inst : SDR_MUX
    port map (
        sys_R_Wn        =>  sys_R_Wn,							
        sys_ADSn		=>  sys_ADSn,
        sys_A			=>  sys_A,
        sys_REF_REQ 	=>  sys_REF_REQ,
    
        sys_R_Wn1		=>  sys_R_Wn1,			
        sys_ADSn1		=>  sys_ADSn1,					
        sys_A1			=>  sys_A1,
        sys_REF_REQ1 	=>  sys_REF_REQ1,
    
        sys_R_Wn2		=>  sys_R_Wn2,				
        sys_ADSn2		=>  sys_ADSn2,					
        sys_A2			=>  sys_A2,
        sys_REF_REQ2 	=>  sys_REF_REQ2,
        
        SDRM_sdr_mux		=>  m_mux_addr
    );

    sdr_ctrl_inst  : sdr_top
    port map (
        sys_R_Wn			=>  sys_R_Wn,
        sys_ADSn			=>  sys_ADSn,  
        sys_DLY_100US		=>  sys_DLY_100US,
        sys_CLK				=>  m_clk,
        sys_RESET			=>  i_rst,
        sys_REF_REQ			=>  sys_REF_REQ,
        sys_REF_ACK			=>  sys_REF_ACK,
        sys_A				=>  sys_A,
        sys_D_VALID			=>  sys_D_VALID,
        sys_CYC_END			=>  sys_CYC_END,
        sys_INIT_DONE		=>  sys_INIT_DONE,
        sys_REF_ON			=>  sys_REF_ON,
        
        sdr_A				=>  sdr_A,
        sdr_BA				=>  sdr_BA,
        sdr_CKE				=>  sdr_CKE,
        sdr_CSn				=>  sdr_CSn,
        sdr_RASn			=>  sdr_RASn,
        sdr_CASn			=>  sdr_CASn,
        sdr_WEn				=>  sdr_WEn,
        sdr_DQM 			=>  sdr_DQM
    );

    ebr_manager_inst : ebr_manager
    port map (
        m_clk           =>  m_clk,
        i_rst           =>  i_rst,

        SDRM_bram_read     =>  m_bram_read,
        SDRM_bram_write    =>  m_bram_write,

        SDRM_WrAddress     =>  SDRM_WrAddress,
        SDRM_RdAddress     =>  SDRM_RdAddress,

        SDRM_WrClockEn     =>  SDRM_WrClockEn,
        SDRM_RdClockEn     =>  SDRM_RdClockEn,
        
        SDRM_EBR_WrData    =>  SDRM_EBR_WrData,
        SDRM_EBR_RdData    =>  SDRM_EBR_RdData,

        SDRM_SDR_WrData    =>  m_SDR_WrData,
        SDRM_SDR_RdData    =>  m_SDR_RdData
    );

    sdr_CK <= m_clk;
    

end architecture;