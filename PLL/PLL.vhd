-- VHDL netlist generated by SCUBA Diamond (64-bit) 3.12.0.240.2
-- Module  Version: 5.7
--C:\lscc\diamond\3.12\ispfpga\bin\nt64\scuba.exe -w -n PLL -lang vhdl -synth synplify -bus_exp 7 -bb -arch sa5p00 -type pll -fin 25.00 -fclkop 100.00 -fclkop_tol 0.0 -phase_cntl STATIC -fb_mode 1 -fdc C:/Git/fpga_sdram_connection/SDR_Manager/PLL/PLL.fdc 

-- Wed Feb 15 14:27:06 2023

library IEEE;
use IEEE.std_logic_1164.all;
library ECP5U;
use ECP5U.components.all;

entity PLL is
    port (
        CLKI: in  std_logic; 
        CLKOP: out  std_logic);
end PLL;

architecture Structure of PLL is

    -- internal signal declarations
    signal REFCLK: std_logic;
    signal LOCK: std_logic;
    signal CLKOP_t: std_logic;
    signal scuba_vhi: std_logic;
    signal scuba_vlo: std_logic;

    attribute FREQUENCY_PIN_CLKOP : string; 
    attribute FREQUENCY_PIN_CLKI : string; 
    attribute ICP_CURRENT : string; 
    attribute LPF_RESISTOR : string; 
    attribute FREQUENCY_PIN_CLKOP of PLLInst_0 : label is "100.000000";
    attribute FREQUENCY_PIN_CLKI of PLLInst_0 : label is "25.000000";
    attribute ICP_CURRENT of PLLInst_0 : label is "5";
    attribute LPF_RESISTOR of PLLInst_0 : label is "16";
    attribute syn_keep : boolean;
    attribute NGD_DRC_MASK : integer;
    attribute NGD_DRC_MASK of Structure : architecture is 1;

begin
    -- component instantiation statements
    scuba_vhi_inst: VHI
        port map (Z=>scuba_vhi);

    scuba_vlo_inst: VLO
        port map (Z=>scuba_vlo);

    PLLInst_0: EHXPLLL
        generic map (PLLRST_ENA=> "DISABLED", INTFB_WAKE=> "DISABLED", 
        STDBY_ENABLE=> "DISABLED", DPHASE_SOURCE=> "DISABLED", 
        CLKOS3_FPHASE=>  0, CLKOS3_CPHASE=>  0, CLKOS2_FPHASE=>  0, 
        CLKOS2_CPHASE=>  0, CLKOS_FPHASE=>  0, CLKOS_CPHASE=>  0, 
        CLKOP_FPHASE=>  0, CLKOP_CPHASE=>  5, PLL_LOCK_MODE=>  0, 
        CLKOS_TRIM_DELAY=>  0, CLKOS_TRIM_POL=> "FALLING", 
        CLKOP_TRIM_DELAY=>  0, CLKOP_TRIM_POL=> "FALLING", 
        OUTDIVIDER_MUXD=> "DIVD", CLKOS3_ENABLE=> "DISABLED", 
        OUTDIVIDER_MUXC=> "DIVC", CLKOS2_ENABLE=> "DISABLED", 
        OUTDIVIDER_MUXB=> "DIVB", CLKOS_ENABLE=> "DISABLED", 
        OUTDIVIDER_MUXA=> "DIVA", CLKOP_ENABLE=> "ENABLED", CLKOS3_DIV=>  1, 
        CLKOS2_DIV=>  1, CLKOS_DIV=>  1, CLKOP_DIV=>  6, CLKFB_DIV=>  4, 
        CLKI_DIV=>  1, FEEDBK_PATH=> "CLKOP")
        port map (CLKI=>CLKI, CLKFB=>CLKOP_t, PHASESEL1=>scuba_vlo, 
            PHASESEL0=>scuba_vlo, PHASEDIR=>scuba_vlo, 
            PHASESTEP=>scuba_vlo, PHASELOADREG=>scuba_vlo, 
            STDBY=>scuba_vlo, PLLWAKESYNC=>scuba_vlo, RST=>scuba_vlo, 
            ENCLKOP=>scuba_vlo, ENCLKOS=>scuba_vlo, ENCLKOS2=>scuba_vlo, 
            ENCLKOS3=>scuba_vlo, CLKOP=>CLKOP_t, CLKOS=>open, 
            CLKOS2=>open, CLKOS3=>open, LOCK=>LOCK, INTLOCK=>open, 
            REFCLK=>REFCLK, CLKINTFB=>open);

    CLKOP <= CLKOP_t;
end Structure;
