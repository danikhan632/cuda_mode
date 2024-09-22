`timescale 1ns / 1ps

module sparse_coo_matmul(
    input wire clk,
    output logic [7:0][7:0][63:0] C   // Output matrix (8x8) in FP64
);

    // Hardcoded inputs for sparse matrix A
    logic [7:0] A_data [0:31];  // Data values of A in FP8
    logic [2:0] A_row  [0:31];  // Row indices of A
    logic [2:0] A_col  [0:31];  // Column indices of A
    logic       A_valid[0:31];  // Validity of the A entries

    // Hardcoded inputs for sparse matrix B
    logic [7:0] B_data [0:31];  // Data values of B in FP8
    logic [2:0] B_row  [0:31];  // Row indices of B
    logic [2:0] B_col  [0:31];  // Column indices of B
    logic       B_valid[0:31];  // Validity of the B entries

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
                C[i][j] = 64'b0;
            end
        end
    end

    logic [7:0][7:0][63:0] c_mul = '0;
    always_ff @(posedge clk) begin
        $display("cmul %p", c_mul);
        
        // Perform sparse matrix multiplication
        for (i = 0; i < 32; i = i + 1) begin
            if (A_valid[i]) begin
                $display("foo %d",A_valid[i]);
                
                for (j = 0; j < 32; j = j + 1) begin
                    if (B_valid[j] && (A_col[i] == B_row[j])) begin
                        // Convert FP8 to real, multiply, and accumulate
                        real a_real, b_real, mul_result;
                        a_real <= fp8_to_real(A_data[i]);
                        b_real <= fp8_to_real(B_data[j]);
                        mul_result <= a_real * b_real;
                        c_mul[A_row[i]][B_col[j]] <= c_mul[A_row[i]][B_col[j]] + $realtobits(mul_result);
                    end
                end
            end
        end
    end

    assign C = c_mul;

endmodule
