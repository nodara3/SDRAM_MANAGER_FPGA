--   ==================================================================
--   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
--   ------------------------------------------------------------------
--   Copyright (c) 2013 by Lattice Semiconductor Corporation
--   ALL RIGHTS RESERVED
--   ------------------------------------------------------------------
--
--   Permission:
--
--      Lattice SG Pte. Ltd. grants permission to use this code
--      pursuant to the terms of the Lattice Reference Design License Agreement.
--
--
--   Disclaimer:
--
--      This VHDL or Verilog source code is intended as a design reference
--      which illustrates how these types of functions can be implemented.
--      It is the user's responsibility to verify their design for
--      consistency and functionality through the use of formal
--      verification methods.  Lattice provides no warranty
--      regarding the use or functionality of this code.
--
--   --------------------------------------------------------------------
--
--                  Lattice SG Pte. Ltd.
--                  101 Thomson Road, United Square #07-02
--                  Singapore 307591
--
--
--                  TEL: 1-800-Lattice (USA and Canada)
--                       +65-6631-2000 (Singapore)
--                       +1-503-268-8001 (other locations)
--
--                  web: http:--www.latticesemi.com/
--                  email: techsupport@latticesemi.com
--
--   --------------------------------------------------------------------
--
-- This is the signal module of the SDR SDRAM controller reference
-- design which generates all signals required to interface with the
-- SDR SDRAM.
--
-- --------------------------------------------------------------------
--
-- Revision History :
-- --------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :| Changes Made:
--   V0.1 :|                   :| 06/29/09  :| Pre-Release
--   V4.3 :| Peter             :| 10/18/09  :| Added Vhdl Support
-- --------------------------------------------------------------------

----------------- changes made by Nodar Vashakmadze from AzRy  --- xx/12/2022 --------------

library ieee, std, work;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  --
  use work.sdr_par.all;
  use work.type_def_package.all;
--

entity sdr_sig is
  port (
    -----------------------------------------------------------------------
    -- inputs
    --
    -- sys_term       : IN STD_LOGIC_VECTOR (1 downto 0);

    sys_clk   : in    std_logic;
    sys_reset : in    std_logic;
    sys_a     : in    std_logic_vector(RA_MSB downto CA_LSB);
    istate    : in    std_logic_vector(3 downto 0);
    cstate    : in    std_logic_vector(3 downto 0);
    -----------------------------------------------------------------------
    -- outputs
    --

    sdr_cke  : out   std_logic;
    sdr_csn  : out   std_logic;
    sdr_rasn : out   std_logic;
    sdr_casn : out   std_logic;
    sdr_wen  : out   std_logic;
    sdr_ba   : out   std_logic_vector(SDR_BA_WIDTH - 1 downto 0);
    sdr_a    : out   std_logic_vector(SDR_A_WIDTH - 1 downto 0)
  );
end entity sdr_sig;

architecture translated of sdr_sig is

  attribute syn_keep : boolean;

  signal sdr_cke_hdl  : std_logic;
  signal sdr_csn_hdl  : std_logic;
  signal sdr_rasn_hdl : std_logic;
  signal sdr_casn_hdl : std_logic;
  signal sdr_wen_hdl  : std_logic;
  signal sdr_ba_hdl   : std_logic_vector(SDR_BA_WIDTH - 1 downto 0);
  signal sdr_a_hdl    : std_logic_vector(SDR_A_WIDTH - 1 downto 0);

  -- signal s_sys_term        : STD_LOGIC_VECTOR (1 downto 0);
  attribute syn_keep of sdr_csn_hdl : signal is true;

