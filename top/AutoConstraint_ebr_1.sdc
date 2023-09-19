
#Begin clock constraint
define_clock -name {ebr_1|RdClock} {p:ebr_1|RdClock} -period 10000000.000 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 5000000.000 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {ebr_1|WrClock} {p:ebr_1|WrClock} -period 10000000.000 -clockgroup Autoconstr_clkgroup_1 -rise 0.000 -fall 5000000.000 -route 0.000 
#End clock constraint
