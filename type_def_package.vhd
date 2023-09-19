library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

package type_def_package is

	constant tCK  :time:= 10 ns;
	
--=======================================================================================---
	--- SDRAM MANAGER CONSTANTS 
	constant t_INIT : time := 100 us;
	constant c_SDR_INIT_TIME : natural := t_INIT/tCK;

	constant c_Data_depth: NATURAL :=  256;
	constant c_Page_Size : NATURAL := 256;
	constant c_UART_CLK_DIV : NATURAL := 868; --868 --217
	constant c_STROBE_COUNTER : NATURAL := 2;
	constant c_SDRAM_DATA_WIDTH : NATURAL := 32;
	constant c_SDRAM_PAGE_SIZE : NATURAL := 256;
	constant c_SDRAM_BANKS : NATURAL := 4;

	constant c_SDRAM_ADDR_DEPTH : NATURAL := 13;         -- row address + bank 2 bits
	constant c_SDRAM_ROW_BITS :NATURAL := 11;
	
	constant c_EBR_NUM_ADDR	:	NATURAL := 5;	
	
	--- BRAM_UNION CONSTANTS
	constant c_EBR_DATA_WIDTH : NATURAL := 32;
	constant c_EBR_ADDR_WIDTH : NATURAL := 8;	
	constant c_EBR_DATA_DEPTH : natural := 2**c_EBR_ADDR_WIDTH;
			

	constant c_TOTAL_EBR_KB : NATURAL := 56;      	-- must be even number, actual brams are half that number
	constant c_TOTAL_EBR : NATURAL := c_TOTAL_EBR_KB/2;
	
	constant c_TOTAL_EBR_WIDTH : NATURAL := integer(ceil(log2(real(c_TOTAL_EBR_KB))));
	
	type t_BRAM_DATA is array (0 to c_TOTAL_EBR-1) of std_logic_vector(c_EBR_DATA_WIDTH-1 downto 0);
