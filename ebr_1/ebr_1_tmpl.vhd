-- VHDL module instantiation generated by SCUBA Diamond (64-bit) 3.12.0.240.2
-- Module  Version: 6.5
-- Tue Feb 14 11:20:25 2023

-- parameterized module component declaration
component ebr_1
    port (WrAddress: in  std_logic_vector(8 downto 0); 
        RdAddress: in  std_logic_vector(8 downto 0); 
        Data: in  std_logic_vector(31 downto 0); WE: in  std_logic; 
        RdClock: in  std_logic; RdClockEn: in  std_logic; 
        Reset: in  std_logic; WrClock: in  std_logic; 
        WrClockEn: in  std_logic; Q: out  std_logic_vector(31 downto 0));
end component;

-- parameterized module component instance
__ : ebr_1
    port map (WrAddress(8 downto 0)=>__, RdAddress(8 downto 0)=>__, Data(31 downto 0)=>__, 
        WE=>__, RdClock=>__, RdClockEn=>__, Reset=>__, WrClock=>__, 
        WrClockEn=>__, Q(31 downto 0)=>__);
