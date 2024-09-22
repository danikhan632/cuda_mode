clear
# verilator --cc --exe --build -j 0 -Wall tb_sparse_coo_matmul.sv sparse_coo_matmul.sv --timing --binary --main --trace --CFLAGS "-std=c++20 " --top tb_sparse_coo_matmul 
verilator --cc --exe --build -j 0 -Wall --timing --binary --main --trace --top tb_sparse_coo_matmul --CFLAGS "-std=c++20 -fcoroutines" tb_sparse_coo_matmul.sv sparse_coo_matmul.sv && \ 
    ./obj_dir/Vtb_sparse_coo_matmul
