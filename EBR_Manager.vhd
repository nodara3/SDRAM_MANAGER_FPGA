library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.type_def_package.all;

entity EBR_Manager is
    port (
        m_clk               : in std_logic;
        i_rst               : in std_logic;

        SDRM_bram_read      : in std_logic;
        SDRM_bram_write     : in std_logic;

        -- SDRM_ebr_addr      : in std_logic_vector (c_EBR_NUSDRM_ADDR - 1 downto 0);
        -- SDRM_ebr_list_addr : out std_logic_vector (c_EBR_NUSDRM_ADDR - 1 downto 0);   

        SDRM_WrAddress      : out std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 
        SDRM_RdAddress      : out std_logic_vector(c_EBR_ADDR_WIDTH-1 downto 0); 

        SDRM_WrClockEn      : out std_logic;
        SDRM_RdClockEn      : out std_logic;
     
        SDRM_EBR_WrData     : out std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
        SDRM_EBR_RdData     : in std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);

        SDRM_SDR_WrData     : out std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
        SDRM_SDR_RdData     : in std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0)

    );
end entity EBR_Manager;

architecture rtl of EBR_Manager is
    signal s_read_addr  : natural range 0 to 2**c_EBR_ADDR_WIDTH-1;
    signal s_write_addr : natural range 0 to 2**c_EBR_ADDR_WIDTH-1;
    
    

begin

    process (m_clk, i_rst)
    begin
       
        if i_rst = '1' then
            s_read_addr <= 0;
            s_write_addr <= 0;


        elsif falling_edge(m_clk) then
            
            if SDRM_bram_read = '1' and s_read_addr < 2**c_EBR_ADDR_WIDTH-1 then
                s_read_addr <= s_read_addr + 1;
            else
                s_read_addr <= 0;     
            end if;

            if SDRM_bram_write = '1' and s_write_addr < 2**c_EBR_ADDR_WIDTH-1 then
                s_write_addr <= s_write_addr + 1;
            else
                s_write_addr <= 0;
            end if;

        end if;
        
    end process;

    SDRM_WrAddress     <= std_logic_vector(to_unsigned(s_write_addr, SDRM_WrAddress'length));
    SDRM_RdAddress     <= std_logic_vector(to_unsigned(s_read_addr, SDRM_RdAddress'length));

    SDRM_WrClockEn     <= SDRM_bram_write;
    SDRM_RdClockEn     <= SDRM_bram_read;

    SDRM_EBR_WrData    <= SDRM_SDR_RdData;
    SDRM_SDR_WrData    <= SDRM_EBR_RdData;

    -- SDRM_ebr_list_addr <= SDRM_ebr_addr;


end architecture;