view source
view objects
view variables
view wave -undock

delete wave *
add wave /lock/*
add wave /lock/sttran/count_v


force -deposit /rst_n 0 0, 1 {45 ns}
force -deposit /clk 1 0, 0 {10ns} -repeat 20
force -deposit /keys_in 0000 0
run 200

force -deposit /keys_in 2#0100
run 20
force -deposit /keys_in 2#0001
run 20
force -deposit /keys_in 2#0110
run 20
force -deposit /keys_in 2#1001
run 20
force -deposit /keys_in 2#0000
run 100

property wave -radix unsigned /lock/keys_in

force -deposit /keys_in 10#2, 10#5 20, 10#4 40, 10#1 60, 10#6 80, 10#9 100, 10#1 120, 10#8 140, 10#0 160
run 300

force -deposit /keys_in 10#4, 10#1 20, 10#9 60, 10#0 80
