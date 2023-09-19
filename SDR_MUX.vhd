library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.type_def_package.all;


entity SDR_MUX is
	port (
		--SDRAM MUX OUT I/O 	    
			sys_R_Wn			:OUT std_logic;							--read/write signal, high indicates reading and low indicates writing
			sys_ADSn			:OUT std_logic;							--active low address strobe
			sys_A				:OUT std_logic_vector( RA_MSB downto CA_LSB);	--address bus
			sys_REF_REQ 		:OUT STD_LOGIC;			
		--EBR_TO_SDRAM I/O	
			sys_R_Wn1			:IN std_logic;							--read/write signal, high indicates reading and low indicates writing
			sys_ADSn1			:IN std_logic;							--active low address strobe
			sys_A1				:IN std_logic_vector( RA_MSB downto CA_LSB);	--address bus
			sys_REF_REQ1 		:IN STD_LOGIC;
		--SDRAM_READ I/O 
			sys_R_Wn2			:IN std_logic;							--read/write signal, high indicates reading and low indicates writing
			sys_ADSn2			:IN std_logic;							--active low address strobe
			sys_A2				:IN std_logic_vector( RA_MSB downto CA_LSB);	--address bus
			sys_REF_REQ2 		:IN STD_LOGIC;	
			
			SDRM_sdr_mux			:IN STD_LOGIC_VECTOR(1 downto 0)
		
		);
end SDR_MUX;

architecture rtl of SDR_MUX is 
begin 
	
	sys_R_Wn			<= 	sys_R_Wn1 when SDRM_sdr_mux = "01" else 
						 	sys_R_Wn2 when SDRM_sdr_mux = "10" else '1';--sys_R_Wn2;
						
	sys_ADSn			<= 	sys_ADSn1 when SDRM_sdr_mux = "01" else 
						 	sys_ADSn2 when SDRM_sdr_mux = "10" else '1';--sys_ADSn2;
						
	sys_A				<= 	sys_A1 when SDRM_sdr_mux = "01" else 
						   	sys_A2 when SDRM_sdr_mux = "10" else (others => '0') ;		--sys_A2;
	
	sys_REF_REQ			<= 	sys_REF_REQ1 when SDRM_sdr_mux = "01" else 
						   	sys_REF_REQ2 when SDRM_sdr_mux = "10" else '0';--sys_A2;	

end rtl;