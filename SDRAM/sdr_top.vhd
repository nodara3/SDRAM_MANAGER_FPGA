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
-- This is the top level module of the SDR SDRAM controller reference
-- design.
--
-- --------------------------------------------------------------------
--
-- Revision History :
-- --------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :| Changes Made:
--   V0.1 :|                   :| 06/29/09  :| Pre-Release
--	 V4.3 :| Peter						 :| 10/18/09	:| Added VHDL Support 	
-- --------------------------------------------------------------------

----------------- changes made by Nodar Vashakmadze from AzRy  --- xx/12/2022 --------------


library ieee;
use ieee.std_logic_1164.all;
library work;
use work.sdr_par.all;
use work.type_def_package.all;

entity sdr_top is
	port(
			sys_R_Wn			:in std_logic;							--read/write signal, high indicates reading and low indicates writing
			sys_ADSn			:in std_logic;							--active low address strobe
			sys_DLY_100US		:in std_logic;							--active high signal notifys controller that sdram has gone through stabilization
			sys_CLK				:in std_logic;							--main clock of system
			sys_RESET			:in std_logic;							--active high signal resets controller to the initial state
			sys_REF_REQ			:in std_logic;							--active high SDRAM refresh request
			sys_REF_ACK			:out std_logic;							--active high refresh request acknowlede
			sys_A				:in std_logic_vector( RA_MSB downto CA_LSB);	--address bus
			--sys_D				:inout std_logic_vector( SYS_DATA_WIDTH-1 downto 0);	--data bus
			sys_D_VALID			:out std_logic;							--active high when reading inicates that data is valid on sys_D 
			sys_CYC_END			:out std_logic;						--active high signal indicates that read/write cycle has been finished 
			sys_INIT_DONE		:out std_logic;							--active high signal indicates finish of SDRAM initialization
			sys_REF_ON			:OUT std_logic;		-- added cause sys_REF_ACK wasn't stayng high during whole refresh cycle, whereas sys_REF_ON becomes high when sys_REF_ACK becomes high stays that way until refresh cycle is over
			--sys_term			:IN STD_LOGIC_VECTOR (1 downto 0);
			
			--sdr_DQ				:inout std_logic_vector( SDR_DATA_WIDTH-1 downto 0);
			sdr_A				:out std_logic_vector(SDR_A_WIDTH-1 downto 0);
			sdr_BA				:out std_logic_vector(1 downto 0);
			sdr_CKE				:out std_logic;
			sdr_CSn				:out std_logic;
			sdr_RASn			:out std_logic;
			sdr_CASn			:out std_logic;
			sdr_WEn				:out std_logic;
			sdr_DQM 			:out std_logic
		);
end sdr_top;

architecture behave of sdr_top is
signal iState :std_logic_vector(3 downto 0); --// INIT_FSM state variables
signal cState :std_logic_vector(3 downto 0); --// CMD_FSM state variables
signal clkCNT :std_logic_vector(7 downto 0); --
signal m_VALID : STD_LOGIc;
-----------------------------------------------------------------------
component sdr_ctrl
			port(
			sys_CLK				: in std_logic;
			sys_RESET			: in std_logic;
			sys_R_Wn			: in std_logic;
			sys_ADSn			: in std_logic;
			sys_DLY_100US	: in std_logic;
			sys_REF_REQ		: in std_logic;
			sys_REF_ACK		: out std_logic;
			sys_REF_ON				: OUT std_logic;		-- added cause sys_REF_ACK wasn't stayng high during whole refresh cycle, whereas sys_REF_ON becomes high when sys_REF_ACK becomes high stays that way until refresh cycle is over
			 m_valid 					:OUT STD_LOGIC;   -- couldn't assert D valid without that
			 
			sys_CYC_END		: out std_logic;
			sys_INIT_DONE	: buffer std_logic;
			iState				: buffer std_logic_vector(3 downto 0);
			cState				: buffer std_logic_vector(3 downto 0);
			clkCNT				: buffer std_logic_vector(7 downto 0)
			);
end component;

component sdr_sig 
		port (   
	--sys_term 				: IN STD_LOGIC_VECTOR (1 downto 0);
		
  	sys_CLK		: in std_logic; 
  	sys_RESET	: in std_logic;
  	sys_A			: in std_logic_vector(RA_MSB downto CA_LSB);   
  	iState		: in std_logic_vector(3 downto 0);  
  	cState		: in std_logic_vector(3 downto 0);  
  	sdr_CKE		: out std_logic; 
  	sdr_CSn		: out std_logic; 
  	sdr_RASn	: out std_logic;
  	sdr_CASn	: out std_logic;
  	sdr_WEn		: out std_logic; 
  	sdr_BA		: out std_logic_vector(SDR_BA_WIDTH-1 downto 0 );  
  	sdr_A		: out std_logic_vector(SDR_A_WIDTH-1 downto 0)   
);                      
end component;

component sdr_data 
	port (                
  sys_CLK			:in std_logic;     
  sys_RESET		:in std_logic;   
  
  m_valid 					:IN STD_LOGIC;   -- couldn't assert D valid without that
  
  --sys_D				:inout std_logic_vector(SYS_DATA_WIDTH-1 downto 0);      
  sys_D_VALID	:out std_logic; 
  cState			:in std_logic_vector(3 downto 0);      
  clkCNT			:in std_logic_vector(7 downto 0)
  --sdr_DQ			:inout std_logic_vector(SDR_DATA_WIDTH-1 downto 0)     
);                           
end component;

begin
state:  sdr_ctrl port map (
		sys_CLK				=> sys_CLK	    ,			
		sys_RESET			=> sys_RESET		,	
		sys_R_Wn			=> sys_R_Wn			,  
		sys_ADSn			=> sys_ADSn			,  
		sys_DLY_100US	=> sys_DLY_100US,	
		sys_REF_REQ		=> sys_REF_REQ	,	
		sys_REF_ACK		=> sys_REF_ACK	,
		
		sys_REF_ON		=> sys_REF_ON,
		m_valid 		=> m_valid,
		
		sys_CYC_END		=> sys_CYC_END	,	
		sys_INIT_DONE	=> sys_INIT_DONE,	
		iState				=> iState				,  
		cState				=> cState				,  
		clkCNT				=> clkCNT				  
		);
address: sdr_sig port map
		(  
			--sys_term => sys_term,
  	sys_CLK		=>sys_CLK		,
  	sys_RESET	=>sys_RESET	,
  	sys_A			=>sys_A			,
  	iState		=>iState		,
  	cState		=>cState		,
  	sdr_CKE		=>sdr_CKE		,
  	sdr_CSn		=>sdr_CSn		,
  	sdr_RASn	=>sdr_RASn	,
  	sdr_CASn	=>sdr_CASn	,
  	sdr_WEn		=>sdr_WEn		,
  	sdr_BA		=>sdr_BA		,
  	sdr_A			=>sdr_A			
);
--
data: sdr_data port map
	 (                                              
  	sys_CLK			=>sys_CLK			 ,  
  	sys_RESET		=>sys_RESET		 ,  
  	--sys_D				=>sys_D				 ,  
	
	m_valid 		=> m_valid,
	
  	sys_D_VALID	=>sys_D_VALID	 ,  
  	cState			=>cState			 ,  
  	clkCNT			=>clkCNT			 
  	--sdr_DQ			=>sdr_DQ			   
		);
--		                                                    
sdr_DQM <= '0' after tDLY ;
end behave;


