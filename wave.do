onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/uut/clk_i
add wave -noupdate /top_tb/uut/rst_n_i
add wave -noupdate -divider IRAM
add wave -noupdate /top_tb/uut/i_addr_o
add wave -noupdate /top_tb/uut/i_rd_o
add wave -noupdate /top_tb/uut/i_data_i
add wave -noupdate -divider DRAM
add wave -noupdate /top_tb/uut/pc_r
add wave -noupdate /top_tb/uut/d_addr_o
add wave -noupdate /top_tb/uut/d_rd_o
add wave -noupdate /top_tb/uut/d_data_i
add wave -noupdate /top_tb/uut/d_wr_o
add wave -noupdate /top_tb/uut/d_data_o
add wave -noupdate -divider {New Divider}
add wave -noupdate /top_tb/uut/clk_i
add wave -noupdate /top_tb/uut/i_data_i
add wave -noupdate /top_tb/uut/alu_op_w
add wave -noupdate /top_tb/uut/branch_w
add wave -noupdate /top_tb/uut/jump_w
add wave -noupdate /top_tb/uut/pc_write_w
add wave -noupdate /top_tb/uut/mem_read_w
add wave -noupdate /top_tb/uut/mem_write_w
add wave -noupdate /top_tb/uut/mem_to_reg_w
add wave -noupdate /top_tb/uut/alu_result_w
add wave -noupdate /top_tb/uut/read_data_w
add wave -noupdate /top_tb/uut/imm_w
add wave -noupdate /top_tb/uut/zero_w
add wave -noupdate -divider {New Divider}
add wave -noupdate /top_tb/uut/clk_i
add wave -noupdate {/top_tb/uut/regfile_inst/regfile[1]}
add wave -noupdate /top_tb/uut/rd_w
add wave -noupdate /top_tb/uut/reg_write_w
add wave -noupdate /top_tb/uut/write_data_w
add wave -noupdate /top_tb/uut/rs1_w
add wave -noupdate /top_tb/uut/rs1_data_w
add wave -noupdate /top_tb/uut/rs2_w
add wave -noupdate /top_tb/uut/rs2_data_w
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {35 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 284
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ns} {96 ns}
