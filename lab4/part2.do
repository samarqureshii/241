vlib work

vlog part2.v

vsim part2

log {/*}
add wave {/*}

force {Clock} 0 ns, 1 {5ns} -r 10ns

force Reset_b 1
run 10ns

force Reset_b 0

force Function 00
force {Data[3:0]} 0011
run 30ns

force Function 01
force {Data[3:0]} 0010 
run 20ns

force Function 10
force {Data[3:0]} 0001
run 20ns

force Function 11
run 20ns

# boundary values (1111)
force Function 00
force {Data[3:0]} 1111
run 30ns

# large left shifts
force Function 10
force {Data[3:0]} 1101
run 20ns

# multiple operations without reset
force Function 00
force {Data[3:0]} 0101
run 20ns
force Function 01
force {Data[3:0]} 0010
run 20ns

# overflow 
force Function 00
force {Data[3:0]} 1011
run 30ns

# changing Function and Data simultaneously
force Function 10
force {Data[3:0]} 0010
run 20ns
force Function 01
force {Data[3:0]} 1100
run 20ns