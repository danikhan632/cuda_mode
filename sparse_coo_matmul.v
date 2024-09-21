`timescale 1ns / 1ps

module sparse_coo_matmul(
    input  wire [31:0] A_data_0, A_data_1, A_data_2, A_data_3,
    input  wire [1:0]  A_row_0, A_row_1, A_row_2, A_row_3,
    input  wire [1:0]  A_col_0, A_col_1, A_col_2, A_col_3,
    input  wire        A_valid_0, A_valid_1, A_valid_2, A_valid_3,
    input  wire [31:0] B_data_0, B_data_1, B_data_2, B_data_3,
    input  wire [1:0]  B_row_0, B_row_1, B_row_2, B_row_3,
    input  wire [1:0]  B_col_0, B_col_1, B_col_2, B_col_3,
    input  wire        B_valid_0, B_valid_1, B_valid_2, B_valid_3,
    output wire [31:0] C00, C01, C02, C03,
    output wire [31:0] C10, C11, C12, C13,
    output wire [31:0] C20, C21, C22, C23,
    output wire [31:0] C30, C31, C32, C33
);

    // Match signals for A_col[i] == B_row[j]
    wire [15:0] match;
    assign match[0]  = A_valid_0 & B_valid_0 & (A_col_0 == B_row_0);
    assign match[1]  = A_valid_0 & B_valid_1 & (A_col_0 == B_row_1);
    assign match[2]  = A_valid_0 & B_valid_2 & (A_col_0 == B_row_2);
    assign match[3]  = A_valid_0 & B_valid_3 & (A_col_0 == B_row_3);
    assign match[4]  = A_valid_1 & B_valid_0 & (A_col_1 == B_row_0);
    assign match[5]  = A_valid_1 & B_valid_1 & (A_col_1 == B_row_1);
    assign match[6]  = A_valid_1 & B_valid_2 & (A_col_1 == B_row_2);
    assign match[7]  = A_valid_1 & B_valid_3 & (A_col_1 == B_row_3);
    assign match[8]  = A_valid_2 & B_valid_0 & (A_col_2 == B_row_0);
    assign match[9]  = A_valid_2 & B_valid_1 & (A_col_2 == B_row_1);
    assign match[10] = A_valid_2 & B_valid_2 & (A_col_2 == B_row_2);
    assign match[11] = A_valid_2 & B_valid_3 & (A_col_2 == B_row_3);
    assign match[12] = A_valid_3 & B_valid_0 & (A_col_3 == B_row_0);
    assign match[13] = A_valid_3 & B_valid_1 & (A_col_3 == B_row_1);
    assign match[14] = A_valid_3 & B_valid_2 & (A_col_3 == B_row_2);
    assign match[15] = A_valid_3 & B_valid_3 & (A_col_3 == B_row_3);

    // Products
    wire [31:0] product [0:15];
    assign product[0]  = match[0]  ? A_data_0 * B_data_0 : 32'b0;
    assign product[1]  = match[1]  ? A_data_0 * B_data_1 : 32'b0;
    assign product[2]  = match[2]  ? A_data_0 * B_data_2 : 32'b0;
    assign product[3]  = match[3]  ? A_data_0 * B_data_3 : 32'b0;
    assign product[4]  = match[4]  ? A_data_1 * B_data_0 : 32'b0;
    assign product[5]  = match[5]  ? A_data_1 * B_data_1 : 32'b0;
    assign product[6]  = match[6]  ? A_data_1 * B_data_2 : 32'b0;
    assign product[7]  = match[7]  ? A_data_1 * B_data_3 : 32'b0;
    assign product[8]  = match[8]  ? A_data_2 * B_data_0 : 32'b0;
    assign product[9]  = match[9]  ? A_data_2 * B_data_1 : 32'b0;
    assign product[10] = match[10] ? A_data_2 * B_data_2 : 32'b0;
    assign product[11] = match[11] ? A_data_2 * B_data_3 : 32'b0;
    assign product[12] = match[12] ? A_data_3 * B_data_0 : 32'b0;
    assign product[13] = match[13] ? A_data_3 * B_data_1 : 32'b0;
    assign product[14] = match[14] ? A_data_3 * B_data_2 : 32'b0;
    assign product[15] = match[15] ? A_data_3 * B_data_3 : 32'b0;

    // Output assignments
    assign C00 = (A_row_0 == 2'b00 & B_col_0 == 2'b00 ? product[0] : 32'b0) +
                 (A_row_0 == 2'b00 & B_col_1 == 2'b00 ? product[1] : 32'b0) +
                 (A_row_0 == 2'b00 & B_col_2 == 2'b00 ? product[2] : 32'b0) +
                 (A_row_0 == 2'b00 & B_col_3 == 2'b00 ? product[3] : 32'b0) +
                 (A_row_1 == 2'b00 & B_col_0 == 2'b00 ? product[4] : 32'b0) +
                 (A_row_1 == 2'b00 & B_col_1 == 2'b00 ? product[5] : 32'b0) +
                 (A_row_1 == 2'b00 & B_col_2 == 2'b00 ? product[6] : 32'b0) +
                 (A_row_1 == 2'b00 & B_col_3 == 2'b00 ? product[7] : 32'b0) +
                 (A_row_2 == 2'b00 & B_col_0 == 2'b00 ? product[8] : 32'b0) +
                 (A_row_2 == 2'b00 & B_col_1 == 2'b00 ? product[9] : 32'b0) +
                 (A_row_2 == 2'b00 & B_col_2 == 2'b00 ? product[10] : 32'b0) +
                 (A_row_2 == 2'b00 & B_col_3 == 2'b00 ? product[11] : 32'b0) +
                 (A_row_3 == 2'b00 & B_col_0 == 2'b00 ? product[12] : 32'b0) +
                 (A_row_3 == 2'b00 & B_col_1 == 2'b00 ? product[13] : 32'b0) +
                 (A_row_3 == 2'b00 & B_col_2 == 2'b00 ? product[14] : 32'b0) +
                 (A_row_3 == 2'b00 & B_col_3 == 2'b00 ? product[15] : 32'b0);

    assign C01 = (A_row_0 == 2'b00 & B_col_0 == 2'b01 ? product[0] : 32'b0) +
                 (A_row_0 == 2'b00 & B_col_1 == 2'b01 ? product[1] : 32'b0) +
                 (A_row_0 == 2'b00 & B_col_2 == 2'b01 ? product[2] : 32'b0) +
                 (A_row_0 == 2'b00 & B_col_3 == 2'b01 ? product[3] : 32'b0) +
                 (A_row_1 == 2'b00 & B_col_0 == 2'b01 ? product[4] : 32'b0) +
                 (A_row_1 == 2'b00 & B_col_1 == 2'b01 ? product[5] : 32'b0) +
                 (A_row_1 == 2'b00 & B_col_2 == 2'b01 ? product[6] : 32'b0) +
                 (A_row_1 == 2'b00 & B_col_3 == 2'b01 ? product[7] : 32'b0) +
                 (A_row_2 == 2'b00 & B_col_0 == 2'b01 ? product[8] : 32'b0) +
                 (A_row_2 == 2'b00 & B_col_1 == 2'b01 ? product[9] : 32'b0) +
                 (A_row_2 == 2'b00 & B_col_2 == 2'b01 ? product[10] : 32'b0) +
                 (A_row_2 == 2'b00 & B_col_3 == 2'b01 ? product[11] : 32'b0) +
                 (A_row_3 == 2'b00 & B_col_0 == 2'b01 ? product[12] : 32'b0) +
                 (A_row_3 == 2'b00 & B_col_1 == 2'b01 ? product[13] : 32'b0) +
                 (A_row_3 == 2'b00 & B_col_2 == 2'b01 ? product[14] : 32'b0) +
                 (A_row_3 == 2'b00 & B_col_3 == 2'b01 ? product[15] : 32'b0);

    // C02 and C03 follow the same pattern as C01, changing the B_col comparison to 2'b10 and 2'b11 respectively
    assign C02 = 32'b0;  // Implement similarly to C00 and C01 if needed
    assign C03 = 32'b0;  // Implement similarly to C00 and C01 if needed

    // C10, C11, C12, C13 follow the same pattern as C00, C01, C02, C03, changing A_row comparison to 2'b01
    assign C10 = 32'b0;  // Implement similarly to C00 if needed
    assign C11 = 32'b0;  // Implement similarly to C01 if needed
    assign C12 = 32'b0;  // Implement similarly to C02 if needed
    assign C13 = 32'b0;  // Implement similarly to C03 if needed

    // C20, C21, C22, C23 follow the same pattern, changing A_row comparison to 2'b10
    assign C20 = 32'b0;  // Implement similarly to C00 if needed
    assign C21 = 32'b0;  // Implement similarly to C01 if needed
    assign C22 = 32'b0;  // Implement similarly to C02 if needed
    assign C23 = 32'b0;  // Implement similarly to C03 if needed

    // C30, C31, C32, C33 follow the same pattern, changing A_row comparison to 2'b11
    assign C30 = 32'b0;  // Implement similarly to C00 if needed
    assign C31 = 32'b0;  // Implement similarly to C01 if needed
    assign C32 = 32'b0;  // Implement similarly to C02 if needed
    assign C33 = 32'b0;  // Implement similarly to C03 if needed

endmodule
