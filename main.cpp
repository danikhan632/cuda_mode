#include "Vtb_sparse_coo_matmul.h"
#include "verilated.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vtb_sparse_coo_matmul* top = new Vtb_sparse_coo_matmul;
    top->eval();
    delete top;
    return 0;
}