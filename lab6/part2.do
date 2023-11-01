```# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog part2.v

#load simulation using mux as the top level simulation module
vsim part2

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {Clock} 0 0ns, 1 {5 ns} -r 10ns 
#changes from 0 to 1 every 5 ns --> repeats every 10 ns


force Reset 1;
force Go 0;
run 10ns

# Test: set all to A = 5, B = 4, C = 3, x = 2; result = 31
force Reset 0;
force Go 1;
force DataIn 8'd5; # A = 5
run 10ns
force Reset 0;
force Go 0;
force DataIn 8'd4; # B = 4
run 10ns
force Reset 0;
force Go 1;
force DataIn 8'd4; # B = 4
run 10ns
force Reset 0;
force Go 0;
force DataIn 8'd3; # C = 3
run 10ns
force Reset 0;
force Go 1;
force DataIn 8'd3; # C = 3
run 10ns
force Reset 0;
force Go 0;
force DataIn 8'd2; # x = 2
run 10ns
force Reset 0;
force Go 1;
force DataIn 8'd2; # x = 2
run 10ns
#Test case ^ checks if values are being loaded
force Reset 0;
force Go 0;
force DataIn 8'd2; # x = 2
run 100ns
#Test case ^ checks if ALU is working
force Reset 0;
force Go 1;
force DataIn 8'd2; 
#Test case ^ checks Result Valid sets back to default value
run 10ns


##### next test 

force Reset 1;
force Go 0;
run 10ns

# Test: set all to A = 1, B = 1, C = 1, x = 0; result = 1
force Reset 0;
force Go 1;
force DataIn 8'd1; # A = 5
run 10ns
force Reset 0;
force Go 0;
force DataIn 8'd1; # B = 4
run 10ns
force Reset 0;
force Go 1;
force DataIn 8'd1; # B = 4
run 10ns
force Reset 0;
force Go 0;
force DataIn 8'd1; # C = 3
run 10ns
force Reset 0;
force Go 1;
force DataIn 8'd1; # C = 3
run 10ns
force Reset 0;
force Go 0;
force DataIn 8'd0; # x = 2
run 10ns
force Reset 0;
force Go 1;
force DataIn 8'd0; # x = 2
run 10ns

#Test case ^ checks if values are being loaded

force Reset 0;
force Go 0;
force DataIn 8'd0; # x = 2
run 100ns

#Test case ^ checks if ALU is working
force Reset 0;
force Go 1;
force DataIn 8'd2; 

#Test case ^ checks Result Valid sets back to default value
run 10ns```

