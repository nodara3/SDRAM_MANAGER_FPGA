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
-- This file contains the parameters used in the SDR SDRAM controller
-- reference design.
--
-- --------------------------------------------------------------------
--
-- Revision History :
-- --------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :| Changes Made:
--   V0.1 :|                   :| 06/29/09  :| Pre-Release
-- --------------------------------------------------------------------

----------------- changes made by Nodar Vashakmadze from AzRy  --- xx/12/2022 --------------

library ieee;               
use ieee.std_logic_1164.all;
package sdr_par is
constant tDLY:time := 2 ns; -- 2ns delay for simulation purpose

-----------------------------------------------------------------------
--//---------------------------------------------------------------------
--// INIT_FSM state variable assignments (gray coded)
--//

constant i_NOP   :std_logic_vector(3 downto 0):= "0000";
constant i_PRE   :std_logic_vector(3 downto 0):= "0001";
constant i_tRP   :std_logic_vector(3 downto 0):= "0010";
constant i_AR1   :std_logic_vector(3 downto 0):= "0011";
constant i_tRFC1 :std_logic_vector(3 downto 0):= "0100";
constant i_AR2   :std_logic_vector(3 downto 0):= "0101";
constant i_tRFC2 :std_logic_vector(3 downto 0):= "0110";
constant i_MRS   :std_logic_vector(3 downto 0):= "0111";
constant i_tMRD  :std_logic_vector(3 downto 0):= "1000";
constant i_ready :std_logic_vector(3 downto 0):= "1001";

-----------------------------------------------------------------------
-- CMD_FSM state variable assignments (gray coded)
--

constant c_idle  :std_logic_vector(3 downto 0) := "0000";
constant c_tRCD  :std_logic_vector(3 downto 0) := "0001";
constant c_cl    :std_logic_vector(3 downto 0) := "0010";
constant c_rdata :std_logic_vector(3 downto 0) := "0011";
constant c_wdata :std_logic_vector(3 downto 0) := "0100";
constant c_tRFC  :std_logic_vector(3 downto 0) := "0101";
constant c_tDAL  :std_logic_vector(3 downto 0) := "0110";
constant c_ACTIVE:std_logic_vector(3 downto 0) := "1000";
constant c_READA :std_logic_vector(3 downto 0) := "1001";
constant c_WRITEA:std_logic_vector(3 downto 0) := "1010";
constant c_AR    :std_logic_vector(3 downto 0) := "1011";
constant c_BS    :std_logic_vector(3 downto 0) := "1100";  -- burst stop
constant c_PRE   :std_logic_vector(3 downto 0) := "1101";  -- precharge
-----------------------------------------------------------------------
-- SDRAM commands (sdr_CSn, sdr_RASn, sdr_CASn, sdr_WEn)
--

constant INHIBIT           :std_logic_vector(3 downto 0) := "1111";
constant NOP               :std_logic_vector(3 downto 0) := "0111";
constant ACTIVE1            :std_logic_vector(3 downto 0) := "0011";
constant READ1              :std_logic_vector(3 downto 0) := "0101";
constant WRITE1             :std_logic_vector(3 downto 0) := "0100";
constant BURST_TERMINATE   :std_logic_vector(3 downto 0) := "0110";
constant PRECHARGE         :std_logic_vector(3 downto 0) := "0010";
constant AUTO_REFRESH      :std_logic_vector(3 downto 0) := "0001";
constant LOAD_MODE_REGISTER:std_logic_vector(3 downto 0) := "0000";

end sdr_par;