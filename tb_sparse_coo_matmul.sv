`timescale 1ns / 1ps

module tb_sparse_coo_matmul();

    // Testbench signals
    logic clk;
    logic rst;
    
    // 8x8 matrix of 32-bit elements (FP32 format)
    logic [31:0][7:0][7:0] C;  

    // Instantiate the Unit Under Test (UUT)
    sparse_coo_matmul uut (
        .rst(rst),
        .clk(clk),
        .C(C)
    );

    // Clock generation
    always begin
        #5 clk <= ~clk;  // 100 MHz clock
    end

    // Optional: Print matrix values if needed to avoid the unused signal warning
    task print_matrix;
        $display("Resulting Matrix C:");
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                $display("C[%0d][%0d] = %d", i, j, C[i][j]);
            end
        end
    endtask

    // Testbench process
    initial begin
        // Initialize inputs
        $dumpfile("trace.vcd");
        $dumpvars();
        clk = 0;
        rst = 1;
        repeat(10) @(posedge clk);
        rst = 0;

        // Initialize the matrices A and B in the UUT using FP8 values
        // A matrix encoded in FP8 (E4M3)
        uut.A_data[0] = 8'b00111000; uut.A_row[0] = 0; uut.A_col[0] = 0; uut.A_valid[0] = 1;
        uut.A_data[1] = 8'b01000000; uut.A_row[1] = 0; uut.A_col[1] = 1; uut.A_valid[1] = 1;
        uut.A_data[2] = 8'b01001000; uut.A_row[2] = 0; uut.A_col[2] = 2; uut.A_valid[2] = 1;
        uut.A_data[3] = 8'b01010000; uut.A_row[3] = 1; uut.A_col[3] = 0; uut.A_valid[3] = 1;
        uut.A_data[4] = 8'b01011000; uut.A_row[4] = 1; uut.A_col[4] = 1; uut.A_valid[4] = 1;
        uut.A_data[5] = 8'b01100000; uut.A_row[5] = 1; uut.A_col[5] = 2; uut.A_valid[5] = 1;
        uut.A_data[6] = 8'b01101000; uut.A_row[6] = 2; uut.A_col[6] = 0; uut.A_valid[6] = 1;
        uut.A_data[7] = 8'b01110000; uut.A_row[7] = 2; uut.A_col[7] = 1; uut.A_valid[7] = 1;

        // Similar initialization for B matrix
        uut.B_data[0] = 8'b00111000; uut.B_row[0] = 0; uut.B_col[0] = 0; uut.B_valid[0] = 1;
        uut.B_data[1] = 8'b01000000; uut.B_row[1] = 1; uut.B_col[1] = 1; uut.B_valid[1] = 1;
        uut.B_data[2] = 8'b01001000; uut.B_row[2] = 2; uut.B_col[2] = 2; uut.B_valid[2] = 1;
        uut.B_data[3] = 8'b01010000; uut.B_row[3] = 3; uut.B_col[3] = 3; uut.B_valid[3] = 1;
        uut.B_data[4] = 8'b01011000; uut.B_row[4] = 1; uut.B_col[4] = 1; uut.B_valid[4] = 1;
        uut.B_data[5] = 8'b01100000; uut.B_row[5] = 1; uut.B_col[5] = 2; uut.B_valid[5] = 1;
        uut.B_data[6] = 8'b01101000; uut.B_row[6] = 2; uut.B_col[6] = 0; uut.B_valid[6] = 1;
        uut.B_data[7] = 8'b01110000; uut.B_row[7] = 2; uut.B_col[7] = 1; uut.B_valid[7] = 1;

        // Mark unused elements as invalid in both A and B matrices
        for (int i = 8; i < 32; i++) begin
            uut.A_valid[i] = 0;
            uut.B_valid[i] = 0;
        end
        
        
        // Simulation start
        // Run the simulation for 100 clock cycles
        repeat(10) @(posedge clk);
        
        // Optionally print matrix after simulation
        print_matrix();

        // Run for another 100 clock cycles
        repeat(100) @(posedge clk);

        // Finish the simulation
        $finish;
    end

endmodule
