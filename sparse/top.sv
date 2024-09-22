import sparse_pkg::*;

/*
    Performs the matrix multiply
    C = A * B
    Where A is of dim [M, N]
    and B is of dim [N, K]
    and A and B are provided as COO sparse format matrices
*/
module sparse_mm #(
    parameter DATA_SIZE = 16,
    parameter M = 4,
    parameter N = 4,
    parameter K = 4,
    parameter MAX_LIST_SIZE = 30
) (
    input logic clk,
    input entry [MAX_LIST_SIZE-1:0] a_list,
    input entry [MAX_LIST_SIZE-1:0] b_list,
    output [M-1:0][K-1:0] out
);
    pair [M-1:0][N-1:0][N-1:0] buffers;
    generate
        for (int i = 0; i < M; i++) begin
            for (int j = 0; j < N; j++) begin
                MAC #(.N = N, ) mac(
                    .clk(clk),
                    .buffer(buffers[i][j]),
                    
                )

            end
        end    
    endgenerate

endmodule