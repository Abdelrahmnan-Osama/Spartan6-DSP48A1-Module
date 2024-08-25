vlib work
vlog dsp_dut.v reg_mux_pair.v dsp_tb3.v
vsim -voptargs=+acc tb3
add wave *
run -all
#quit -sim