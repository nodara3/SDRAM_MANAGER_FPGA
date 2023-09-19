library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.math_real.all;
use work.type_def_package.all;
entity Command_Decoder is
  port (
    m_clk           : in std_logic;
    i_rst           : in std_logic;
    -- SDRM_ebr_addr      : in std_logic_vector (c_EBR_NUSDRM_ADDR - 1 downto 0);
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
end entity;

architecture rtl of Command_Decoder is

  signal s_write_str : std_Logic;
  signal s_read_str  : std_logic;
  signal s_busy_in  : std_Logic;
  signal s_sys_INIT_Done : std_logic;
  
begin
    
  p_busy : process (all)
  begin

    if i_rst = '1' then

      SDRM_BUSY          <= '0';
      s_read_str      <= '0';
      s_write_str     <= '0';
      s_busy_in       <= '0';
      SDRM_mux_addr      <= "00";
      s_sys_INIT_Done <= '0';
      SDRM_SDRAM_addr    <= (others => '0');
      
    elsif falling_edge(m_clk) then

      s_read_str <= SDRM_Read_Str;
      s_write_str <= SDRM_Write_Str;
      s_busy_in <= SDRM_BUSY_RW;
      s_sys_INIT_Done <= sys_INIT_Done;

      if sys_INIT_Done = '1' and s_sys_INIT_Done = '0' then
        SDRM_BUSY <= '0';
      end if;

      if sys_INIT_Done = '1' then

        if SDRM_BUSY_RW = '0' and SDRM_BUSY = '0' then

          if s_read_str = '0' and SDRM_Read_Str = '1' then
            SDRM_BUSY <= '1';
            SDRM_mux_addr <= "10";
            SDRM_SDRAM_addr <= SDRM_sdr_addr;
          end if;

          if s_write_str = '0' and SDRM_Write_Str = '1' then
            SDRM_BUSY <= '1';
            SDRM_mux_addr <= "01";
            SDRM_SDRAM_addr <= SDRM_sdr_addr;
          end if;
        end if;

        if s_busy_in = '1' and SDRM_BUSY_RW = '0' then
          SDRM_BUSY <= '0';
          SDRM_mux_addr <= "00";
        end if;
      else
        SDRM_BUSY <= '1';
      end if;
    end if;
  end process;
  
end architecture;