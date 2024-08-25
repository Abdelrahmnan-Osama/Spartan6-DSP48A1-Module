vlib work
vlog dsp_dut.v reg_mux_pair.v dsp_tb2.v
vsim -voptargs=+acc tb2
add wave *
run -all
#quit -sim