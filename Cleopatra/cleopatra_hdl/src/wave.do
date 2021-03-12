onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/cpu/CU/reset
add wave -noupdate /tb/cpu/CU/clock
add wave -noupdate /tb/cpu/CU/halt
add wave -noupdate -radixshowbase 0 /tb/cpu/CU/ir
add wave -noupdate /tb/cpu/CU/irq
add wave -noupdate /tb/cpu/CU/iack
add wave -noupdate /tb/cpu/CU/EA
add wave -noupdate /tb/cpu/CU/PE
add wave -noupdate -radix hexadecimal /tb/cpu/CU/i
add wave -noupdate -divider PC
add wave -noupdate /tb/cpu/DP/REG_PC/ce
add wave -noupdate -radix hexadecimal /tb/cpu/DP/REG_PC/D
add wave -noupdate -radix hexadecimal /tb/cpu/DP/REG_PC/Q
add wave -noupdate -divider RS
add wave -noupdate /tb/cpu/DP/REG_RS/ce
add wave -noupdate -radix hexadecimal /tb/cpu/DP/REG_RS/D
add wave -noupdate -radix hexadecimal /tb/cpu/DP/REG_RS/Q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {599 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 135
configure wave -valuecolwidth 72
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1144 ns} {1671 ns}
