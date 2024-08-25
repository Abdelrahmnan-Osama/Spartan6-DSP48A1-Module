vlib work
vlog dsp_dut.v reg_mux_pair.v dsp_tb1.v
vsim -voptargs=+acc tb1
add wave *
run -all
#quit -sim