vlib work

vlog part1.v

vsim part1

log {/*}
add wave {/*} 
add wave /part1/CurState 

force {Clock} 0 0ns, 1 {5ns} -r 10ns


force resetn 0
run 10ns
force resetn 1
run 10ns

force w 1
run 40ns
force w 0
run 10ns
force w 1
run 10ns
force w 1
run 30ns
force resetn 0
run 20ns
force resetn 1
run 40ns


// edge cases

//1101
force w 1
run 10ns
force w 1
run 10ns
force w 0
run 10ns
force w 1
run 10ns

// overlap 11011 
force w 1
run 10ns
force w 1
run 10ns
force w 0
run 10ns
force w 1
run 10ns
force w 1
run 10ns

// overlap 11101
force w 1
run 10ns
force w 1
run 10ns
force w 1
run 10ns
force w 0
run 10ns
force w 1
run 10ns

run 100ns
