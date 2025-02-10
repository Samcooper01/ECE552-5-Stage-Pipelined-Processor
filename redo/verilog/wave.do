onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /proc_hier_pbench/DUT/p0/DECODE_inst/rf/writeData
add wave -noupdate /proc_hier_pbench/DUT/p0/DECODE_inst/rf/writeEn
add wave -noupdate /proc_hier_pbench/DUT/p0/DECODE_inst/rf/writeRegSel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1333 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 347
configure wave -valuecolwidth 114
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
WaveRestoreZoom {0 ns} {1685 ns}
