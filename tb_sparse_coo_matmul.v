`timescale 1ns / 1ps

module tb_sparse_coo_matmul;

    // Inputs
    reg [31:0] A_data [0:3];
    reg [1:0]  A_row  [0:3];
    reg [1:0]  A_col  [0:3];
    reg        A_valid[0:3];

    reg [31:0] B_data [0:3];
    reg [1:0]  B_row  [0:3];
    reg [1:0]  B_col  [0:3];
    reg        B_valid[0:3];

    // Outputs
    wire [31:0] C00, C01, C02, C03;
    wire [31:0] C10, C11, C12, C13;
    wire [31:0] C20, C21, C22, C23;
    wire [31:0] C30, C31, C32, C33;

    // Instantiate the Unit Under Test (UUT)
    sparse_coo_matmul uut (
        .A_data_0(A_data[0]), .A_data_1(A_data[1]), .A_data_2(A_data[2]), .A_data_3(A_data[3]),
        .A_row_0(A_row[0]), .A_row_1(A_row[1]), .A_row_2(A_row[2]), .A_row_3(A_row[3]),
        .A_col_0(A_col[0]), .A_col_1(A_col[1]), .A_col_2(A_col[2]), .A_col_3(A_col[3]),
        .A_valid_0(A_valid[0]), .A_valid_1(A_valid[1]), .A_valid_2(A_valid[2]), .A_valid_3(A_valid[3]),
        .B_data_0(B_data[0]), .B_data_1(B_data[1]), .B_data_2(B_data[2]), .B_data_3(B_data[3]),
        .B_row_0(B_row[0]), .B_row_1(B_row[1]), .B_row_2(B_row[2]), .B_row_3(B_row[3]),
        .B_col_0(B_col[0]), .B_col_1(B_col[1]), .B_col_2(B_col[2]), .B_col_3(B_col[3]),
        .B_valid_0(B_valid[0]), .B_valid_1(B_valid[1]), .B_valid_2(B_valid[2]), .B_valid_3(B_valid[3]),
        .C00(C00), .C01(C01), .C02(C02), .C03(C03),
        .C10(C10), .C11(C11), .C12(C12), .C13(C13),
        .C20(C20), .C21(C21), .C22(C22), .C23(C23),
        .C30(C30), .C31(C31), .C32(C32), .C33(C33)
    );

    // Testbench sequence
    initial begin
        // Initialize Inputs
        // For A matrix
        A_data[0] = 32'd2; A_row[0] = 2'd0; A_col[0] = 2'd1; A_valid[0] = 1'b1;
        A_data[1] = 32'd3; A_row[1] = 2'd1; A_col[1] = 2'd2; A_valid[1] = 1'b1;
        A_data[2] = 32'd4; A_row[2] = 2'd2; A_col[2] = 2'd3; A_valid[2] = 1'b1;
        A_data[3] = 32'd0; A_row[3] = 2'd0; A_col[3] = 2'd0; A_valid[3] = 1'b0; // Not valid

        // For B matrix
        B_data[0] = 32'd5; B_row[0] = 2'd1; B_col[0] = 2'd0; B_valid[0] = 1'b1;
        B_data[1] = 32'd6; B_row[1] = 2'd2; B_col[1] = 2'd1; B_valid[1] = 1'b1;
        B_data[2] = 32'd7; B_row[2] = 2'd3; B_col[2] = 2'd2; B_valid[2] = 1'b1;
        B_data[3] = 32'd0; B_row[3] = 2'd0; B_col[3] = 2'd0; B_valid[3] = 1'b0; // Not valid

        // Display Outputs
        $display("C00: %d", C00);
        $display("C01: %d", C01);
        $display("C02: %d", C02);
        $display("C03: %d", C03);
        $display("C10: %d", C10);
        $display("C11: %d", C11);
        $display("C12: %d", C12);
        $display("C13: %d", C13);
        $display("C20: %d", C20);
        $display("C21: %d", C21);
        $display("C22: %d", C22);
        $display("C23: %d", C23);
        $display("C30: %d", C30);
        $display("C31: %d", C31);
        $display("C32: %d", C32);
        $display("C33: %d", C33);

        $finish;
    end

endmodule
