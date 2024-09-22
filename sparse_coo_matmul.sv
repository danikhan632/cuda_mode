`timescale 1ns / 1ps

module sparse_coo_matmul(
    input logic rst,
    input wire clk,
    output logic [7:0][7:0][31:0] C   // Output matrix (8x8) in FP32
);

    // Hardcoded inputs for sparse matrix A
    logic [7:0][7:0] A_data ;  // Data values of A in FP8
    logic [7:0][31:0] A_row  ;  // Row indices of A
    logic [7:0][31:0] A_col;  // Column indices of A
    logic [31:0]      A_valid;  // Validity of the A entries

    // Hardcoded inputs for sparse matrix B
    logic [7:0][7:0] B_data ;  // Data values of B in FP8
    logic [7:0][31:0] B_row;  // Row indices of B
    logic [7:0][31:0] B_col;  // Column indices of B
    logic [31:0]      B_valid;  // Validity of the B entries

    integer i, j;

    // FP8 to real conversion function
    function automatic real fp8_to_real(input [7:0] fp8_value);
        logic sign;
        logic [3:0] exponent;
        logic [2:0] mantissa;
        real result;

        sign = fp8_value[7];
        exponent = fp8_value[6:3];
        mantissa = fp8_value[2:0];
        
        if (exponent == 4'b0000 && mantissa == 3'b000) begin
            result = 0.0;  // Zero
        end else begin
            result = (sign ? -1.0 : 1.0) * (1.0 + real'(mantissa) / 8.0) * (2.0 ** ($signed(exponent) - 7));
        end
        
        return result;
    endfunction

    // Initialize C to 0
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                C[i][j] = 32'b0;  // Initialize C to 0 (FP32 format)
            end
        end
    end

    logic [7:0][7:0][31:0] c_mul = '0;  // Temporary matrix to accumulate results (FP32 format)
    logic [31:0] mul_result_bits;        // Declare this outside of always_ff

    always_ff @(posedge clk) begin
        if (rst) begin
        c_mul <= '0;  // Properly initialize C with 32-bit zero values
        A_data <= '0;  // Use non-blocking assignment to initialize A_data
        A_row  <= '0;  // Initialize A_row with 3-bit zeros
        A_col  <= '0;  // Initialize A_col with 3-bit zeros
        A_valid <= '0;  // Initialize A_valid with 1-bit zeros
        end else begin
            // Perform sparse matrix multiplication
            for (i = 0; i < 32; i = i + 1) begin
                if (A_valid[i]) begin
                    for (j = 0; j < 32; j = j + 1) begin
                        if (B_valid[j] && (A_col[i] == B_row[j])) begin
                            // Convert FP8 to real, multiply, and accumulate
                            real a_real, b_real, mul_result;
                            a_real = fp8_to_real(A_data[i]);
                            b_real = fp8_to_real(B_data[j]);
                            mul_result = a_real * b_real;

                            // Convert mul_result to bits, truncate to 32 bits, and accumulate
                            mul_result_bits <= $realtobits(mul_result)[31:0];  // Convert real to FP32 bits

                            c_mul[A_row[i]][B_col[j]] <= c_mul[A_row[i]][B_col[j]] + mul_result_bits;
                        end
                    end
                end
            end
        end
    end

    // Assign accumulated result to output C
    assign C = c_mul;

endmodule
