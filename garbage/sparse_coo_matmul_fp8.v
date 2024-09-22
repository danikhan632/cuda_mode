module sparse_coo_matmul_fp8(
    input [7:0] A_data[31:0],
    input [2:0] A_row[31:0],
    input [2:0] A_col[31:0],
    input A_valid[31:0],
    input [7:0] B_data[31:0],
    input [2:0] B_row[31:0],
    input [2:0] B_col[31:0],
    input B_valid[31:0],
    output reg [31:0] C[7:0][7:0]
);

    integer i, j;
    reg [31:0] a_fp32, b_fp32;
    FP8_E4M3 A_fp8_to_fp32(.value(A_data[i]), .fp32_value(a_fp32));
    FP8_E4M3 B_fp8_to_fp32(.value(B_data[j]), .fp32_value(b_fp32));

    always @(*) begin
        // Initialize C to zero
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                C[i][j] = 0;
            end
        end

        // Perform sparse matrix multiplication
        for (i = 0; i < 32; i = i + 1) begin
            if (A_valid[i]) begin
                for (j = 0; j < 32; j = j + 1) begin
                    if (B_valid[j] && A_col[i] == B_row[j]) begin
                        C[A_row[i]][B_col[j]] = C[A_row[i]][B_col[j]] + a_fp32 * b_fp32;
                    end
                end
            end
        end
    end
endmodule
