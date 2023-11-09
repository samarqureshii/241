# set the working dir, where all compiled verilog Goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog part1.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver part1

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# create clock
force {clock} 0 0ns, 1 {5ns} -r 10ns

force address 5'd0
force data 4'd11
force wren 1'b1
run 10ns

force address 5'd4
force data 4'd22
run 10ns

force address 5'd3
force data 4'd45
run 10ns

force address 5'd2
force data 4'd100
run 10ns

force address 5'd1
force data 4'd00
run 10ns

force wren 1'b0
force address 5'd0
run 10ns

force address 5'd4
run 10ns

force address 5'd3
run 10ns

force address 5'd2
run 10ns

force address 5'd1
run 10ns

force address 5'd0
run 10ns