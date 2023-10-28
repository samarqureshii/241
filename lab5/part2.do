vlib work

vlog part2.v

vsim -G CLOCK_FREQUENCY=4 part2 

log {/*}
add wave {/*}

force {ClockIn} 0 0ms, 1 {125ms} -r 250ms

force Reset 1
run 500ms
force Reset 0

force Speed 00
run 1000ms
 
force Reset 1
run 250ms
force Reset 0

force Speed 01 
run 20000ms

force Speed 10
run 6000ms

force Speed 11
run 20000ms