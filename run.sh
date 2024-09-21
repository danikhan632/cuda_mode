clear
verilator --cc --exe --build tb_sparse_coo_matmul.v sparse_coo_matmul.v main.cpp
./obj_dir/Vtb_sparse_coo_matmul