--=========================================================================================================================================
--=========================================================================================================================================
--===================================== HERE STARTS SDRAM TIMING AND OTHER CONSTANTS ======================================================			
--=========================================================================================================================================
--=========================================================================================================================================


	-- SDRAM mode register definition
	--

	-- Write Burst Mode
	constant Programmed_Length:std_logic := '0';
	constant Single_Access    :std_logic := '1';

	--Operation Mode
	--constant Standard :std_logic_vector(1 downto 0) := "00";

	--CAS Latency
	constant Latency_2:std_logic_vector(2 downto 0) := "010";
	constant Latency_3:std_logic_vector(2 downto 0) := "011";

	-- Burst Type
	constant Sequential :std_logic:= '0';
	constant Interleaved:std_logic:= '1';

	-- Burst Length
	constant Length_1:std_logic_vector(2 downto 0)	:= "000";
	constant Length_2:std_logic_vector(2 downto 0)	:= "001";
	constant Length_4:std_logic_vector(2 downto 0)	:= "010";
	constant Length_8:std_logic_vector(2 downto 0)	:= "011";
	constant Length_Full_Page:std_logic_vector(2 downto 0)	:= "111";
	-----------------------------------------------------------------------
	-- User modifiable parameters
	--

	--/****************************
	--* Mode register setting
	--****************************/

	constant MR_Write_Burst_Mode:std_logic := Programmed_Length;
	--                                // Single_Access;

	constant MR_Operation_Mode:std_logic_vector(1 downto 0) := "00";

	constant MR_CAS_Latency : std_logic_vector(2 downto 0) := Latency_2;

	constant MR_Burst_Type:std_logic :=    Sequential;
									--// Interleaved;

	constant MR_Burst_Length:std_logic_vector(2 downto 0) :=  Length_Full_Page;

	--/****************************
	--* Bus width setting
	--****************************/

	--
	--           23 ......... 12     11 ....... 10      9 .........0
	-- sys_A  : MSB <-------------------------------------------> LSB
	--
	-- Row    : RA_MSB <--> RA_LSB
	-- Bank   :                    BA_MSB <--> BA_LSB
	-- Column :                                       CA_MSB <--> CA_LSB
	--
	constant SYS_DATA_WIDTH: integer := 32;    	---  added to make controler easily adjustable
	constant SDR_DATA_WIDTH: integer := 32;		---  added to make controler easily adjustable

	constant RA_MSB:integer := 20;
	constant RA_LSB:integer := 10;

	constant BA_MSB :integer := 9;
	constant BA_LSB :integer :=  8;

	constant CA_MSB :integer:=  7;
	constant CA_LSB :integer:=  0;

	constant SDR_BA_WIDTH :integer:=  2; -- BA0,BA1
	constant SDR_A_WIDTH  :integer:= 11; -- A0-A10

	--/****************************
	--* SDRAM AC timing spec
	--****************************/

	--parameter tCK  = 12; //Comments by Zhipeng
	--constant tCK  :time:= 10 ns;
	--constant t_TIME	:time := 7 ns;	
	constant tMRD :time:= 2 * tCK;
	constant tRP  :time:= 20 ns;
	constant tRFC :time:= 60 ns;
	constant tRCD :time:= 20 ns;
	constant tWR  :time:= 2 * tCK;          --tCK + ( 7 ns);
	constant tDAL :time:= tRP + tWR;
	constant tAC  :time:= 6 ns;

	constant  tCkP	:time := tCK/2;
	-----------------------------------------------------------------------
	-- Clock count definition for meeting SDRAM AC timing spec
	--
	constant NUM_CLK_tAC  :integer:= tAC/tCkP;
	constant NUM_CLK_tMRD :integer:= tMRD/tCK;
	constant NUM_CLK_tRP  :integer:= tRP/tCK;
	constant NUM_CLK_tRFC :integer:= tRFC/tCK;
	constant NUM_CLK_tRCD :integer:= tRCD/tCK;
	constant NUM_CLK_tDAL :integer:= tDAL/tCK;

	-- tDAL needs to be satisfied before the next sdram ACTIVE command can
	-- be issued. State c_tDAL of CMD_FSM is created for this purpose.
	-- However, states c_idle, c_ACTIVE and c_tRCD need to be taken into
	-- account because ACTIVE command will not be issued until CMD_FSM
	-- switch from c_ACTIVE to c_tRCD. NUM_CLK_WAIT is the version after
	-- the adjustment.
	--parameter NUM_CLK_WAIT = (NUM_CLK_tDAL < 3) ? 0 : NUM_CLK_tDAL - 3;
	constant NUM_CLK_WAIT:integer:= 0 ;--when (NUM_CLK_tDAL < 3) else (NUM_CLK_tDAL - 3) ;
	--parameter NUM_CLK_CL    = (MR_CAS_Latency == Latency_2) ? 2 :
	--                          (MR_CAS_Latency == Latency_3) ? 3 :
	--                          3;  // default
	constant NUM_CLK_CL:integer:=2;
	--parameter NUM_CLK_READ  = (MR_Burst_Length == Length_1) ? 1 :
	--                          (MR_Burst_Length == Length_2) ? 2 :
	--                          (MR_Burst_Length == Length_4) ? 4 :
	--                          (MR_Burst_Length == Length_8) ? 8 :
	--                          4; // default
	constant NUM_CLK_READ:integer:=255;
	--
	--parameter NUM_CLK_WRITE = (MR_Burst_Length == Length_1) ? 1 :
	--                          (MR_Burst_Length == Length_2) ? 2 :
	--                          (MR_Burst_Length == Length_4) ? 4 :
	--                          (MR_Burst_Length == Length_8) ? 8 :
	--                          4; // default
	constant NUM_CLK_WRITE:integer:=255;

--==================================================================================================================
--==================================================================================================================
--===================================== END OF SDRAM CONSTANTS =====================================================			
--==================================================================================================================
--==================================================================================================================	

end type_def_package;
