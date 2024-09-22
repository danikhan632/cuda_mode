clear
verilator --cc --exe --build -j 0 -Wall tb_sparse_coo_matmul.sv sparse_coo_matmul.sv --timing --binary --trace --CFLAGS "-std=c++20 -fcoroutines"

./obj_dir/Vtb_sparse_coo_matmul