begin

  sdr_cke  <= sdr_cke_hdl;
  sdr_csn  <= sdr_csn_hdl;
  sdr_rasn <= sdr_rasn_hdl;
  sdr_casn <= sdr_casn_hdl;
  sdr_wen  <= sdr_wen_hdl;
  sdr_ba   <= sdr_ba_hdl;
  sdr_a    <= sdr_a_hdl;

  -----------------------------------------------------------------------
  -- SDR SDRAM Control Singals
  --

  process (sys_clk, sys_reset) is
  begin

    if (sys_reset = '1') then
      (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= INHIBIT  after tDLY;
      sdr_cke_hdl                                            <= '0'  after tDLY;
      sdr_ba_hdl                                             <= (OTHERS => '1') after tDLY;
      sdr_a_hdl                                              <= (OTHERS => '1') after tDLY;
    elsif falling_edge(sys_clk) then
      -- s_sys_term <= sys_term;
      case istate is

        when (i_tRP) |
             (i_tRFC1) |
             (i_tRFC2) |
             (i_tMRD) |
             (i_NOP) =>

          (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= NOP  after tDLY;
          sdr_cke_hdl                                            <= '1'  after tDLY;
          sdr_ba_hdl                                             <= (OTHERS => '1')after tDLY;
          sdr_a_hdl                                              <= (OTHERS => '1')after tDLY;

        when i_PRE =>

          (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= PRECHARGE  after tDLY;
          sdr_cke_hdl                                            <= '1'  after tDLY;
          sdr_ba_hdl                                             <= (OTHERS => '1')after tDLY;
          sdr_a_hdl                                              <= (OTHERS => '1')after tDLY;

        when (i_AR1) | (i_AR2) =>

          (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= AUTO_REFRESH  after tDLY;
          sdr_cke_hdl                                            <= '1'  after tDLY;
          sdr_ba_hdl                                             <= (OTHERS => '1')after tDLY;
          sdr_a_hdl                                              <= (OTHERS => '1')after tDLY;

        when i_MRS =>

          (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= LOAD_MODE_REGISTER  after tDLY;
          sdr_cke_hdl                                            <= '1'  after tDLY;
          sdr_ba_hdl                                             <= (OTHERS => '0')after tDLY;
          sdr_a_hdl                                              <= "0" & MR_Write_Burst_Mode & MR_Operation_Mode & MR_CAS_Latency & MR_Burst_Type & MR_Burst_Length  after tDLY;

        when i_ready =>

          case cstate is

            when (c_idle) |
                 (c_tRCD) |
                 (c_tRFC) |
                 (c_cl) |
                 (c_rdata) |
                 (c_wdata) =>

              (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= NOP  after tDLY;
              sdr_cke_hdl                                            <= '1'  after tDLY;
              sdr_ba_hdl                                             <= (OTHERS => '1')after tDLY;
              sdr_a_hdl                                              <= (OTHERS => '1')after tDLY;

            when c_ACTIVE =>

              (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= ACTIVE1  after tDLY;
              sdr_cke_hdl                                            <= '1'  after tDLY;
              sdr_ba_hdl                                             <= sys_a(BA_MSB downto BA_LSB) after tDLY;                                                                   -- bank
              sdr_a_hdl                                              <= sys_a(RA_MSB downto RA_LSB) after tDLY;                                                                   -- row
            -- column
            -- enable auto precharge

            when c_READA =>

              (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= READ1  after tDLY;
              sdr_cke_hdl                                            <= '1'  after tDLY;
              sdr_ba_hdl                                             <= sys_a(BA_MSB downto BA_LSB) after tDLY;                                                                   -- bank
              -- column
              -- 2 '0'(burst length 4)

              ----------------------- changed ---------------------- casue A10 wasn't becoming high for read and then auto precharge
              -- was --  sdr_A_hdl <= sys_A(CA_MSB) & '1' & sys_A(CA_MSB - 1 downto CA_LSB) & "00"  after tDLY;
              sdr_a_hdl <= '0' & "00" & sys_a(CA_MSB downto CA_LSB)   after tDLY;
            ------------------------------------------------------

            -- column
            -- enable auto precharge

            when c_WRITEA =>

              (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= WRITE1  after tDLY;
              sdr_cke_hdl                                            <= '1'  after tDLY;
              sdr_ba_hdl                                             <= sys_a(BA_MSB downto BA_LSB)  after tDLY;                                                                  -- bank
              -- column
              -- 2 '0'(burst length 4)

              ----------------------- changed ---------------------- casue A10 wasn't becoming high for read and then auto precharge
              -- was --  sdr_A_hdl <= sys_A(CA_MSB) & '1' & sys_A(CA_MSB - 1 downto CA_LSB) & "00"  after tDLY;
              sdr_a_hdl <= '0' & "00" & sys_a(CA_MSB downto CA_LSB)  after tDLY;
            ------------------------------------------------------

            when c_PRE =>

              (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= PRECHARGE  after tDLY;
              sdr_cke_hdl                                            <= '1'  after tDLY;
              sdr_ba_hdl                                             <= (OTHERS => '1')after tDLY;
              sdr_a_hdl                                              <= (OTHERS => '1')after tDLY;

            when c_BS =>

              (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= BURST_TERMINATE  after tDLY;
              sdr_cke_hdl                                            <= '1'  after tDLY;
              sdr_ba_hdl                                             <= (OTHERS => '1')after tDLY;
              sdr_a_hdl                                              <= (OTHERS => '1')after tDLY;

            when c_AR =>

              (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= AUTO_REFRESH  after tDLY;
              sdr_cke_hdl                                            <= '1'  after tDLY;
              sdr_ba_hdl                                             <= (OTHERS => '1')after tDLY;
              sdr_a_hdl                                              <= (OTHERS => '1')after tDLY;

            when OTHERS =>

              (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= NOP  after tDLY;
              sdr_cke_hdl                                            <= '1'  after tDLY;
              sdr_ba_hdl                                             <= (OTHERS => '1')after tDLY;
              sdr_a_hdl                                              <= (OTHERS => '1')after tDLY;

          end case;

        when OTHERS =>

          (sdr_csn_hdl, sdr_rasn_hdl, sdr_casn_hdl, sdr_wen_hdl) <= NOP  after tDLY;
          sdr_cke_hdl                                            <= '1'  after tDLY;
          sdr_ba_hdl                                             <= (OTHERS => '1')after tDLY;
          sdr_a_hdl                                              <= (OTHERS => '1')after tDLY;

      end case;

    ---------------- precharge all ------------------

    -- IF sys_term(1) = '1' and s_sys_term(1) = '0' THEN
    -- sdr_BA_hdl <= (OTHERS => '0')after tDLY;
    -- sdr_A_hdl <= (OTHERS => '1')after tDLY;
    -- sdr_RASn_hdl <= '0' after tDLY;
    -- sdr_WEn_hdl   <= '0' after tDLY;
    -- END IF;

    -------------  burst stop --------------
    -- IF sys_term(0) = '1' and s_sys_term(0) = '0' THEN
    -- sdr_WEn_hdl   <= '0' after tDLY;
    -- END IF;
    end if;

  end process;

end architecture translated;
