clear
verilator -Wall --cc sparse_coo_matmul.v tb_sparse_coo_matmul.v --exe main.cpp
