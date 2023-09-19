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
-- This is the data path module of the SDR SDRAM controller reference
-- design.
--
-- --------------------------------------------------------------------
--
-- Revision History :
-- --------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :| Changes Made:
--   V0.1 :|                   :| 06/29/09  :| Pre-Release
--	 V4.3 :| Peter						 :| 10/18/09  :| Added VHDL Support
-- --------------------------------------------------------------------
--
-- This is the data module for a synchronous DRAM controller.
-- 
LIBRARY ieee,STD,work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--
use work.sdr_par.all;
use work.type_def_package.all;
--
ENTITY sdr_data IS
   PORT (
      -----------------------------------------------------------------------
-- inputs
--
      sys_CLK                 : IN std_logic;   
      sys_RESET               : IN std_logic;   
      -----------------------------------------------------------------------
-- bidir
--
      
      -----------------------------------------------------------------------
-- outputs
		m_valid 					:IN STD_LOGIC;   -- couldn't assert D valid without that
      sys_D_VALID             : OUT std_logic;   
      cState                  : IN std_logic_vector(3 DOWNTO 0);   
      clkCNT                  : IN std_logic_vector(7 DOWNTO 0));   
      
END ENTITY sdr_data;

ARCHITECTURE translated OF sdr_data IS

   --SIGNAL regSdrDQ                 :  std_logic_vector(SYS_DATA_WIDTH-1 DOWNTO 0);    --was 16
   SIGNAL enableSysD               :  std_logic;   
   --SIGNAL regSysD                  :  std_logic_vector(SYS_DATA_WIDTH-1 DOWNTO 0);   --was 16
   --SIGNAL regSysDX                 :  std_logic_vector(SYS_DATA_WIDTH-1 DOWNTO 0);   
   --SIGNAL enableSdrDQ              :  std_logic;   
   --SIGNAL stateWRITEA              :  std_logic;   
   -----------------------------------------------------------------------
   --  Read Cycle Data Path
   --
   --SIGNAL temp_hdl2               :  std_logic_vector(SYS_DATA_WIDTH-1 DOWNTO 0);   --was 16

   -----------------------------------------------------------------------
   --  Write Cycle Data Path
   --
   --SIGNAL temp_hdl7               :  std_logic_vector(SYS_DATA_WIDTH-1 DOWNTO 0);   
   --SIGNAL temp_hdl8               :  std_logic;   
   SIGNAL sys_D_VALID_hdl1        :  std_logic;   
   
BEGIN
   sys_D_VALID <= sys_D_VALID_hdl1 ;
   -----------------------------------------------------------------------
   -- sys_D_VALID Generation
   --
   sys_D_VALID_hdl1 <= enableSysD  after tDLY;


   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         enableSysD <= '0' after tDLY;    
      ELSIF falling_edge(sys_CLK) THEN
	 
         IF ((cState = c_rdata) or (m_valid = '1'))then --AND (clkCNT = conv_std_logic_vector(NUM_CLK_READ,8)- "00000001")) THEN   --   
            enableSysD <= '1' after tDLY;    
         ELSE
            enableSysD <= '0' after tDLY;    
         END IF;
      END IF;
   END PROCESS;
   
----------------------------------------------------------------------------------------  
	   
   --temp_hdl8 <= '1' WHEN (cState = c_WRITEA) ELSE '0';
   --stateWRITEA <= temp_hdl8  after tDLY;

   --PROCESS (sys_CLK, sys_RESET)
   --BEGIN
      --IF (sys_RESET = '1') THEN
         --enableSdrDQ <= '0' after tDLY;    
      --ELSIF falling_edge(sys_CLK) THEN
          --IF (cState = c_WRITEA) THEN
            --enableSdrDQ <= '1' after tDLY;
          --ELSIF ((cState = c_wdata) AND (clkCNT = NUM_CLK_WRITE)) THEN
            --enableSdrDQ <= '0' after tDLY;    
         --END IF;
      --END IF;
   --END PROCESS;
   
   
   --temp_hdl2 <= regSdrDQ WHEN (enableSysD) = '1' ELSE (others => 'Z') ;
   --sys_D <= temp_hdl2  after tDLY ;


   --PROCESS (sys_CLK, sys_RESET)
   --BEGIN
      --IF (sys_RESET = '1') THEN
         --regSdrDQ <= (others => '0') after tDLY;    
      --ELSIF falling_edge(sys_CLK) THEN
         --regSdrDQ <= sdr_DQ after tDLY; -- cnt3_sdrdq & cnt2_sdrdq & cnt1_sdrdq & cnt0_sdrdq     
      --END IF;
   --END PROCESS;
   
   
   --temp_hdl7 <= regSysDX WHEN (enableSdrDQ) = '1' ELSE (others => 'Z');
   --sdr_DQ <= temp_hdl7  after tDLY;

   --PROCESS (sys_CLK, sys_RESET)
   --BEGIN
      --IF (sys_RESET = '1') THEN
         --regSysDX <= (others => '0') after tDLY;    
      --ELSIF falling_edge(sys_CLK) THEN
         --IF (cState = c_WRITEA or cState = c_wdata) THEN                      -- changed
            --regSysDX <= regSysD  after tDLY;    
         --END IF;
      --END IF;
   --END PROCESS;
   
   --PROCESS (sys_CLK, sys_RESET)
   --BEGIN
      --IF (sys_RESET = '1') THEN
         --regSysD <= (others => '0') after tDLY;    
      --ELSIF falling_edge(sys_CLK) THEN
         --regSysD <= sys_D after tDLY;    
      --END IF;
   --END PROCESS;

END ARCHITECTURE translated;