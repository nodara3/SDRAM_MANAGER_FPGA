library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.type_def_package.all;

entity bram_union is
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
end entity bram_union;

architecture rtl of bram_union is

    component ebr_0 is
        port (
            WrAddress: in  std_logic_vector(c_EBR_ADDR_WIDTH downto 0); 
            RdAddress: in  std_logic_vector(c_EBR_ADDR_WIDTH downto 0); 
            Data: in  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0); 
            WE: in  std_logic; 
            RdClock: in  std_logic; 
            RdClockEn: in  std_logic; 
            Reset: in  std_logic; 
            WrClock: in  std_logic; 
            WrClockEn: in  std_logic; 
            Q: out  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0)
            );
    end component;

    component ebr_1 is
        port (
            WrAddress: in  std_logic_vector(c_EBR_ADDR_WIDTH downto 0); 
            RdAddress: in  std_logic_vector(c_EBR_ADDR_WIDTH downto 0); 
            Data: in  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0); 
            WE: in  std_logic; 
            RdClock: in  std_logic; 
            RdClockEn: in  std_logic; 
            Reset: in  std_logic; 
            WrClock: in  std_logic; 
            WrClockEn: in  std_logic; 
            Q: out  std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0)
            );
    end component;

    signal  s_WE_0 : std_logic_vector (c_TOTAL_EBR-1 downto 0);
    signal  s_WE_1 : std_logic_vector (c_TOTAL_EBR-1 downto 0);
    signal  s_read_0_en : std_logic_vector(c_TOTAL_EBR-1 downto 0);
    signal  s_read_1_en : std_logic_vector(c_TOTAL_EBR-1 downto 0);
    signal  s_write_0_en : std_logic_vector(c_TOTAL_EBR-1 downto 0);
    signal  s_write_1_en : std_logic_vector(c_TOTAL_EBR-1 downto 0);
    signal  r_user_Q : t_BRAM_DATA;
    signal  r_sdram_Q : t_BRAM_DATA;

    signal  s_sdram_RdAddr : std_Logic_vector(c_EBR_ADDR_WIDTH downto 0); 
    signal  s_user_RdAddr : std_Logic_vector(c_EBR_ADDR_WIDTH downto 0); 
    signal  s_sdram_WrAddr : std_Logic_vector(c_EBR_ADDR_WIDTH downto 0); 
    signal  s_user_WrAddr : std_Logic_vector(c_EBR_ADDR_WIDTH downto 0); 
begin

    s_sdram_RdAddr <=   std_logic_vector(to_unsigned((to_integer(unsigned(m_SDRAM_RdAddress))), c_EBR_ADDR_WIDTH+1)) when ebr_sdr_select(0) = '0' else 
                        std_logic_vector(to_unsigned((to_integer(unsigned(m_SDRAM_RdAddress)) + c_EBR_DATA_DEPTH), c_EBR_ADDR_WIDTH+1));
    s_user_RdAddr <=   std_logic_vector(to_unsigned((to_integer(unsigned(m_USER_RdAddress))), c_EBR_ADDR_WIDTH+1)) when ebr_user_select(0) = '0' else 
                        std_logic_vector(to_unsigned((to_integer(unsigned(m_USER_RdAddress)) + c_EBR_DATA_DEPTH), c_EBR_ADDR_WIDTH+1));
    s_sdram_WrAddr <=   std_logic_vector(to_unsigned((to_integer(unsigned(m_SDRAM_WrAddress))), c_EBR_ADDR_WIDTH+1)) when ebr_sdr_select(0) = '0' else 
                        std_logic_vector(to_unsigned((to_integer(unsigned(m_SDRAM_WrAddress)) + c_EBR_DATA_DEPTH), c_EBR_ADDR_WIDTH+1));
    s_user_WrAddr <=   std_logic_vector(to_unsigned((to_integer(unsigned(m_USER_WrAddress))), c_EBR_ADDR_WIDTH+1)) when ebr_user_select(0) = '0' else 
                        std_logic_vector(to_unsigned((to_integer(unsigned(m_USER_WrAddress)) + c_EBR_DATA_DEPTH), c_EBR_ADDR_WIDTH+1));

    
    ebr_gen : for i in 0 to c_TOTAL_EBR-1 generate

        s_read_0_en(i) <= '1' when ebr_user_select = std_logic_vector(to_unsigned(i, c_TOTAL_EBR_WIDTH)) and m_USER_RdClockEn ='1' else '0';
        s_read_1_en(i) <= '1' when ebr_sdr_select = std_logic_vector(to_unsigned(i, c_TOTAL_EBR_WIDTH)) and m_SDRAM_RdClockEn = '1' else '0'; 
        s_write_0_en(i) <= '1' when ebr_sdr_select = std_logic_vector(to_unsigned(i, c_TOTAL_EBR_WIDTH)) and m_SDRAM_WrClockEn ='1' else '0';
        s_write_1_en(i) <= '1' when ebr_user_select = std_logic_vector(to_unsigned(i, c_TOTAL_EBR_WIDTH)) and m_USER_WrClockEn = '1' else '0'; 

        s_WE_0(i) <= '1' when ebr_sdr_select = std_logic_vector(to_unsigned(i, c_TOTAL_EBR_WIDTH)) and m_SDRAM_WrClockEn = '1' else '0';    
        s_WE_1(i) <= '1' when ebr_user_select = std_logic_vector(to_unsigned(i, c_TOTAL_EBR_WIDTH)) and m_USER_WrClockEn = '1' else '0'; 
        
        ebr_0_inst : ebr_0 
        port map ( 
            WrAddress   => s_sdram_WrAddr,
            RdAddress   => s_user_RdAddr,
            Data        => m_SDRAM_Data,
            WE          => s_WE_0(i),
            RdClock     => not m_clk,
            RdClockEn   => s_read_0_en(i),
            Reset       => i_rst, 
            WrClock     => not m_clk,
            WrClockEn   => s_write_0_en(i),
            Q           => r_user_Q(i) 
        );

        ebr_1_inst : ebr_1 
        port map ( 
            WrAddress   => s_user_WrAddr,
            RdAddress   =>  s_sdram_RdAddr,
            Data        => m_USER_Data,
            WE          => s_WE_1(i),
            RdClock     => not m_clk,
            RdClockEn   =>  s_read_1_en(i),
            Reset       => i_rst, 
            WrClock     => not m_clk,
            WrClockEn   => s_write_1_en(i),
            Q           => r_sdram_Q(i) 
        );
    end generate;
       

    m_USER_Q   <= r_user_Q(to_integer(unsigned(ebr_user_select))); 
    m_SDRAM_Q  <= r_sdram_Q(to_integer(unsigned(ebr_sdr_select)));  


end architecture; 